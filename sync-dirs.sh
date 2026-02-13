#!/bin/bash

# sync-dirs.sh - Bidirectional directory synchronization script
# 
# This script synchronizes two directories bidirectionally, logging all changes.
# If there is a conflict, it will prompt the user and show the diff.
# It can also run in monitoring mode, continuously watching for changes.
#
# Usage: ./sync-dirs.sh [options] <dir1> <dir2>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_DIR="$HOME/.sync-dirs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/sync_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    # Log to console with colors
    case "$level" in
        "INFO")
            echo -e "${GREEN}[$timestamp] [$level] $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}[$timestamp] [$level] $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}[$timestamp] [$level] $message${NC}"
            ;;
        "CHANGE")
            echo -e "${BLUE}[$timestamp] [$level] $message${NC}"
            ;;
        *)
            echo -e "[$timestamp] [$level] $message"
            ;;
    esac
}

# Function to show help
show_help() {
    echo "Usage: $0 [options] <dir1> <dir2>"
    echo "   or: $0 --config <config_file>"
    echo ""
    echo "Synchronizes two directories bidirectionally."
    echo "If there is a conflict, it will prompt the user and show the diff."
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -m, --monitor           Run in monitoring mode, continuously watching for changes"
    echo "  -i, --interval SECONDS  Set the interval between checks in monitoring mode (default: 10)"
    echo "  -c, --config FILE       Use configuration file instead of command line arguments"
    echo "  -g, --ignore PATTERNS   Comma-separated list of glob patterns to ignore (e.g., '*.tmp,*.log,build/')"
    echo "  -l, --log-ignored       Log ignored files (default: off)"
    echo ""
    echo "Examples:"
    echo "  $0 ~/projects/local ~/projects/remote"
    echo "  $0 --monitor --interval 30 ~/projects/local ~/projects/remote"
    echo "  $0 --config sync-dirs.conf"
    echo "  $0 --ignore '*.tmp,build/' ~/projects/local ~/projects/remote"
}

# Function to check if a directory exists and create it if it doesn't
check_dir() {
    if [ ! -d "$1" ]; then
        log "WARNING" "Directory does not exist: $1"
        log "INFO" "Creating directory: $1"
        mkdir -p "$1"
    fi
}

# Function to show diff between two files
show_diff() {
    local file1="$1"
    local file2="$2"

    if command -v colordiff &> /dev/null; then
        colordiff -u "$file1" "$file2"
    else
        diff -u "$file1" "$file2"
    fi
}

# Function to resolve conflict
resolve_conflict() {
    local src="$1"
    local dst="$2"
    local rel_path="$3"

    log "WARNING" "Conflict detected for file: $rel_path"
    echo ""
    echo "File has been modified in both directories:"
    echo "1: $src/$rel_path"
    echo "2: $dst/$rel_path"
    echo ""

    # Show diff
    echo "Diff between the files:"
    show_diff "$src/$rel_path" "$dst/$rel_path"
    echo ""

    # Ask user what to do
    while true; do
        echo -e "${YELLOW}How do you want to resolve this conflict?${NC}"
        echo "1) Use file from $src"
        echo "2) Use file from $dst"
        echo "3) Skip this file"
        echo "4) Show diff again"
        echo "q) Quit synchronization"
        read -p "Enter your choice [1/2/3/4/q]: " choice

        case "$choice" in
            1)
                log "CHANGE" "Using file from $src: $rel_path"
                cp -pR "$src/$rel_path" "$dst/$rel_path" 2>/dev/null || cp "$src/$rel_path" "$dst/$rel_path"
                return 0
                ;;
            2)
                log "CHANGE" "Using file from $dst: $rel_path"
                cp -pR "$dst/$rel_path" "$src/$rel_path" 2>/dev/null || cp "$dst/$rel_path" "$src/$rel_path"
                return 0
                ;;
            3)
                log "INFO" "Skipping file: $rel_path"
                return 1
                ;;
            4)
                echo "Diff between the files:"
                show_diff "$src/$rel_path" "$dst/$rel_path"
                echo ""
                ;;
            q|Q)
                log "INFO" "Synchronization aborted by user"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                ;;
        esac
    done
}

