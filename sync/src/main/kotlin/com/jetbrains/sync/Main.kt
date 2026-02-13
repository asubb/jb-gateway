package com.jetbrains.sync

import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.ajalt.clikt.parameters.arguments.optional
import com.github.ajalt.clikt.parameters.options.*
import com.github.ajalt.clikt.parameters.types.file
import com.github.ajalt.clikt.parameters.types.int
import kotlinx.coroutines.*
import org.slf4j.LoggerFactory
import java.io.File
import java.nio.file.Path
import kotlin.io.path.Path

/**
 * Main entry point for the sync-dirs application.
 * This application synchronizes two directories bidirectionally.
 */
fun main(args: Array<String>) {
    SyncDirsCommand().main(args)
}

/**
 * Command-line interface for the sync-dirs application.
 */
class SyncDirsCommand : CliktCommand(
    name = "sync-dirs",
    help = "Synchronizes two directories bidirectionally. If there is a conflict, it will prompt the user and show the diff."
) {
    private val logger = LoggerFactory.getLogger(SyncDirsCommand::class.java)
    
    private val dir1 by argument().optional()
    private val dir2 by argument().optional()
    
    private val configFile by option("-c", "--config")
        .file(mustExist = true, canBeDir = false)
        .help("Use configuration file instead of command line arguments")
    
    private val monitorMode by option("-m", "--monitor")
        .flag()
        .help("Run in monitoring mode, continuously watching for changes")
    
    private val interval by option("-i", "--interval")
        .int()
        .default(10)
        .help("Set the interval between checks in monitoring mode (default: 10 seconds)")
    
    private val ignorePatterns by option("-g", "--ignore")
        .help("Comma-separated list of glob patterns to ignore (e.g., '*.tmp,*.log,build/')")
    
    private val logIgnored by option("-l", "--log-ignored")
        .flag()
        .help("Log ignored files (default: off)")
    
    override fun run() {
        // Initialize configuration
        val config = if (configFile != null) {
            ConfigurationManager.readFromFile(configFile!!)
        } else {
            Configuration(
                dir1 = dir1?.let { Path(it) },
                dir2 = dir2?.let { Path(it) },
                ignorePatterns = ignorePatterns?.split(",")?.map { it.trim() } ?: emptyList(),
                monitorMode = monitorMode,
                interval = interval,
                logIgnoredFiles = logIgnored
            )
        }
        
        // Validate configuration
        if (config.dir1 == null || config.dir2 == null) {
            logger.error("Both directories must be specified either as arguments or in the configuration file")
            echo("Error: Both directories must be specified either as arguments or in the configuration file", err = true)
            return
        }
        
        // Create synchronizer
        val synchronizer = DirectorySynchronizer(config)
        
        // Set up signal handler for Ctrl+C
        Runtime.getRuntime().addShutdownHook(Thread {
            logger.info("Synchronization stopped by user")
            echo("Synchronization stopped by user")
        })
        
        // Start synchronization
        if (config.monitorMode) {
            logger.info("Starting monitoring mode with interval of ${config.interval} seconds")
            echo("Starting monitoring mode with interval of ${config.interval} seconds")
            echo("Press Ctrl+C to stop monitoring")
            
            runBlocking {
                while (true) {
                    synchronizer.synchronize()
                    logger.info("Waiting ${config.interval} seconds before next check...")
                    echo("Waiting ${config.interval} seconds before next check...")
                    delay(config.interval * 1000L)
                }
            }
        } else {
            synchronizer.synchronize()
        }
    }
}