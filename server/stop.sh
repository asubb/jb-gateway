#!/bin/bash

set -e

echo "Stopping JetBrains Gateway services..."

# Stop and remove the Docker container
echo "Stopping Docker container..."
docker stop jb-gateway 2>/dev/null || echo "jb-gateway container is not running"
docker rm jb-gateway 2>/dev/null || echo "jb-gateway container does not exist"

# Stop the standalone SSH server if running (macOS specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
  SSH_TEMP_DIR="$HOME/.jb-gateway/ssh"
  SSH_PID_FILE="$SSH_TEMP_DIR/sshd.pid"
  
  if [ -f "$SSH_PID_FILE" ]; then
    SSH_PID=$(cat "$SSH_PID_FILE")
    if ps -p "$SSH_PID" > /dev/null; then
      echo "Stopping standalone SSH server (PID: $SSH_PID)..."
      kill "$SSH_PID"
      rm "$SSH_PID_FILE"
    else
      echo "SSH server process is not running, but PID file exists. Cleaning up..."
      rm "$SSH_PID_FILE"
    fi
  else
    # Try to find SSH server by checking for process listening on the SSH port
    HOST_SSH_PORT=2022
    SSH_PROCESS=$(lsof -i :$HOST_SSH_PORT -t 2>/dev/nulls)
    
    if [ -n "$SSH_PROCESS" ]; then
      echo "Found SSH server process listening on port $HOST_SSH_PORT (PID: $SSH_PROCESS)..."
      echo "Stopping SSH server..."
      kill "$SSH_PROCESS" 2>/dev/null || echo "Failed to stop SSH server process"
    else
      echo "No SSH server found running on port $HOST_SSH_PORT"
    fi
  fi
fi

echo "JetBrains Gateway services stopped."
