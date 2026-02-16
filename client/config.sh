#!/bin/bash

# config.sh - Display client configuration and file locations

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source shared utilities
source "$PROJECT_ROOT/lib/config-display.sh"

# Detect client configuration file location
CLIENT_ENV_FILE="$SCRIPT_DIR/.env"
PID_DIR="$HOME/.jb-gateway/proxy"
LOG_DIR="$HOME/.jb-gateway/logs"

main() {
    echo ""
    display_section_separator "Client Configuration"
    echo ""

    # Display configuration file location
    echo -e "  ${CYAN}Configuration Files:${NC}"
    display_file_location "$CLIENT_ENV_FILE"
    echo ""

    # Display current values
    echo -e "  ${CYAN}Current Values:${NC}"

    local ssh_host=$(get_config_value "$CLIENT_ENV_FILE" "SSH_HOST")
    local ssh_port=$(get_config_value "$CLIENT_ENV_FILE" "SSH_PORT")
    local ssh_user=$(get_config_value "$CLIENT_ENV_FILE" "SSH_USER")
    local proxy_ports=$(get_config_value "$CLIENT_ENV_FILE" "PROXY_PORTS")
    local smb_host=$(get_config_value "$CLIENT_ENV_FILE" "SMB_HOST")
    local smb_user=$(get_config_value "$CLIENT_ENV_FILE" "SMB_USER")

    display_config_value "SSH_HOST" "$ssh_host"
    display_config_value "SSH_PORT" "$ssh_port"
    display_config_value "SSH_USER" "$ssh_user"
    display_config_value "PROXY_PORTS" "$proxy_ports"
    display_config_value "SMB_HOST" "$smb_host"
    display_config_value "SMB_USER" "$smb_user"

    echo ""

    # Display runtime directories
    echo -e "  ${CYAN}Runtime Directories:${NC}"
    display_directory_location "$PID_DIR"
    display_directory_location "$LOG_DIR"

    echo ""
}

main "$@"