# Function to synchronize files from src to dst
sync_files() {
    local src="$1"
    local dst="$2"
    local direction="$3"

    log "INFO" "Synchronizing files from $src to $dst"

    # Find all files in source directory
    # Using process substitution instead of pipe to avoid subshell issues with read
    while read -r src_file; do
        # Get relative path
        rel_path="${src_file#$src/}"

        # Skip if the file is in a hidden directory
        if [[ "$rel_path" == .* ]]; then
            continue
        fi

        # Skip if the file matches any ignore pattern
        if is_ignored "$rel_path"; then
            if [ "$LOG_IGNORED_FILES" = true ]; then
                log "INFO" "Ignoring file: $rel_path"
            fi
            continue
        fi

        # Check if destination file exists
        if [ -f "$dst/$rel_path" ]; then
            # Check if files are different
            if ! cmp -s "$src_file" "$dst/$rel_path"; then
                # Check if destination file is newer
                src_mod_time=$(stat -c %Y "$src_file" 2>/dev/null || stat -f %m "$src_file")
                dst_mod_time=$(stat -c %Y "$dst/$rel_path" 2>/dev/null || stat -f %m "$dst/$rel_path")

                if [ "$direction" == "forward" ]; then
                    if [ "$dst_mod_time" -gt "$src_mod_time" ]; then
                        # Conflict: both files modified
                        resolve_conflict "$src" "$dst" "$rel_path"
                    else
                        # Source file is newer, copy to destination
                        log "CHANGE" "Updating file in $dst: $rel_path"
                        mkdir -p "$(dirname "$dst/$rel_path")"
                        cp -pR "$src_file" "$dst/$rel_path" 2>/dev/null || cp "$src_file" "$dst/$rel_path"
                    fi
                else
                    if [ "$src_mod_time" -gt "$dst_mod_time" ]; then
                        # Conflict: both files modified
                        resolve_conflict "$dst" "$src" "$rel_path"
                    else
                        # Destination file is newer, copy to source
                        log "CHANGE" "Updating file in $src: $rel_path"
                        mkdir -p "$(dirname "$src/$rel_path")"
                        cp -pR "$dst/$rel_path" "$src_file" 2>/dev/null || cp "$dst/$rel_path" "$src_file"
                    fi
                fi
            fi
        else
            # File doesn't exist in destination, copy it
            log "CHANGE" "Creating file in $dst: $rel_path"
            mkdir -p "$(dirname "$dst/$rel_path")"
            cp -pR "$src_file" "$dst/$rel_path" 2>/dev/null || cp "$src_file" "$dst/$rel_path"
        fi
    done < <(find "$src" -type f -not -path "*/\.*")
}

# Function to handle deleted files
handle_deleted_files() {
    local src="$1"
    local dst="$2"

    log "INFO" "Checking for deleted files in $dst"

    # Find files in dst that don't exist in src
    # Using process substitution instead of pipe to avoid subshell issues with read
    while read -r dst_file; do
        # Get relative path
        rel_path="${dst_file#$dst/}"

        # Skip if the file is in a hidden directory
        if [[ "$rel_path" == .* ]]; then
            continue
        fi

        # Skip if the file matches any ignore pattern
        if is_ignored "$rel_path"; then
            if [ "$LOG_IGNORED_FILES" = true ]; then
                log "INFO" "Ignoring file: $rel_path"
            fi
            continue
        fi

        # Check if file exists in source
        if [ ! -f "$src/$rel_path" ]; then
            echo -e "${YELLOW}File exists in $dst but not in $src: $rel_path${NC}"
            echo "What would you like to do?"
            echo "1) Delete from $dst"
            echo "2) Restore to $src"
            echo "3) Skip this file"
            read -p "Enter your choice [1/2/3]: " choice

            case "$choice" in
                1)
                    log "CHANGE" "Deleting file from $dst: $rel_path"
                    rm "$dst_file"
                    ;;
                2)
                    log "CHANGE" "Restoring file to $src: $rel_path"
                    mkdir -p "$(dirname "$src/$rel_path")"
                    cp -pR "$dst_file" "$src/$rel_path" 2>/dev/null || cp "$dst_file" "$src/$rel_path"
                    ;;
                3)
                    log "INFO" "Skipping file: $rel_path"
                    ;;
                *)
                    log "WARNING" "Invalid choice, skipping file: $rel_path"
                    ;;
            esac
        fi
    done < <(find "$dst" -type f -not -path "*/\.*")
}

