package com.jetbrains.sync

import org.slf4j.LoggerFactory
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

/**
 * Logger for the sync-dirs application.
 * Logs messages to both file and console with color-coded output.
 */
class Logger(private val config: Configuration) {
    companion object {
        private val logger = LoggerFactory.getLogger(Logger::class.java)
        
        // ANSI color codes
        const val RESET = "\u001B[0m"
        const val RED = "\u001B[31m"
        const val GREEN = "\u001B[32m"
        const val YELLOW = "\u001B[33m"
        const val BLUE = "\u001B[34m"
        
        // Log directory
        private val LOG_DIR = Paths.get(System.getProperty("user.home"), ".sync-dirs")
        
        // Date formatters
        private val FILE_DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")
        private val LOG_DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
    }
    
    // Log file
    private val logFile: Path
    
    init {
        // Create log directory if it doesn't exist
        if (!Files.exists(LOG_DIR)) {
            Files.createDirectories(LOG_DIR)
        }
        
        // Create log file
        val timestamp = LocalDateTime.now().format(FILE_DATE_FORMATTER)
        logFile = LOG_DIR.resolve("sync_$timestamp.log")
        Files.createFile(logFile)
        
        // Log initial message
        info("Log file: $logFile")
    }
    
    /**
     * Logs an informational message.
     */
    fun info(message: String) {
        log("INFO", message, GREEN)
    }
    
    /**
     * Logs a warning message.
     */
    fun warning(message: String) {
        log("WARNING", message, YELLOW)
    }
    
    /**
     * Logs an error message.
     */
    fun error(message: String) {
        log("ERROR", message, RED)
    }
    
    /**
     * Logs a change message.
     */
    fun change(message: String) {
        log("CHANGE", message, BLUE)
    }
    
    /**
     * Logs a message with the specified level and color.
     */
    private fun log(level: String, message: String, color: String) {
        val timestamp = LocalDateTime.now().format(LOG_DATE_FORMATTER)
        val logMessage = "[$timestamp] [$level] $message"
        
        // Log to file
        Files.write(logFile, listOf(logMessage), java.nio.file.StandardOpenOption.APPEND)
        
        // Log to console with color
        println("$color$logMessage$RESET")
        
        // Log to SLF4J
        when (level) {
            "INFO" -> logger.info(message)
            "WARNING" -> logger.warn(message)
            "ERROR" -> logger.error(message)
            "CHANGE" -> logger.info("CHANGE: $message")
            else -> logger.info("$level: $message")
        }
    }
    
    /**
     * Returns the path to the log file.
     */
    fun getLogFile(): Path {
        return logFile
    }
}