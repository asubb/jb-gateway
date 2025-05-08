#!/bin/bash

set -e

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Directory where PID files are stored
PID_DIR="$HOME/.jb-gateway/proxy"

if [ ! -d "$PID_DIR" ]; then
    echo -e "${YELLOW}No proxy tunnels found. Directory $PID_DIR does not exist.${NC}"
    exit 0
fi

# Check if there are any PID files
PID_FILES=$(find "$PID_DIR" -name "proxy_*.pid" 2>/dev/null)

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
    port=$(basename "$pid_file" | sed 's/proxy_\([0-9]*\)\.pid/\1/')

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