# Function to synchronize directories
sync_directories() {
    local dir1="$1"
    local dir2="$2"

    # Remove trailing slashes
    dir1="${dir1%/}"
    dir2="${dir2%/}"

    # Check if directories exist
    check_dir "$dir1"
    check_dir "$dir2"

    log "INFO" "Starting bidirectional synchronization"
    log "INFO" "Directory 1: $dir1"
    log "INFO" "Directory 2: $dir2"
    log "INFO" "Log file: $LOG_FILE"

    # Handle deleted files in both directions
    handle_deleted_files "$dir1" "$dir2"
    handle_deleted_files "$dir2" "$dir1"

    # Sync files from dir1 to dir2
    sync_files "$dir1" "$dir2" "forward"

    # Sync files from dir2 to dir1
    sync_files "$dir2" "$dir1" "backward"


    log "INFO" "Synchronization completed successfully"
    echo -e "${GREEN}Synchronization completed successfully${NC}"
    echo "Log file: $LOG_FILE"
}

# Default values
MONITOR_MODE=false
INTERVAL=10
IGNORE_PATTERNS=""
CONFIG_FILE=""
LOG_IGNORED_FILES=false

# Function to read configuration file
read_config_file() {
    local config_file="$1"

    if [ ! -f "$config_file" ]; then
        log "ERROR" "Configuration file not found: $config_file"
        exit 1
    fi

    log "INFO" "Reading configuration from $config_file"

    # Read configuration file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^[[:space:]]*$ ]]; then
            continue
        fi

        # Parse key-value pairs
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"

            # Remove leading and trailing whitespace
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)

            case "$key" in
                DIR1)
                    dir1="$value"
                    ;;
                DIR2)
                    dir2="$value"
                    ;;
                IGNORE)
                    IGNORE_PATTERNS="$value"
                    ;;
                MONITOR)
                    if [[ "$value" == "true" ]]; then
                        MONITOR_MODE=true
                    else
                        MONITOR_MODE=false
                    fi
                    ;;
                INTERVAL)
                    INTERVAL="$value"
                    ;;
                LOG_IGNORED_FILES)
                    if [[ "$value" == "true" ]]; then
                        LOG_IGNORED_FILES=true
                    else
                        LOG_IGNORED_FILES=false
                    fi
                    ;;
                *)
                    log "WARNING" "Unknown configuration option: $key"
                    ;;
            esac
        fi
    done < "$config_file"

    # Validate required configuration options
    if [ -z "$dir1" ] || [ -z "$dir2" ]; then
        log "ERROR" "DIR1 and DIR2 must be specified in the configuration file"
        exit 1
    fi
}

# Function to check if a file matches any ignore pattern
is_ignored() {
    local file_path="$1"

    if [ -z "$IGNORE_PATTERNS" ]; then
        return 1  # Not ignored
    fi

    # Split ignore patterns by comma
    IFS=',' read -ra patterns <<< "$IGNORE_PATTERNS"

    for pattern in "${patterns[@]}"; do
        # Trim whitespace
        pattern=$(echo "$pattern" | xargs)

        # Check if pattern ends with / (directory pattern)
        if [[ "$pattern" == */ ]]; then
            # Remove trailing slash for comparison
            dir_pattern="${pattern%/}"
            # Check if file path starts with directory pattern followed by / or is exactly the directory pattern
            if [[ "$file_path" == "$dir_pattern"/* ]] || [[ "$file_path" == "$dir_pattern" ]]; then
                return 0  # Ignored
            fi
        # Check if file matches pattern
        elif [[ "$file_path" == $pattern ]]; then
            return 0  # Ignored
        fi
    done

    return 1  # Not ignored
}

# Function to handle SIGINT (Ctrl+C)
function cleanup {
    echo ""
    log "INFO" "Monitoring stopped by user"
    exit 0
}

# Parse command line arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--monitor)
            MONITOR_MODE=true
            shift
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -g|--ignore)
            IGNORE_PATTERNS="$2"
            shift 2
            ;;
        -l|--log-ignored)
            LOG_IGNORED_FILES=true
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# If config file is specified, read it
if [ -n "$CONFIG_FILE" ]; then
    read_config_file "$CONFIG_FILE"
    # Use dir1 and dir2 from config file
    set -- "$dir1" "$dir2"
fi

if [ "$#" -ne 2 ]; then
    log "ERROR" "Exactly two directory paths are required, or use --config option"
    show_help
    exit 1
fi

# Set up trap for SIGINT
trap cleanup SIGINT

# Start synchronization
if [ "$MONITOR_MODE" = true ]; then
    log "INFO" "Starting monitoring mode with interval of $INTERVAL seconds"
    log "INFO" "Press Ctrl+C to stop monitoring"

    while true; do
        sync_directories "$1" "$2"
        log "INFO" "Waiting $INTERVAL seconds before next check..."
        sleep $INTERVAL
    done
else
    sync_directories "$1" "$2"
fi
