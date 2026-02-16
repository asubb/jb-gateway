#!/bin/bash

# status.sh - Display operational status of all jb-gateway client subsystems
# Usage: ./client/status.sh

set -e

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
PID_DIR="$HOME/.jb-gateway/proxy"
LOG_DIR="$HOME/.jb-gateway/logs"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Status symbols
CHECK_MARK="✓"
CROSS_MARK="✗"
WARNING_MARK="⚠"
INFO_MARK="ℹ"

# Platform detection
PLATFORM=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
else
    PLATFORM="unknown"
fi

# Configuration functions
check_env_exists() {
    [[ -f "$ENV_FILE" ]]
}

get_proxy_ports() {
    if check_env_exists; then
        grep "^PROXY_PORTS=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'"
    fi
}

get_ssh_settings() {
    local setting=$1
    if check_env_exists; then
        grep "^$setting=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'"
    fi
}

get_smb_settings() {
    local setting=$1
    if check_env_exists; then
        grep "^$setting=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'"
    fi
}

# HTTP Proxy Tunnel functions
check_proxy_dir_exists() {
    [[ -d "$PID_DIR" ]]
}

find_proxy_pids() {
    if check_proxy_dir_exists; then
        find "$PID_DIR" -name "proxy_*.pid" 2>/dev/null
    fi
}

read_pid_file() {
    local pid_file=$1
    if [[ -f "$pid_file" && -r "$pid_file" ]]; then
        local pid=$(cat "$pid_file" 2>/dev/null | tr -d '[:space:]')
        if [[ "$pid" =~ ^[0-9]+$ ]]; then
            echo "$pid"
            return 0
        fi
    fi
    return 1
}

check_pid_running() {
    local pid=$1
    ps -p "$pid" > /dev/null 2>&1
}

verify_tunnel_process() {
    local pid=$1
    local port=$2
    local cmd_line=$(ps -p "$pid" -o command= 2>/dev/null)

    # Check if it's sshpass (parent of ssh) or ssh itself
    if [[ "$cmd_line" =~ sshpass ]] || [[ "$cmd_line" =~ ssh.*-L ]]; then
        return 0
    fi

    # Check if there's an ssh child process with our port
    if command -v pgrep > /dev/null 2>&1; then
        if pgrep -P "$pid" 2>/dev/null | xargs ps -p 2>/dev/null | grep -q "ssh.*-L.*$port:"; then
            return 0
        fi
    fi

    return 1
}

calculate_uptime() {
    local pid=$1
    if [[ "$PLATFORM" == "macos" ]]; then
        local start_time=$(ps -p "$pid" -o lstart= 2>/dev/null)
        if [[ -n "$start_time" ]]; then
            local start_epoch=$(date -j -f "%a %b %d %H:%M:%S %Y" "$start_time" "+%s" 2>/dev/null)
            local now_epoch=$(date "+%s")
            local uptime_seconds=$((now_epoch - start_epoch))
            format_uptime "$uptime_seconds"
        fi
    else
        # Linux
        local start_time=$(ps -p "$pid" -o etimes= 2>/dev/null | tr -d '[:space:]')
        if [[ -n "$start_time" ]]; then
            format_uptime "$start_time"
        fi
    fi
}

