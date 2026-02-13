package com.jetbrains.sync

import java.io.File
import java.nio.file.Path
import java.nio.file.Paths
import java.util.Properties

/**
 * Configuration for the directory synchronization.
 */
data class Configuration(
    val dir1: Path? = null,
    val dir2: Path? = null,
    val ignorePatterns: List<String> = emptyList(),
    val monitorMode: Boolean = false,
    val interval: Int = 10,
    val logIgnoredFiles: Boolean = false
)

/**
 * Manages configuration loading and validation.
 */
object ConfigurationManager {
    /**
     * Reads configuration from a file.
     *
     * @param file The configuration file
     * @return The configuration
     */
    fun readFromFile(file: File): Configuration {
        val properties = Properties()
        file.inputStream().use { properties.load(it) }
        
        val dir1 = properties.getProperty("DIR1")?.let { Paths.get(it) }
        val dir2 = properties.getProperty("DIR2")?.let { Paths.get(it) }
        val ignorePatterns = properties.getProperty("IGNORE")
            ?.split(",")
            ?.map { it.trim() }
            ?: emptyList()
        val monitorMode = properties.getProperty("MONITOR")?.equals("true", ignoreCase = true) ?: false
        val interval = properties.getProperty("INTERVAL")?.toIntOrNull() ?: 10
        val logIgnoredFiles = properties.getProperty("LOG_IGNORED_FILES")?.equals("true", ignoreCase = true) ?: false
        
        return Configuration(
            dir1 = dir1,
            dir2 = dir2,
            ignorePatterns = ignorePatterns,
            monitorMode = monitorMode,
            interval = interval,
            logIgnoredFiles = logIgnoredFiles
        )
    }
    
    /**
     * Writes configuration to a file.
     *
     * @param config The configuration
     * @param file The configuration file
     */
    fun writeToFile(config: Configuration, file: File) {
        val properties = Properties()
        
        config.dir1?.let { properties.setProperty("DIR1", it.toString()) }
        config.dir2?.let { properties.setProperty("DIR2", it.toString()) }
        if (config.ignorePatterns.isNotEmpty()) {
            properties.setProperty("IGNORE", config.ignorePatterns.joinToString(","))
        }
        properties.setProperty("MONITOR", config.monitorMode.toString())
        properties.setProperty("INTERVAL", config.interval.toString())
        properties.setProperty("LOG_IGNORED_FILES", config.logIgnoredFiles.toString())
        
        file.outputStream().use { properties.store(it, "Sync-dirs configuration") }
    }
}