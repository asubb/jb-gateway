package com.jetbrains.sync

import java.nio.file.Path
import java.util.Scanner

/**
 * Handles conflict resolution when a file has been modified in both directories.
 */
class ConflictResolver(private val logger: Logger) {
    /**
     * Resolves a conflict between two files.
     *
     * @param src The source file
     * @param dst The destination file
     * @param srcDir The source directory
     * @param dstDir The destination directory
     * @return True if the conflict was resolved, false if it was skipped
     */
    fun resolveConflict(src: Path, dst: Path, srcDir: Path, dstDir: Path): Boolean {
        val relPath = srcDir.relativize(src)
        
        logger.warning("Conflict detected for file: $relPath")
        println()
        println("File has been modified in both directories:")
        println("1: $src")
        println("2: $dst")
        println()
        
        // Show diff
        println("Diff between the files:")
        println(FileUtils.showDiff(src, dst))
        println()
        
        // Ask user what to do
        val scanner = Scanner(System.`in`)
        
        while (true) {
            println(Logger.YELLOW + "How do you want to resolve this conflict?" + Logger.RESET)
            println("1) Use file from $srcDir")
            println("2) Use file from $dstDir")
            println("3) Skip this file")
            println("4) Show diff again")
            println("q) Quit synchronization")
            print("Enter your choice [1/2/3/4/q]: ")
            
            val choice = scanner.nextLine().trim()
            
            when (choice) {
                "1" -> {
                    logger.change("Using file from $srcDir: $relPath")
                    FileUtils.copyFile(src, dst)
                    return true
                }
                "2" -> {
                    logger.change("Using file from $dstDir: $relPath")
                    FileUtils.copyFile(dst, src)
                    return true
                }
                "3" -> {
                    logger.info("Skipping file: $relPath")
                    return false
                }
                "4" -> {
                    println("Diff between the files:")
                    println(FileUtils.showDiff(src, dst))
                    println()
                }
                "q", "Q" -> {
                    logger.info("Synchronization aborted by user")
                    System.exit(0)
                }
                else -> {
                    println(Logger.RED + "Invalid choice. Please try again." + Logger.RESET)
                }
            }
        }
    }
    
    /**
     * Handles a file that exists in one directory but not in the other.
     *
     * @param existingFile The existing file
     * @param existingDir The directory containing the existing file
     * @param missingDir The directory where the file is missing
     * @return True if the file was handled, false if it was skipped
     */
    fun handleDeletedFile(existingFile: Path, existingDir: Path, missingDir: Path): Boolean {
        val relPath = existingDir.relativize(existingFile)
        val missingFile = missingDir.resolve(relPath)
        
        println(Logger.YELLOW + "File exists in $existingDir but not in $missingDir: $relPath" + Logger.RESET)
        
        // Ask user what to do
        val scanner = Scanner(System.`in`)
        
        while (true) {
            println("What would you like to do?")
            println("1) Delete from $existingDir")
            println("2) Restore to $missingDir")
            println("3) Skip this file")
            print("Enter your choice [1/2/3]: ")
            
            val choice = scanner.nextLine().trim()
            
            when (choice) {
                "1" -> {
                    logger.change("Deleting file from $existingDir: $relPath")
                    existingFile.toFile().delete()
                    return true
                }
                "2" -> {
                    logger.change("Restoring file to $missingDir: $relPath")
                    FileUtils.copyFile(existingFile, missingFile)
                    return true
                }
                "3" -> {
                    logger.info("Skipping file: $relPath")
                    return false
                }
                else -> {
                    println(Logger.RED + "Invalid choice. Please try again." + Logger.RESET)
                }
            }
        }
    }
}