format_uptime() {
    local seconds=$1
    local days=$((seconds / 86400))
    local hours=$(( (seconds % 86400) / 3600 ))
    local minutes=$(( (seconds % 3600) / 60 ))

    if [[ $days -gt 0 ]]; then
        echo "${days}d ${hours}h ${minutes}m"
    elif [[ $hours -gt 0 ]]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

extract_port_from_filename() {
    local pid_file=$1
    basename "$pid_file" | sed 's/proxy_\([0-9]*\)\.pid/\1/'
}

check_tunnel_status() {
    local pid_file=$1
    local port=$(extract_port_from_filename "$pid_file")
    local pid=$(read_pid_file "$pid_file")

    if [[ -z "$pid" ]]; then
        echo -e "  ${RED}${CROSS_MARK} Port $port: Stale PID file (malformed or empty)${NC}"
        return 1
    fi

    if ! check_pid_running "$pid"; then
        echo -e "  ${YELLOW}${WARNING_MARK} Port $port: Stale PID file (process $pid not running)${NC}"
        return 1
    fi

    if ! verify_tunnel_process "$pid" "$port"; then
        echo -e "  ${YELLOW}${WARNING_MARK} Port $port: PID $pid exists but not an SSH tunnel${NC}"
        return 1
    fi

    local uptime=$(calculate_uptime "$pid")
    echo -e "  ${GREEN}${CHECK_MARK} Port $port: Active (PID: $pid, Uptime: $uptime)${NC}"
    return 0
}

check_monitor_status() {
    local monitor_pid_file="$PID_DIR/monitor.pid"

    if [[ ! -f "$monitor_pid_file" ]]; then
        echo -e "  ${CYAN}${INFO_MARK} Monitor: Not running${NC}"
        return 1
    fi

    local pid=$(read_pid_file "$monitor_pid_file")

    if [[ -z "$pid" ]]; then
        echo -e "  ${YELLOW}${WARNING_MARK} Monitor: Stale PID file (malformed or empty)${NC}"
        return 1
    fi

    if ! check_pid_running "$pid"; then
        echo -e "  ${YELLOW}${WARNING_MARK} Monitor: Stale PID file (process $pid not running)${NC}"
        return 1
    fi

    local uptime=$(calculate_uptime "$pid")
    echo -e "  ${GREEN}${CHECK_MARK} Monitor: Active (PID: $pid, Uptime: $uptime)${NC}"
    return 0
}

display_tunnel_status() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${INFO_MARK} HTTP Proxy Tunnels${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if ! check_proxy_dir_exists; then
        echo -e "  ${CYAN}${INFO_MARK} No tunnels active (PID directory not found)${NC}"
        echo ""
        return
    fi

    local pid_files=$(find_proxy_pids)

    if [[ -z "$pid_files" ]]; then
        echo -e "  ${CYAN}${INFO_MARK} No tunnels active${NC}"
        echo ""
        return
    fi

    local tunnel_count=0
    while IFS= read -r pid_file; do
        check_tunnel_status "$pid_file" && ((tunnel_count++)) || true
    done <<< "$pid_files"

    echo ""
    check_monitor_status
    echo ""
}

# SMB Mount functions
list_smb_mounts() {
    if [[ "$PLATFORM" == "macos" ]]; then
        mount -t smbfs 2>/dev/null
    else
        # Linux
        mount -t cifs 2>/dev/null
    fi
}

parse_mount_info() {
    local mount_line=$1
    local share host mountpoint

    if [[ "$PLATFORM" == "macos" ]]; then
        # macOS format: //user@host/share on /mount/point (smbfs, ...)
        # Extract share: everything after last / before " on "
        share=$(echo "$mount_line" | sed 's|.*/\([^ ]*\) on .*|\1|')
        # Extract host: part between // and / (with or without user@)
        host=$(echo "$mount_line" | sed 's|//\([^@]*@\)\?\([^/]*\)/.*|\2|')
        # Extract mountpoint: everything after "on " and before " ("
        mountpoint=$(echo "$mount_line" | sed 's|.* on \(.*\) (smbfs.*|\1|')
    else
        # Linux format: //host/share on /mount/point type cifs (...)
        share=$(echo "$mount_line" | sed 's|.*/\([^ ]*\) on .*|\1|')
        host=$(echo "$mount_line" | sed 's|//\([^/]*\)/.*|\1|')
        mountpoint=$(echo "$mount_line" | sed 's|.* on \(.*\) type cifs.*|\1|')
    fi

    echo "$mountpoint|$share|$host"
}

check_mount_exists() {
    local mountpoint=$1
    [[ -d "$mountpoint" ]]
}

check_mount_accessible() {
    local mountpoint=$1
    [[ -r "$mountpoint" ]] && [[ -d "$mountpoint" ]]
}

display_mount_status() {
    local mountpoint=$1
    local share=$2
    local host=$3

    if ! check_mount_exists "$mountpoint"; then
        echo -e "  ${RED}${CROSS_MARK} $mountpoint: Mount point does not exist${NC}"
        return 1
    fi

    if ! check_mount_accessible "$mountpoint"; then
        echo -e "  ${YELLOW}${WARNING_MARK} $mountpoint: Not accessible (share: $share, host: $host)${NC}"
        return 1
    fi

    echo -e "  ${GREEN}${CHECK_MARK} $mountpoint: Active (share: $share, host: $host)${NC}"
    return 0
}

display_smb_status() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${INFO_MARK} SMB Mounts${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local mount_output=$(list_smb_mounts)

    if [[ -z "$mount_output" ]]; then
        echo -e "  ${CYAN}${INFO_MARK} No SMB mounts active${NC}"
        echo ""
        return
    fi

    local mount_count=0
    while IFS= read -r mount_line; do
        if [[ -n "$mount_line" ]]; then
            local mount_info=$(parse_mount_info "$mount_line")
            IFS='|' read -r mountpoint share host <<< "$mount_info"
            if [[ -n "$mountpoint" ]]; then
                display_mount_status "$mountpoint" "$share" "$host" && ((mount_count++)) || true
            fi
        fi
    done <<< "$mount_output"

    if [[ $mount_count -eq 0 ]]; then
        echo -e "  ${CYAN}${INFO_MARK} No SMB mounts active${NC}"
    fi

    echo ""
}

# Status Summary functions
count_configured_ports() {
    local proxy_ports=$(get_proxy_ports)
    if [[ -z "$proxy_ports" ]]; then
        echo "0"
        return
    fi

    # Handle comma-separated list and ranges
    local count=0
    IFS=',' read -ra PORTS <<< "$proxy_ports"
    for port_spec in "${PORTS[@]}"; do
        port_spec=$(echo "$port_spec" | tr -d ' ')
        if [[ "$port_spec" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            # Range
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"
            count=$((count + end - start + 1))
        elif [[ "$port_spec" =~ ^[0-9]+$ ]]; then
            # Single port
            count=$((count + 1))
        fi
    done
    echo "$count"
}

count_active_tunnels() {
    if ! check_proxy_dir_exists; then
        echo "0"
        return
    fi

    local pid_files=$(find_proxy_pids)
    if [[ -z "$pid_files" ]]; then
        echo "0"
        return
    fi

    local count=0
    while IFS= read -r pid_file; do
        local port=$(extract_port_from_filename "$pid_file")
        local pid=$(read_pid_file "$pid_file")
        if [[ -n "$pid" ]] && check_pid_running "$pid" && verify_tunnel_process "$pid" "$port"; then
            count=$((count + 1))
        fi
    done <<< "$pid_files"
    echo "$count"
}

determine_health_status() {
    local configured=$(count_configured_ports)
    local active=$(count_active_tunnels)

    if [[ $configured -eq 0 ]]; then
        echo "OK"
        return
    fi

    if [[ $active -eq $configured ]]; then
        echo "OK"
    elif [[ $active -eq 0 ]]; then
        echo "ERROR"
    else
        echo "WARNING"
    fi
}

display_summary() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${INFO_MARK} Summary${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local configured=$(count_configured_ports)
    local active=$(count_active_tunnels)
    local health=$(determine_health_status)

    echo -e "  Configured Ports: $configured"
    echo -e "  Active Tunnels: $active"

    if [[ $configured -gt 0 && $active -lt $configured ]]; then
        local missing=$((configured - active))
        echo -e "  ${YELLOW}${WARNING_MARK} Missing Tunnels: $missing${NC}"
    fi

    echo ""
    case "$health" in
        "OK")
            echo -e "  Overall Status: ${GREEN}${CHECK_MARK} OK${NC}"
            ;;
        "WARNING")
            echo -e "  Overall Status: ${YELLOW}${WARNING_MARK} WARNING (Some tunnels missing)${NC}"
            ;;
        "ERROR")
            echo -e "  Overall Status: ${RED}${CROSS_MARK} ERROR (No tunnels active)${NC}"
            ;;
    esac

    echo ""
    if [[ -d "$LOG_DIR" ]]; then
        echo -e "  Log files: $LOG_DIR"
    else
        echo -e "  ${CYAN}${INFO_MARK} Log directory not found: $LOG_DIR${NC}"
    fi
    echo ""
}

