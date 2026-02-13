package com.jetbrains.sync

import io.mockk.*
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.nio.file.Files
import java.nio.file.Path
import kotlin.io.path.createDirectories
import kotlin.io.path.createFile
import kotlin.io.path.exists
import kotlin.io.path.writeText

class DirectorySynchronizerTest {
    
    @TempDir
    lateinit var tempDir: Path
    
    private lateinit var dir1: Path
    private lateinit var dir2: Path
    private lateinit var config: Configuration
    private lateinit var synchronizer: DirectorySynchronizer
    
    @BeforeEach
    fun setUp() {
        dir1 = tempDir.resolve("dir1").createDirectories()
        dir2 = tempDir.resolve("dir2").createDirectories()
        
        config = Configuration(
            dir1 = dir1,
            dir2 = dir2,
            ignorePatterns = listOf("*.tmp", "*.log", "build/"),
            monitorMode = false,
            interval = 10,
            logIgnoredFiles = false
        )
        
        // Create a mock ConflictResolver that always chooses option 1 (use file from source)
        val mockConflictResolver = mockk<ConflictResolver>()
        every { mockConflictResolver.resolveConflict(any(), any(), any(), any()) } returns true
        every { mockConflictResolver.handleDeletedFile(any(), any(), any()) } returns true
        
        // Create a DirectorySynchronizer with the mock ConflictResolver
        synchronizer = spyk(DirectorySynchronizer(config)) {
            every { conflictResolver } returns mockConflictResolver
        }
    }
    
    @Test
    fun `synchronize should copy files from dir1 to dir2`() {
        // Create a file in dir1
        val file1 = dir1.resolve("file1.txt").createFile()
        file1.writeText("Content of file1")
        
        // Synchronize
        synchronizer.synchronize()
        
        // Check that the file was copied to dir2
        val file2 = dir2.resolve("file1.txt")
        assertTrue(file2.exists())
        assertEquals("Content of file1", Files.readString(file2))
    }
    
    @Test
    fun `synchronize should copy files from dir2 to dir1`() {
        // Create a file in dir2
        val file2 = dir2.resolve("file2.txt").createFile()
        file2.writeText("Content of file2")
        
        // Synchronize
        synchronizer.synchronize()
        
        // Check that the file was copied to dir1
        val file1 = dir1.resolve("file2.txt")
        assertTrue(file1.exists())
        assertEquals("Content of file2", Files.readString(file1))
    }
    
    @Test
    fun `synchronize should ignore files matching ignore patterns`() {
        // Create files in dir1
        val file1 = dir1.resolve("file1.txt").createFile()
        file1.writeText("Content of file1")
        
        val tempFile = dir1.resolve("temp.tmp").createFile()
        tempFile.writeText("Temporary file")
        
        val logFile = dir1.resolve("app.log").createFile()
        logFile.writeText("Log file")
        
        val buildDir = dir1.resolve("build").createDirectories()
        val buildFile = buildDir.resolve("build.txt").createFile()
        buildFile.writeText("Build file")
        
        // Synchronize
        synchronizer.synchronize()
        
        // Check that only the non-ignored file was copied to dir2
        assertTrue(dir2.resolve("file1.txt").exists())
        assertFalse(dir2.resolve("temp.tmp").exists())
        assertFalse(dir2.resolve("app.log").exists())
        assertFalse(dir2.resolve("build").exists())
    }
    
    @Test
    fun `synchronize should handle nested directories`() {
        // Create nested directories and files in dir1
        val nestedDir = dir1.resolve("nested").createDirectories()
        val nestedFile = nestedDir.resolve("nested.txt").createFile()
        nestedFile.writeText("Nested file")
        
        val deepDir = nestedDir.resolve("deep").createDirectories()
        val deepFile = deepDir.resolve("deep.txt").createFile()
        deepFile.writeText("Deep file")
        
        // Synchronize
        synchronizer.synchronize()
        
        // Check that the nested directories and files were copied to dir2
        assertTrue(dir2.resolve("nested").exists())
        assertTrue(dir2.resolve("nested/nested.txt").exists())
        assertEquals("Nested file", Files.readString(dir2.resolve("nested/nested.txt")))
        
        assertTrue(dir2.resolve("nested/deep").exists())
        assertTrue(dir2.resolve("nested/deep/deep.txt").exists())
        assertEquals("Deep file", Files.readString(dir2.resolve("nested/deep/deep.txt")))
    }
    
    @Test
    fun `synchronize should update modified files`() {
        // Create a file in both directories with different content
        val file1 = dir1.resolve("file.txt").createFile()
        file1.writeText("Original content")
        
        val file2 = dir2.resolve("file.txt").createFile()
        file2.writeText("Modified content")
        
        // Set the modification time of file1 to be newer than file2
        Files.setLastModifiedTime(file1, Files.getLastModifiedTime(file2).plusSeconds(1))
        
        // Synchronize
        synchronizer.synchronize()
        
        // Check that file2 was updated with the content of file1
        assertEquals("Original content", Files.readString(file2))
    }
    
    @Test
    fun `synchronize should handle deleted files`() {
        // Create a file in dir2 that doesn't exist in dir1
        val file2 = dir2.resolve("deleted.txt").createFile()
        file2.writeText("This file will be deleted")
        
        // Synchronize
        synchronizer.synchronize()
        
        // Check that the file was handled (in this case, deleted from dir2)
        verify { synchronizer.conflictResolver.handleDeletedFile(file2, dir2, dir1) }
    }
    
    @Test
    fun `synchronize should handle conflicts`() {
        // Create a file in both directories with different content
        val file1 = dir1.resolve("conflict.txt").createFile()
        file1.writeText("Content from dir1")
        
        val file2 = dir2.resolve("conflict.txt").createFile()
        file2.writeText("Content from dir2")
        
        // Set the modification times to simulate a conflict
        val modTime = Files.getLastModifiedTime(file1)
        Files.setLastModifiedTime(file1, modTime)
        Files.setLastModifiedTime(file2, modTime.plusSeconds(1))
        
        // Synchronize
        synchronizer.synchronize()
        
        // Check that the conflict was resolved
        verify { synchronizer.conflictResolver.resolveConflict(file1, file2, dir1, dir2) }
    }
}