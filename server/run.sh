#!/bin/bash

set -e

# Default projects directory (will be overridden by host.env if present)
DEFAULT_PROJECTS_DIR="${1:-$HOME/projects}"

HOST_SSH_PORT=2022
# Check for standalone SSH server and install if needed (macOS specific)
if [[ "$OSTYPE" == "darwin"* ]] && [[ "${DISABLE_HOST_SSH}" != "true" ]]; then
  echo "Checking for standalone SSH server..."

  # Check if 'minissh' is installed via brew (or install your preferred lightweight SSH server)
  SSH_SERVER_RUNNING=false

  # First, check if the port is already in use
  if lsof -i :$HOST_SSH_PORT &>/dev/null; then
    echo "Port $HOST_SSH_PORT is already in use, assuming SSH server is running."
    SSH_SERVER_RUNNING=true
  else
    # Check if openssh is installed
    if ! brew list openssh &>/dev/null; then
      echo "OpenSSH not found. Installing via Homebrew..."
      brew install openssh
    fi

    # Create a temporary config file for the standalone SSH server
    SSH_TEMP_DIR="$HOME/.jb-gateway/ssh"
    mkdir -p "$SSH_TEMP_DIR"

    SSH_CONFIG_FILE="$SSH_TEMP_DIR/sshd_config"
    echo "Port $HOST_SSH_PORT" > "$SSH_CONFIG_FILE"
    echo "ListenAddress 0.0.0.0" >> "$SSH_CONFIG_FILE"
    echo "PermitRootLogin no" >> "$SSH_CONFIG_FILE"
    echo "PasswordAuthentication yes" >> "$SSH_CONFIG_FILE"
    echo "ChallengeResponseAuthentication yes" >> "$SSH_CONFIG_FILE"
    echo "UsePAM yes" >> "$SSH_CONFIG_FILE"
    echo "X11Forwarding no" >> "$SSH_CONFIG_FILE"
    echo "PrintMotd no" >> "$SSH_CONFIG_FILE"
    echo "AuthenticationMethods publickey,password keyboard-interactive" >> "$SSH_CONFIG_FILE"

    # Create host keys if they don't exist
    if [ ! -f "$SSH_TEMP_DIR/ssh_host_rsa_key" ]; then
      ssh-keygen -t rsa -f "$SSH_TEMP_DIR/ssh_host_rsa_key" -N "" < /dev/null
    fi

    echo "HostKey $SSH_TEMP_DIR/ssh_host_rsa_key" >> "$SSH_CONFIG_FILE"

    # Start the standalone SSH server
    echo "Starting standalone SSH server on port $HOST_SSH_PORT..."
    /usr/sbin/sshd -f "$SSH_CONFIG_FILE" -D &
    SSH_PID=$!

    # Wait a moment for the server to start
    sleep 2

    # Check if the server started successfully
    if ps -p $SSH_PID > /dev/null; then
      echo "Standalone SSH server started successfully with PID: $SSH_PID"
      # Store the PID for clean termination later
      echo "$SSH_PID" > "$SSH_TEMP_DIR/sshd.pid"

      SSH_SERVER_RUNNING=true
    else
      echo "Failed to start standalone SSH server"
    fi
  fi

  if [ "$SSH_SERVER_RUNNING" = false ]; then
    echo "Warning: Could not verify or start SSH server on port $HOST_SSH_PORT."
    echo "Docker container will still be started, but host SSH server might not be accessible."
  fi
fi

# Stop and remove existing container if it exists
docker stop jb-gateway || true
docker rm jb-gateway || true

# Create named volume for cache if it doesn't exist
docker volume create jb-gateway-cache

# Get current host user
HOST_USER="$(whoami)"
echo "Host user: $HOST_USER"

ADDITIONAL_VOLUMES=""
ADDITIONAL_ENV=""

# Check if host.env file exists and read additional directories to mount and environment variables
if [ -f "$(dirname "$0")/host.env" ]; then
  source "$(dirname "$0")/host.env"
  if [ ! -z "$HOST_DIRS" ]; then
    echo "Mounting additional directories from host.env:"
    IFS=',' read -ra DIR_MAPPINGS <<< "$HOST_DIRS"
    for mapping in "${DIR_MAPPINGS[@]}"; do
      echo "  - $mapping"
      ADDITIONAL_VOLUMES="$ADDITIONAL_VOLUMES -v $mapping"
    done
  fi

  # Process container environment variables if defined
  if [ ! -z "$CONTAINER_ENV" ]; then
    echo "Setting additional environment variables from host.env:"
    # Replace ~ with the actual container home directory
    CONTAINER_ENV_PROCESSED=$(echo "$CONTAINER_ENV" | sed 's/\~/\/home\/jb-gateway/g')

    # Split the environment variables and add each one separately
    for env_var in $CONTAINER_ENV_PROCESSED; do
      echo "  - $env_var"
      ADDITIONAL_ENV="$ADDITIONAL_ENV -e $env_var"
    done
  fi
