#!/bin/bash

# config.sh - Display server configuration and file locations

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source shared utilities
source "$PROJECT_ROOT/lib/config-display.sh"

# Detect server configuration file location
HOST_ENV_FILE="$SCRIPT_DIR/host.env"

main() {
    echo ""
    display_section_separator "Server Configuration"
    echo ""

    # Display configuration file location
    echo -e "  ${CYAN}Configuration Files:${NC}"
    display_file_location "$HOST_ENV_FILE"
    echo ""

    # Display current values
    echo -e "  ${CYAN}Current Values:${NC}"

    local projects_dir=$(get_config_value "$HOST_ENV_FILE" "PROJECTS_DIR")
    local container_projects_dir=$(get_config_value "$HOST_ENV_FILE" "CONTAINER_PROJECTS_DIR_NAME")
    local host_dirs=$(get_config_value "$HOST_ENV_FILE" "HOST_DIRS")
    local container_env=$(get_config_value "$HOST_ENV_FILE" "CONTAINER_ENV")
    local disable_host_ssh=$(get_config_value "$HOST_ENV_FILE" "DISABLE_HOST_SSH")
    local smb_enabled=$(get_config_value "$HOST_ENV_FILE" "SMB_ENABLED")
    local smb_shares=$(get_config_value "$HOST_ENV_FILE" "SMB_SHARES")

    display_config_value "PROJECTS_DIR" "$projects_dir"
    display_config_value "CONTAINER_PROJECTS_DIR_NAME" "$container_projects_dir"
    display_config_value "HOST_DIRS" "$host_dirs"
    display_config_value "CONTAINER_ENV" "$container_env"
    display_config_value "DISABLE_HOST_SSH" "$disable_host_ssh"
    display_config_value "SMB_ENABLED" "$smb_enabled"
    display_config_value "SMB_SHARES" "$smb_shares"

    echo ""
}

main "$@"
