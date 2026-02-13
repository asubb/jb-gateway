package com.jetbrains.sync

import com.github.difflib.DiffUtils
import com.github.difflib.UnifiedDiffUtils
import java.io.File
import java.nio.file.*
import java.nio.file.attribute.BasicFileAttributes
import kotlin.io.path.exists
import kotlin.io.path.isDirectory
import kotlin.io.path.name

/**
 * Utility functions for file operations.
 */
object FileUtils {
    /**
     * Checks if a directory exists and creates it if it doesn't.
     *
     * @param path The directory path
     * @param logger The logger
     * @return The directory path
     */
    fun checkDirectory(path: Path, logger: Logger): Path {
        if (!path.exists()) {
            logger.warning("Directory does not exist: $path")
            logger.info("Creating directory: $path")
            Files.createDirectories(path)
        } else if (!path.isDirectory()) {
            logger.error("Path exists but is not a directory: $path")
            throw IllegalArgumentException("Path exists but is not a directory: $path")
        }
        return path
    }
    
    /**
     * Checks if a file matches any ignore pattern.
     *
     * @param filePath The file path relative to the root directory
     * @param ignorePatterns The list of ignore patterns
     * @return True if the file should be ignored, false otherwise
     */
    fun isIgnored(filePath: Path, ignorePatterns: List<String>): Boolean {
        if (ignorePatterns.isEmpty()) {
            return false
        }
        
        val pathStr = filePath.toString().replace('\\', '/')
        
        for (pattern in ignorePatterns) {
            val trimmedPattern = pattern.trim()
            
            // Check if pattern ends with / (directory pattern)
            if (trimmedPattern.endsWith("/")) {
                val dirPattern = trimmedPattern.dropLast(1)
                if (pathStr == dirPattern || pathStr.startsWith("$dirPattern/")) {
                    return true
                }
            }
            // Check if file matches pattern (simple glob pattern with * wildcard)
            else if (matchesGlob(pathStr, trimmedPattern)) {
                return true
            }
        }
        
        return false
    }
    
    /**
     * Checks if a path matches a glob pattern.
     * Supports only * wildcard for simplicity.
     *
     * @param path The path to check
     * @param pattern The glob pattern
     * @return True if the path matches the pattern, false otherwise
     */
    private fun matchesGlob(path: String, pattern: String): Boolean {
        val regex = pattern
            .replace(".", "\\.")
            .replace("*", ".*")
            .toRegex()
        
        return regex.matches(path)
    }
    
    /**
     * Shows the diff between two files.
     *
     * @param file1 The first file
     * @param file2 The second file
     * @return The diff as a string
     */
    fun showDiff(file1: Path, file2: Path): String {
        val file1Lines = Files.readAllLines(file1)
        val file2Lines = Files.readAllLines(file2)
        
        val patch = DiffUtils.diff(file1Lines, file2Lines)
        val diff = UnifiedDiffUtils.generateUnifiedDiff(
            file1.toString(),
            file2.toString(),
            file1Lines,
            patch,
            3 // Context size
        )
        
        return diff.joinToString("\n")
    }
    
    /**
     * Copies a file from source to destination, preserving attributes.
     *
     * @param source The source file
     * @param destination The destination file
     */
    fun copyFile(source: Path, destination: Path) {
        // Create parent directories if they don't exist
        val parent = destination.parent
        if (parent != null && !Files.exists(parent)) {
            Files.createDirectories(parent)
        }
        
        // Copy the file, replacing if it exists
        Files.copy(source, destination, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.COPY_ATTRIBUTES)
    }
    
    /**
     * Finds all files in a directory that are not hidden and don't match any ignore pattern.
     *
     * @param directory The directory to search
     * @param ignorePatterns The list of ignore patterns
     * @return A list of files
     */
    fun findFiles(directory: Path, ignorePatterns: List<String>): List<Path> {
        val files = mutableListOf<Path>()
        
        Files.walkFileTree(directory, object : SimpleFileVisitor<Path>() {
            override fun visitFile(file: Path, attrs: BasicFileAttributes): FileVisitResult {
                val relativePath = directory.relativize(file)
                
                // Skip hidden files and directories
                if (isHidden(relativePath)) {
                    return FileVisitResult.CONTINUE
                }
                
                // Skip ignored files
                if (isIgnored(relativePath, ignorePatterns)) {
                    return FileVisitResult.CONTINUE
                }
                
                files.add(file)
                return FileVisitResult.CONTINUE
            }
            
            override fun preVisitDirectory(dir: Path, attrs: BasicFileAttributes): FileVisitResult {
                // Skip hidden directories
                if (dir != directory && isHidden(directory.relativize(dir))) {
                    return FileVisitResult.SKIP_SUBTREE
                }
                
                return FileVisitResult.CONTINUE
            }
        })
        
        return files
    }
    
    /**
     * Checks if a path is hidden (starts with a dot).
     *
     * @param path The path to check
     * @return True if the path is hidden, false otherwise
     */
    private fun isHidden(path: Path): Boolean {
        return path.any { it.name.startsWith(".") }
    }
}