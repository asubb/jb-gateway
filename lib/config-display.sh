#!/bin/bash

# config-display.sh - Shared utilities for displaying configuration information
# Matches visual style from client/status.sh

# Color codes (matching status.sh)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Status symbols (matching status.sh)
CHECK_MARK="✓"
CROSS_MARK="✗"
WARNING_MARK="⚠"
INFO_MARK="ℹ"

# Display file location with existence indicator
# Args: $1 = file path
display_file_location() {
    local file_path=$1

    if [[ -f "$file_path" && -r "$file_path" ]]; then
        echo -e "  ${GREEN}${CHECK_MARK}${NC} $file_path"
    else
        echo -e "  ${YELLOW}${WARNING_MARK}${NC} $file_path (not found - using defaults)"
    fi
}

# Display directory location with existence indicator
# Args: $1 = directory path
display_directory_location() {
    local dir_path=$1

    if [[ -d "$dir_path" ]]; then
        echo -e "  ${GREEN}${CHECK_MARK}${NC} $dir_path"
    else
        echo -e "  ${CYAN}${INFO_MARK}${NC} $dir_path (not created yet)"
    fi
}

# Display section separator line (matching status.sh)
# Args: $1 = section title
display_section_separator() {
    local title=$1
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${INFO_MARK} $title${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Get configuration value from env file
# Args: $1 = env file path, $2 = key name
get_config_value() {
    local env_file=$1
    local key=$2

    if [[ -f "$env_file" ]]; then
        grep "^$key=" "$env_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr -d "'"
    fi
}

# Display configuration key-value pair
# Args: $1 = key name, $2 = value
display_config_value() {
    local key=$1
    local value=$2

    if [[ -z "$value" ]]; then
        echo -e "    $key: ${CYAN}(not set)${NC}"
    else
        echo -e "    $key: $value"
    fi
}
