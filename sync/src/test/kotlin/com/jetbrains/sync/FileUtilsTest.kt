package com.jetbrains.sync

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.nio.file.Files
import java.nio.file.Path
import kotlin.io.path.createDirectories
import kotlin.io.path.createFile
import kotlin.io.path.writeText

class FileUtilsTest {
    
    @Test
    fun `isIgnored should return false when ignore patterns is empty`() {
        val filePath = Path.of("test.txt")
        val ignorePatterns = emptyList<String>()
        
        assertFalse(FileUtils.isIgnored(filePath, ignorePatterns))
    }
    
    @Test
    fun `isIgnored should return true when file matches exact pattern`() {
        val filePath = Path.of("test.txt")
        val ignorePatterns = listOf("test.txt")
        
        assertTrue(FileUtils.isIgnored(filePath, ignorePatterns))
    }
    
    @Test
    fun `isIgnored should return true when file matches wildcard pattern`() {
        val filePath = Path.of("test.txt")
        val ignorePatterns = listOf("*.txt")
        
        assertTrue(FileUtils.isIgnored(filePath, ignorePatterns))
    }
    
    @Test
    fun `isIgnored should return true when file is in ignored directory`() {
        val filePath = Path.of("build/test.txt")
        val ignorePatterns = listOf("build/")
        
        assertTrue(FileUtils.isIgnored(filePath, ignorePatterns))
    }
    
    @Test
    fun `isIgnored should return false when file doesn't match any pattern`() {
        val filePath = Path.of("test.txt")
        val ignorePatterns = listOf("*.log", "build/", "temp.txt")
        
        assertFalse(FileUtils.isIgnored(filePath, ignorePatterns))
    }
    
    @Test
    fun `isIgnored should handle multiple patterns correctly`() {
        val filePath = Path.of("test.txt")
        val ignorePatterns = listOf("*.log", "*.txt", "build/")
        
        assertTrue(FileUtils.isIgnored(filePath, ignorePatterns))
    }
    
    @Test
    fun `isIgnored should handle nested directories correctly`() {
        val filePath = Path.of("build/nested/test.txt")
        val ignorePatterns = listOf("build/")
        
        assertTrue(FileUtils.isIgnored(filePath, ignorePatterns))
    }
    
    @Test
    fun `checkDirectory should create directory if it doesn't exist`(@TempDir tempDir: Path) {
        val logger = MockLogger()
        val dirPath = tempDir.resolve("newdir")
        
        assertFalse(Files.exists(dirPath))
        
        val result = FileUtils.checkDirectory(dirPath, logger)
        
        assertTrue(Files.exists(dirPath))
        assertTrue(Files.isDirectory(dirPath))
        assertEquals(dirPath, result)
    }
    
    @Test
    fun `showDiff should return diff between two files`(@TempDir tempDir: Path) {
        val file1 = tempDir.resolve("file1.txt").createFile()
        val file2 = tempDir.resolve("file2.txt").createFile()
        
        file1.writeText("Line 1\nLine 2\nLine 3\n")
        file2.writeText("Line 1\nLine 2 modified\nLine 3\n")
        
        val diff = FileUtils.showDiff(file1, file2)
        
        assertTrue(diff.contains("Line 2"))
        assertTrue(diff.contains("Line 2 modified"))
    }
    
    @Test
    fun `copyFile should copy file from source to destination`(@TempDir tempDir: Path) {
        val sourceFile = tempDir.resolve("source.txt").createFile()
        val destFile = tempDir.resolve("dest.txt")
        
        sourceFile.writeText("Test content")
        
        FileUtils.copyFile(sourceFile, destFile)
        
        assertTrue(Files.exists(destFile))
        assertEquals("Test content", Files.readString(destFile))
    }
    
    @Test
    fun `copyFile should create parent directories if they don't exist`(@TempDir tempDir: Path) {
        val sourceFile = tempDir.resolve("source.txt").createFile()
        val destFile = tempDir.resolve("nested/deep/dest.txt")
        
        sourceFile.writeText("Test content")
        
        FileUtils.copyFile(sourceFile, destFile)
        
        assertTrue(Files.exists(destFile))
        assertEquals("Test content", Files.readString(destFile))
    }
    
    @Test
    fun `findFiles should return all files in directory`(@TempDir tempDir: Path) {
        val file1 = tempDir.resolve("file1.txt").createFile()
        val file2 = tempDir.resolve("file2.txt").createFile()
        val nestedDir = tempDir.resolve("nested").createDirectories()
        val file3 = nestedDir.resolve("file3.txt").createFile()
        
        val files = FileUtils.findFiles(tempDir, emptyList())
        
        assertEquals(3, files.size)
        assertTrue(files.contains(file1))
        assertTrue(files.contains(file2))
        assertTrue(files.contains(file3))
    }
    
    @Test
    fun `findFiles should ignore hidden files and directories`(@TempDir tempDir: Path) {
        val file1 = tempDir.resolve("file1.txt").createFile()
        val hiddenFile = tempDir.resolve(".hidden.txt").createFile()
        val hiddenDir = tempDir.resolve(".hiddendir").createDirectories()
        val fileInHiddenDir = hiddenDir.resolve("file2.txt").createFile()
        
        val files = FileUtils.findFiles(tempDir, emptyList())
        
        assertEquals(1, files.size)
        assertTrue(files.contains(file1))
        assertFalse(files.contains(hiddenFile))
        assertFalse(files.contains(fileInHiddenDir))
    }
    
    @Test
    fun `findFiles should ignore files matching ignore patterns`(@TempDir tempDir: Path) {
        val file1 = tempDir.resolve("file1.txt").createFile()
        val file2 = tempDir.resolve("file2.log").createFile()
        val buildDir = tempDir.resolve("build").createDirectories()
        val fileInBuildDir = buildDir.resolve("file3.txt").createFile()
        
        val ignorePatterns = listOf("*.log", "build/")
        val files = FileUtils.findFiles(tempDir, ignorePatterns)
        
        assertEquals(1, files.size)
        assertTrue(files.contains(file1))
        assertFalse(files.contains(file2))
        assertFalse(files.contains(fileInBuildDir))
    }
    
    // Mock logger for testing
    private class MockLogger : Logger(Configuration()) {
        override fun info(message: String) {}
        override fun warning(message: String) {}
        override fun error(message: String) {}
        override fun change(message: String) {}
    }
}