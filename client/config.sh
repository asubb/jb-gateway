#!/bin/bash

# config.sh - Display client configuration and file locations

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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
            echo "  --profile NAME    Display configuration for specific profile"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1"
            echo "Usage: $0 [--profile NAME]"
            exit 1
            ;;
    esac
done

# Source shared utilities
source "$PROJECT_ROOT/lib/config-display.sh"

# Resolve paths based on profile
if [[ -n "$PROFILE" ]]; then
    CONFIG_DIR="$HOME/.jb-gateway/profiles/$PROFILE"
    CLIENT_ENV_FILE="$CONFIG_DIR/.env"
    PID_DIR="$CONFIG_DIR/state"
    LOG_DIR="$CONFIG_DIR/logs"
else
    CONFIG_DIR="$HOME/.jb-gateway"
    CLIENT_ENV_FILE="$SCRIPT_DIR/.env"
    PID_DIR="$HOME/.jb-gateway/proxy"
    LOG_DIR="$HOME/.jb-gateway/logs"
fi

main() {
    echo ""
    display_section_separator "Client Configuration"
    echo ""

    # Display profile information
    if [[ -n "$PROFILE" ]]; then
        echo -e "  ${CYAN}Profile:${NC} ${GREEN}$PROFILE${NC}"
    else
        echo -e "  ${CYAN}Profile:${NC} ${CYAN}(default)${NC}"
    fi
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
