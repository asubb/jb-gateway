#!/bin/bash

set -e

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Directory for storing PID files
PID_DIR="$HOME/.jb-gateway/proxy"
mkdir -p "$PID_DIR"

# Directory for storing log files
LOG_DIR="$HOME/.jb-gateway/logs"
mkdir -p "$LOG_DIR"

# Default values
SSH_PORT=1022
SSH_USER="jb-gateway"
SSH_HOST="localhost"
SSH_PASSWORD=""

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "Loading configuration from .env file..."
    source .env

    # Override defaults with values from .env if they exist
    [ ! -z "$SSH_PORT" ] && SSH_PORT="$SSH_PORT"
    [ ! -z "$SSH_USER" ] && SSH_USER="$SSH_USER"
    [ ! -z "$SSH_HOST" ] && SSH_HOST="$SSH_HOST"
    [ ! -z "$SSH_PASSWORD" ] && SSH_PASSWORD="$SSH_PASSWORD"
fi

# Help message
function show_help {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -p, --ports PORTS        Comma-separated list of ports or port ranges to tunnel (e.g., 8080,8081,8082-8085)"
    echo "                           If not provided, will use PROXY_PORTS from .env file"
    echo "  -s, --ssh-port PORT      SSH port for jb-gateway container (default: from .env or 1022)"
    echo "  -u, --user USER          SSH user for jb-gateway container (default: from .env or jb-gateway)"
    echo "  -w, --password PASS      SSH password for jb-gateway container (default: from .env or none)"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Example: $0 -p 8080,8081,8082-8085"
    echo "This will forward multiple ports from localhost to the same ports on the remote host via jb-gateway"
}

# Parse command line arguments
PORTS=""
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -p|--ports)
            PORTS="$2"
            shift 2
            ;;
        -s|--ssh-port)
            SSH_PORT="$2"
            shift 2
            ;;
        -u|--user)
            SSH_USER="$2"
            shift 2
            ;;
        -w|--password)
            SSH_PASSWORD="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# If no ports specified via command line, use the ones from .env
if [ -z "$PORTS" ]; then
    if [ -z "$PROXY_PORTS" ]; then
        echo -e "${RED}Error: No ports specified. Either provide ports with -p option or set PROXY_PORTS in .env file.${NC}"
        exit 1
    else
        PORTS="$PROXY_PORTS"
    fi
fi

# Check if sshpass is installed when password is provided
if [ -n "$SSH_PASSWORD" ]; then
    if ! command -v sshpass &> /dev/null; then
        echo -e "${RED}Error: sshpass is required for password authentication but it's not installed.${NC}"
        echo "Please install sshpass first:"
        echo "  - On Ubuntu/Debian: sudo apt-get install sshpass"
        echo "  - On macOS: brew install hudochenkov/sshpass/sshpass"
        exit 1
    fi
fi

# Function to expand port ranges
expand_port_range() {
    local port_spec="$1"

    # Check if it's a range (contains a hyphen)
    if [[ "$port_spec" == *-* ]]; then
        local start_port="${port_spec%-*}"
        local end_port="${port_spec#*-}"

        # Validate that both start and end are numbers
        if ! [[ "$start_port" =~ ^[0-9]+$ ]] || ! [[ "$end_port" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Error: Invalid port range: $port_spec${NC}" >&2
            return 1
        fi

        # Generate the sequence of ports
        seq "$start_port" "$end_port"
    else
        # It's a single port
        if ! [[ "$port_spec" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Error: Invalid port: $port_spec${NC}" >&2
            return 1
        fi
        echo "$port_spec"
    fi
}

# Function to start a tunnel for a specific port
start_tunnel() {
    local port="$1"

    # Check if a tunnel is already running for this port
    local pid_file="$PID_DIR/proxy_$port.pid"
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p "$pid" > /dev/null; then
            # Additional check: verify this process is actually an SSH tunnel for this port
            if ps aux | grep -v grep | grep "$pid" | grep -q "ssh.*-L.*$port:host.docker.internal:$port"; then
                echo -e "${GREEN}Port $port: Tunnel already running (PID: $pid). Skipping.${NC}"
                return
            else
                echo -e "${YELLOW}Port $port: PID $pid exists but not a tunnel. Starting new one.${NC}"
                rm -f "$pid_file"
            fi
        else
            echo -e "${YELLOW}Port $port: Stale PID file found. Starting new tunnel.${NC}"
            rm -f "$pid_file"
        fi
    fi

    # Create a log file for this tunnel
    local tunnel_log_file="$LOG_DIR/tunnel_${port}_$(date +%Y%m%d_%H%M%S).log"
    echo -e "${GREEN}Port $port: Starting tunnel...${NC}"

    # Start SSH tunnel in background with output redirection
    if [ -n "$SSH_PASSWORD" ]; then
        # Use sshpass if password is provided
        sshpass -p "$SSH_PASSWORD" ssh -N -L "$port:host.docker.internal:$port" "$SSH_USER@$SSH_HOST" -p "$SSH_PORT" > "$tunnel_log_file" 2>&1 &
    else
        # Use regular SSH if no password is provided
        ssh -N -L "$port:host.docker.internal:$port" "$SSH_USER@$SSH_HOST" -p "$SSH_PORT" > "$tunnel_log_file" 2>&1 &
    fi

    # Save the PID
    local pid=$!
    echo "$pid" > "$PID_DIR/proxy_$port.pid"
    # Save the log file path in a companion file for reference
    echo "$tunnel_log_file" > "$PID_DIR/proxy_${port}_log.txt"
    echo -e "${GREEN}Port $port: Tunnel started (PID: $pid)${NC}"
}

# Process each port or port range
IFS=',' read -ra PORT_SPECS <<< "$PORTS"
for port_spec in "${PORT_SPECS[@]}"; do
    # Expand port ranges
    for port in $(expand_port_range "$port_spec"); do
        start_tunnel "$port"
    done
done

echo -e "${GREEN}All tunnels started in background.${NC} Use proxy-stop.sh to stop them."
echo "Tunnel PIDs are stored in $PID_DIR/"
