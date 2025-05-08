#!/bin/bash

set -e

# Check if projects directory is provided as a parameter
# If not, use default ~/projects
PROJECTS_DIR="${1:-$HOME/projects}"

# Ensure the projects directory exists
if [ ! -d "$PROJECTS_DIR" ]; then
  echo "Warning: Projects directory $PROJECTS_DIR does not exist. Creating it."
  mkdir -p "$PROJECTS_DIR"
fi

HOST_SSH_PORT=2022
# Check for standalone SSH server and install if needed (macOS specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
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

echo "Using projects directory: $PROJECTS_DIR"

# Stop and remove existing container if it exists
docker stop jb-gateway || true
docker rm jb-gateway || true

# Create named volume for cache if it doesn't exist
docker volume create jb-gateway-cache

docker run -it -d --name jb-gateway \
  -v ~/.jb-gateway/.ssh:/home/jb-gateway/.ssh/ \
  -v ~/.jb-gateway/.config:/home/jb-gateway/.config/ \
  -v jb-gateway-cache:/home/jb-gateway/.cache \
  -v ~/.jb-gateway/.java:/home/jb-gateway/.java/ \
  -v ~/.jb-gateway/.local:/home/jb-gateway/.local/ \
  -v ~/.jb-gateway/.gradle:/home/jb-gateway/.gradle/ \
  -v ~/.jb-gateway/.jdks:/home/jb-gateway/.jdks/ \
  -v "$PROJECTS_DIR":/home/jb-gateway/projects \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 1022:22 \
  jb-gateway

# Change ownership of the cache volume to jb-gateway user
docker exec jb-gateway chown -R jb-gateway:jb-gateway /home/jb-gateway/.cache

# Wait a moment for the container to initialize
sleep 2

# Display the SSH public key
echo "======= CONTAINER USER SSH PUBLIC KEY ======="
echo "You need to add it to your Github (or any other) account make sure it can push changes"
docker exec jb-gateway cat /home/jb-gateway/.ssh/id_rsa.pub
echo "=============================="
echo "Connect to Docker container using: ssh -p 1022 jb-gateway@localhost"
echo "Projects directory: $PROJECTS_DIR is mounted at /home/jb-gateway/projects"

# Display info about the standalone SSH server
if [[ "$OSTYPE" == "darwin"* ]] && [ "$SSH_SERVER_RUNNING" = true ]; then
    echo ""
    echo "====== STANDALONE SSH SERVER ====="
    echo "Standalone SSH server is running on port $HOST_SSH_PORT"
    echo "Connect using: ssh -p $HOST_SSH_PORT $(whoami)@localhost"
    echo "====================================="
fi
