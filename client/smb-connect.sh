#!/bin/bash

# smb-connect.sh - Script to connect to SMB shares defined in .env
# Usage:
#   ./smb-connect.sh [--profile NAME] view [host]                     - View available shares
#   ./smb-connect.sh [--profile NAME] mount <share> <mountpoint> [host] - Mount a share to a local directory

set -e

# Profile support
PROFILE=""

# Parse profile flag early
for ((i=1; i<=$#; i++)); do
    if [[ "${!i}" == "--profile" ]]; then
        ((i++))
        PROFILE="${!i}"
        break
    fi
done

# Default values
SMB_HOST="localhost"
SMB_USER="jb-gateway"
SMB_PASSWORD="password"

# Determine env file location based on profile
if [[ -n "$PROFILE" ]]; then
    ENV_FILE="$HOME/.jb-gateway/profiles/$PROFILE/.env"
else
    ENV_FILE="$(dirname "$0")/.env"
fi

# Load configuration from .env file if it exists
if [ -f "$ENV_FILE" ]; then
    echo "Loading configuration from .env file..."
    source "$ENV_FILE"
elif [ -z "$PROFILE" ] && [ -f "$(dirname "$0")/.env" ]; then
    echo "Loading configuration from .env file..."
    source "$(dirname "$0")/.env"
fi

# Load configuration from host.env file if it exists
if [ -f "$(dirname "$0")/../server/host.env" ]; then
    echo "Loading configuration from host.env file..."
    source "$(dirname "$0")/../server/host.env"
fi

# Function to view available shares
view_shares() {
    local host=${1:-$SMB_HOST}

    echo "Viewing available SMB shares on $host..."
    echo "You may be prompted for a password. Use: $SMB_PASSWORD"

    if command -v smbutil &> /dev/null; then
        # macOS
        smbutil view //$SMB_USER@$host
    elif command -v smbclient &> /dev/null; then
        # Linux
        smbclient -L $host -U $SMB_USER%$SMB_PASSWORD
    else
        echo "Error: No SMB client tools found. Please install smbutil (macOS) or smbclient (Linux)."
        exit 1
    fi
}

# Function to mount a share
mount_share() {
    local share=$1
    local mountpoint=$2
    local host=${3:-$SMB_HOST}

    if [ -z "$share" ] || [ -z "$mountpoint" ]; then
        echo "Error: Share name and mount point are required."
        echo "Usage: $0 mount <share> <mountpoint> [host]"
        exit 1
    fi

    # Check if mountpoint exists
    if [ ! -d "$mountpoint" ]; then
        echo "Mount point $mountpoint does not exist. Creating it..."
        mkdir -p "$mountpoint"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create mount point $mountpoint"
            exit 1
        fi
    fi

    echo "Mounting SMB share $share from $host to $mountpoint..."
    echo "You may be prompted for a password. Use: $SMB_PASSWORD"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        mount_smbfs //$SMB_USER@$host/$share "$mountpoint"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo mount -t cifs //$host/$share "$mountpoint" -o username=$SMB_USER,password=$SMB_PASSWORD
    else
        echo "Error: Unsupported operating system."
        exit 1
    fi

    if [ $? -eq 0 ]; then
        echo "Successfully mounted $share to $mountpoint"
    else
        echo "Failed to mount $share to $mountpoint"
        exit 1
    fi
}

# Filter out profile arguments
FILTERED_ARGS=()
SKIP_NEXT=false
for arg in "$@"; do
    if [[ "$SKIP_NEXT" == "true" ]]; then
        SKIP_NEXT=false
        continue
    fi
    if [[ "$arg" == "--profile" ]]; then
        SKIP_NEXT=true
        continue
    fi
    FILTERED_ARGS+=("$arg")
done

# Main script logic
case "${FILTERED_ARGS[0]}" in
    view)
        view_shares "${FILTERED_ARGS[1]}"
        ;;
    mount)
        mount_share "${FILTERED_ARGS[1]}" "${FILTERED_ARGS[2]}" "${FILTERED_ARGS[3]}"
        ;;
    *)
        echo "Usage:"
        echo "  $0 [--profile NAME] view [host]                     - View available shares"
        echo "  $0 [--profile NAME] mount <share> <mountpoint> [host] - Mount a share to a local directory"
        echo ""
        echo "Example:"
        echo "  $0 view                           - View shares on default host"
        echo "  $0 --profile dev view             - View shares using dev profile"
        echo "  $0 view 192.168.1.100             - View shares on specific host"
        echo "  $0 mount projects ~/smb-mount     - Mount projects share from default host"
        echo "  $0 --profile dev mount projects ~/smb-mount - Mount using dev profile"
        echo "  $0 mount projects ~/smb-mount 192.168.1.100 - Mount projects share from specific host"
        exit 1
        ;;
esac

exit 0