fi

# Set PROJECTS_DIR from host.env if defined, otherwise use the default
PROJECTS_DIR="${PROJECTS_DIR:-$DEFAULT_PROJECTS_DIR}"

# Set container projects directory (default to 'projects' inside HOME)
CONTAINER_PROJECTS_DIR_NAME="${CONTAINER_PROJECTS_DIR_NAME:-projects}"
CONTAINER_PROJECTS_PATH="/home/jb-gateway/$CONTAINER_PROJECTS_DIR_NAME"

# Ensure the projects directory exists
if [ ! -d "$PROJECTS_DIR" ]; then
  echo "Warning: Projects directory $PROJECTS_DIR does not exist. Creating it."
  mkdir -p "$PROJECTS_DIR"
fi

echo "Using projects directory: $PROJECTS_DIR"

docker run -d --name jb-gateway \
  -v ~/.jb-gateway/.ssh:/home/jb-gateway/.ssh/ \
  -v ~/.jb-gateway/.config:/home/jb-gateway/.config/ \
  -v ~/.jb-gateway/.gitconfig:/home/jb-gateway/.gitconfig \
  -v jb-gateway-cache:/home/jb-gateway/.cache \
  -v ~/.jb-gateway/.java:/home/jb-gateway/.java/ \
  -v ~/.jb-gateway/.local:/home/jb-gateway/.local/ \
  -v ~/.jb-gateway/.gradle:/home/jb-gateway/.gradle/ \
  -v ~/.jb-gateway/.jdks:/home/jb-gateway/.jdks/ \
  -v ~/.jb-gateway/.sdkman/candidates:/home/jb-gateway/.sdkman/candidates \
  -v "$PROJECTS_DIR":"$CONTAINER_PROJECTS_PATH" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e HOST_USER="$HOST_USER" \
  -e CONTAINER_PROJECTS_PATH="$CONTAINER_PROJECTS_PATH" \
  $ADDITIONAL_VOLUMES \
  $ADDITIONAL_ENV \
  -p 1022:22 \
  -p 139:139 \
  -p 445:445 \
  -p 6080:6080 \
  -p 9222:9222 \
  jb-gateway

# Wait for the container to be in 'running' state
echo "Waiting for jb-gateway container to start..."
MAX_RETRIES=10
RETRY_COUNT=0
while [ "$(docker inspect -f '{{.State.Running}}' jb-gateway 2>/dev/null)" != "true" ]; do
  sleep 1
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Error: Container failed to start within $MAX_RETRIES seconds."
    exit 1
  fi
done

# Change ownership of the cache volume to jb-gateway user
docker exec jb-gateway chown -R jb-gateway:jb-gateway /home/jb-gateway/.cache

# Wait a moment for the container to initialize (some services start in background)
sleep 2

# Display connection information
echo ""
echo "🚀 JetBrains Gateway container is ready!"
echo ""
echo "🔑 SSH PUBLIC KEY (Container User):"
echo "------------------------------------"
# Wait until the SSH key is generated in the container
MAX_RETRIES=10
RETRY_COUNT=0
while ! docker exec jb-gateway [ -f /home/jb-gateway/.ssh/id_rsa.pub ] 2>/dev/null; do
  sleep 1
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Warning: SSH key not found in container. You may need to check it manually later."
    break
  fi
done
docker exec jb-gateway cat /home/jb-gateway/.ssh/id_rsa.pub || echo "SSH key not available yet."
echo "------------------------------------"
echo "👉 Add this key to your GitHub/GitLab account to enable git operations."
echo ""
echo "🖥️  HOW TO CONNECT:"
echo "------------------"
echo "1. JetBrains Gateway (Recommended):"
echo "   - Host: localhost"
echo "   - Port: 1022"
echo "   - User: jb-gateway"
echo ""
echo "2. Terminal SSH:"
echo "   ssh -p 1022 jb-gateway@localhost"
echo ""
echo "3. Remote Chrome (noVNC):"
echo "   http://localhost:6080/vnc.html"
echo ""
echo "4. Chromium Debug Port:"
echo "   localhost:9222"
echo ""
echo "📂 PROJECTS:"
echo "-----------"
echo "Host: $PROJECTS_DIR"
echo "Container: $CONTAINER_PROJECTS_PATH"

# Display info about the standalone SSH server
if [[ "$OSTYPE" == "darwin"* ]] && [ "$SSH_SERVER_RUNNING" = true ]; then
    echo ""
    echo "🔧 STANDALONE SSH SERVER (Host):"
    echo "-------------------------------"
    echo "Running on port: $HOST_SSH_PORT"
    echo "Connect using: ssh -p $HOST_SSH_PORT $(whoami)@localhost"
    echo "Usage within container: use 'host-ssh' command"
    echo "-------------------------------"
fi
