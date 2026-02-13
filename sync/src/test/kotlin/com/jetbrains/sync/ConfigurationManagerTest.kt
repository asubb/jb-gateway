package com.jetbrains.sync

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.nio.file.Path
import kotlin.io.path.createFile
import kotlin.io.path.writeText

class ConfigurationManagerTest {
    
    @Test
    fun `readFromFile should read configuration from file`(@TempDir tempDir: Path) {
        val configFile = tempDir.resolve("config.properties").createFile()
        configFile.writeText("""
            # Test configuration
            DIR1=/path/to/dir1
            DIR2=/path/to/dir2
            IGNORE=*.tmp,*.log,build/
            MONITOR=true
            INTERVAL=30
            LOG_IGNORED_FILES=true
        """.trimIndent())
        
        val config = ConfigurationManager.readFromFile(configFile.toFile())
        
        assertEquals("/path/to/dir1", config.dir1.toString())
        assertEquals("/path/to/dir2", config.dir2.toString())
        assertEquals(listOf("*.tmp", "*.log", "build/"), config.ignorePatterns)
        assertTrue(config.monitorMode)
        assertEquals(30, config.interval)
        assertTrue(config.logIgnoredFiles)
    }
    
    @Test
    fun `readFromFile should handle missing optional properties`(@TempDir tempDir: Path) {
        val configFile = tempDir.resolve("config.properties").createFile()
        configFile.writeText("""
            # Test configuration with only required properties
            DIR1=/path/to/dir1
            DIR2=/path/to/dir2
        """.trimIndent())
        
        val config = ConfigurationManager.readFromFile(configFile.toFile())
        
        assertEquals("/path/to/dir1", config.dir1.toString())
        assertEquals("/path/to/dir2", config.dir2.toString())
        assertEquals(emptyList<String>(), config.ignorePatterns)
        assertFalse(config.monitorMode)
        assertEquals(10, config.interval)
        assertFalse(config.logIgnoredFiles)
    }
    
    @Test
    fun `readFromFile should handle comments and empty lines`(@TempDir tempDir: Path) {
        val configFile = tempDir.resolve("config.properties").createFile()
        configFile.writeText("""
            # Test configuration
            
            # Directory paths
            DIR1=/path/to/dir1
            
            # Second directory
            DIR2=/path/to/dir2
            
            # Ignore patterns
            IGNORE=*.tmp,*.log,build/
        """.trimIndent())
        
        val config = ConfigurationManager.readFromFile(configFile.toFile())
        
        assertEquals("/path/to/dir1", config.dir1.toString())
        assertEquals("/path/to/dir2", config.dir2.toString())
        assertEquals(listOf("*.tmp", "*.log", "build/"), config.ignorePatterns)
    }
    
    @Test
    fun `writeToFile should write configuration to file`(@TempDir tempDir: Path) {
        val configFile = tempDir.resolve("config.properties").toFile()
        
        val config = Configuration(
            dir1 = Path.of("/path/to/dir1"),
            dir2 = Path.of("/path/to/dir2"),
            ignorePatterns = listOf("*.tmp", "*.log", "build/"),
            monitorMode = true,
            interval = 30,
            logIgnoredFiles = true
        )
        
        ConfigurationManager.writeToFile(config, configFile)
        
        val content = configFile.readText()
        
        assertTrue(content.contains("DIR1=/path/to/dir1"))
        assertTrue(content.contains("DIR2=/path/to/dir2"))
        assertTrue(content.contains("IGNORE=*.tmp,*.log,build/"))
        assertTrue(content.contains("MONITOR=true"))
        assertTrue(content.contains("INTERVAL=30"))
        assertTrue(content.contains("LOG_IGNORED_FILES=true"))
    }
    
    @Test
    fun `writeToFile should handle null directories`(@TempDir tempDir: Path) {
        val configFile = tempDir.resolve("config.properties").toFile()
        
        val config = Configuration(
            dir1 = null,
            dir2 = null,
            ignorePatterns = listOf("*.tmp", "*.log", "build/"),
            monitorMode = true,
            interval = 30,
            logIgnoredFiles = true
        )
        
        ConfigurationManager.writeToFile(config, configFile)
        
        val content = configFile.readText()
        
        assertFalse(content.contains("DIR1="))
        assertFalse(content.contains("DIR2="))
        assertTrue(content.contains("IGNORE=*.tmp,*.log,build/"))
        assertTrue(content.contains("MONITOR=true"))
        assertTrue(content.contains("INTERVAL=30"))
        assertTrue(content.contains("LOG_IGNORED_FILES=true"))
    }
    
    @Test
    fun `writeToFile should handle empty ignore patterns`(@TempDir tempDir: Path) {
        val configFile = tempDir.resolve("config.properties").toFile()
        
        val config = Configuration(
            dir1 = Path.of("/path/to/dir1"),
            dir2 = Path.of("/path/to/dir2"),
            ignorePatterns = emptyList(),
            monitorMode = true,
            interval = 30,
            logIgnoredFiles = true
        )
        
        ConfigurationManager.writeToFile(config, configFile)
        
        val content = configFile.readText()
        
        assertTrue(content.contains("DIR1=/path/to/dir1"))
        assertTrue(content.contains("DIR2=/path/to/dir2"))
        assertFalse(content.contains("IGNORE="))
        assertTrue(content.contains("MONITOR=true"))
        assertTrue(content.contains("INTERVAL=30"))
        assertTrue(content.contains("LOG_IGNORED_FILES=true"))
    }
}