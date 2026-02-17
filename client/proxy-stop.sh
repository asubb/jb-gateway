#!/bin/bash

set -e

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Profile support
PROFILE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --profile NAME    Use profile-specific configuration directory"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            echo "Usage: $0 [--profile NAME]"
            exit 1
            ;;
    esac
done

# Resolve PID directory based on profile
if [[ -n "$PROFILE" ]]; then
    PID_DIR="$HOME/.jb-gateway/profiles/$PROFILE/state"
    PID_PATTERN="tunnel_*.pid"
else
    PID_DIR="$HOME/.jb-gateway/proxy"
    PID_PATTERN="proxy_*.pid"
fi

if [ ! -d "$PID_DIR" ]; then
    echo -e "${YELLOW}No proxy tunnels found. Directory $PID_DIR does not exist.${NC}"
    exit 0
fi

# Check for tunnel monitor and stop it if running
MONITOR_PID_FILE="$PID_DIR/monitor.pid"
if [ -f "$MONITOR_PID_FILE" ]; then
    monitor_pid=$(cat "$MONITOR_PID_FILE")
    if ps -p "$monitor_pid" > /dev/null; then
        echo -e "${GREEN}Stopping tunnel monitor (PID: $monitor_pid)...${NC}"
        kill "$monitor_pid" 2>/dev/null || true
        sleep 1
    else
        echo -e "${YELLOW}Tunnel monitor not running (PID: $monitor_pid)${NC}"
    fi
    rm -f "$MONITOR_PID_FILE"
    echo -e "${GREEN}Tunnel monitor stopped.${NC}"
fi

# Check if there are any PID files
PID_FILES=$(find "$PID_DIR" -name "$PID_PATTERN" 2>/dev/null)

if [ -z "$PID_FILES" ]; then
    echo -e "${YELLOW}No active proxy tunnels found.${NC}"
    exit 0
fi

echo -e "${GREEN}Stopping all proxy tunnels...${NC}"

# Counter for successful terminations
TERMINATED=0

# Process each PID file
for pid_file in $PID_FILES; do
    # Extract port number from filename
    if [[ -n "$PROFILE" ]]; then
        port=$(basename "$pid_file" | sed 's/tunnel_\([0-9]*\)\.pid/\1/')
    else
        port=$(basename "$pid_file" | sed 's/proxy_\([0-9]*\)\.pid/\1/')
    fi

    # Read PID from file
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")

        # Check if process is still running
        if ps -p "$pid" > /dev/null; then
            echo -e "${GREEN}Port $port: Stopping tunnel (PID: $pid)${NC}"
            kill "$pid" 2>/dev/null || true
            TERMINATED=$((TERMINATED + 1))
        else
            echo -e "${YELLOW}Port $port: Tunnel not running (PID: $pid)${NC}"
        fi

        # Remove PID file
        rm -f "$pid_file"
    fi
done

echo -e "${GREEN}Terminated $TERMINATED proxy tunnel(s).${NC}"
echo -e "${GREEN}All proxy tunnels stopped.${NC}"