display_configuration() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${INFO_MARK} Configuration${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if check_env_exists; then
        echo -e "  Config file: $ENV_FILE"
    else
        echo -e "  ${YELLOW}${WARNING_MARK} Config file not found: $ENV_FILE${NC}"
        echo -e "  Using default configuration"
    fi

    echo ""
    echo -e "  Proxy Settings:"
    local proxy_ports=$(get_proxy_ports)
    echo -e "    PROXY_PORTS: ${proxy_ports:-"(not set)"}"

    echo ""
    echo -e "  SSH Settings:"
    local ssh_host=$(get_ssh_settings "SSH_HOST")
    local ssh_port=$(get_ssh_settings "SSH_PORT")
    local ssh_user=$(get_ssh_settings "SSH_USER")
    echo -e "    SSH_HOST: ${ssh_host:-"(not set)"}"
    echo -e "    SSH_PORT: ${ssh_port:-"(not set)"}"
    echo -e "    SSH_USER: ${ssh_user:-"(not set)"}"

    echo ""
    echo -e "  SMB Settings:"
    local smb_host=$(get_smb_settings "SMB_HOST")
    local smb_user=$(get_smb_settings "SMB_USER")
    echo -e "    SMB_HOST: ${smb_host:-"(not set)"}"
    echo -e "    SMB_USER: ${smb_user:-"(not set)"}"
    echo ""
}

# Main execution
main() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  jb-gateway Client Status${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "  Platform: $PLATFORM"
    echo ""

    display_configuration
    display_tunnel_status
    display_smb_status
    display_summary
}

main "$@"
