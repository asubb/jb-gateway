package com.jetbrains.sync

import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.attribute.FileTime
import kotlin.io.path.exists
import kotlin.io.path.getLastModifiedTime
import kotlin.io.path.isRegularFile

/**
 * Synchronizes two directories bidirectionally.
 */
class DirectorySynchronizer(private val config: Configuration) {
    private val logger = Logger(config)
    private val conflictResolver = ConflictResolver(logger)
    
    /**
     * Synchronizes the two directories.
     */
    fun synchronize() {
        val dir1 = config.dir1!!
        val dir2 = config.dir2!!
        
        // Remove trailing slashes
        val dir1Path = Path.of(dir1.toString().trimEnd('/'))
        val dir2Path = Path.of(dir2.toString().trimEnd('/'))
        
        // Check if directories exist
        FileUtils.checkDirectory(dir1Path, logger)
        FileUtils.checkDirectory(dir2Path, logger)
        
        logger.info("Starting bidirectional synchronization")
        logger.info("Directory 1: $dir1Path")
        logger.info("Directory 2: $dir2Path")
        logger.info("Log file: ${logger.getLogFile()}")
        
        // Handle deleted files in both directions
        handleDeletedFiles(dir1Path, dir2Path)
        handleDeletedFiles(dir2Path, dir1Path)
        
        // Sync files from dir1 to dir2
        syncFiles(dir1Path, dir2Path, "forward")
        
        // Sync files from dir2 to dir1
        syncFiles(dir2Path, dir1Path, "backward")
        
        logger.info("Synchronization completed successfully")
        println("${Logger.GREEN}Synchronization completed successfully${Logger.RESET}")
        println("Log file: ${logger.getLogFile()}")
    }
    
    /**
     * Synchronizes files from source to destination.
     *
     * @param src The source directory
     * @param dst The destination directory
     * @param direction The synchronization direction ("forward" or "backward")
     */
    private fun syncFiles(src: Path, dst: Path, direction: String) {
        logger.info("Synchronizing files from $src to $dst")
        
        // Find all files in source directory
        val srcFiles = FileUtils.findFiles(src, config.ignorePatterns)
        
        for (srcFile in srcFiles) {
            // Get relative path
            val relPath = src.relativize(srcFile)
            
            // Skip if the file is in a hidden directory
            if (FileUtils.isHidden(relPath)) {
                continue
            }
            
            // Skip if the file matches any ignore pattern
            if (FileUtils.isIgnored(relPath, config.ignorePatterns)) {
                if (config.logIgnoredFiles) {
                    logger.info("Ignoring file: $relPath")
                }
                continue
            }
            
            // Check if destination file exists
            val dstFile = dst.resolve(relPath)
            if (dstFile.exists() && dstFile.isRegularFile()) {
                // Check if files are different
                if (!Files.mismatch(srcFile, dstFile).equals(-1L)) {
                    // Check if destination file is newer
                    val srcModTime = srcFile.getLastModifiedTime()
                    val dstModTime = dstFile.getLastModifiedTime()
                    
                    if (direction == "forward") {
                        if (dstModTime > srcModTime) {
                            // Conflict: both files modified
                            conflictResolver.resolveConflict(srcFile, dstFile, src, dst)
                        } else {
                            // Source file is newer, copy to destination
                            logger.change("Updating file in $dst: $relPath")
                            FileUtils.copyFile(srcFile, dstFile)
                        }
                    } else {
                        if (srcModTime > dstModTime) {
                            // Conflict: both files modified
                            conflictResolver.resolveConflict(dstFile, srcFile, dst, src)
                        } else {
                            // Destination file is newer, copy to source
                            logger.change("Updating file in $src: $relPath")
                            FileUtils.copyFile(dstFile, srcFile)
                        }
                    }
                }
            } else {
                // File doesn't exist in destination, copy it
                logger.change("Creating file in $dst: $relPath")
                FileUtils.copyFile(srcFile, dstFile)
            }
        }
    }
    
    /**
     * Handles files that have been deleted in one directory but still exist in the other.
     *
     * @param src The source directory
     * @param dst The destination directory
     */
    private fun handleDeletedFiles(src: Path, dst: Path) {
        logger.info("Checking for deleted files in $dst")
        
        // Find all files in destination directory
        val dstFiles = FileUtils.findFiles(dst, config.ignorePatterns)
        
        for (dstFile in dstFiles) {
            // Get relative path
            val relPath = dst.relativize(dstFile)
            
            // Skip if the file is in a hidden directory
            if (FileUtils.isHidden(relPath)) {
                continue
            }
            
            // Skip if the file matches any ignore pattern
            if (FileUtils.isIgnored(relPath, config.ignorePatterns)) {
                if (config.logIgnoredFiles) {
                    logger.info("Ignoring file: $relPath")
                }
                continue
            }
            
            // Check if file exists in source
            val srcFile = src.resolve(relPath)
            if (!srcFile.exists() || !srcFile.isRegularFile()) {
                conflictResolver.handleDeletedFile(dstFile, dst, src)
            }
        }
    }
}