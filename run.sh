#!/bin/bash

set -e

# Check if username is provided as a parameter
# If not, use the current user from whoami
HOST_USER="${1:-$(whoami)}"

# Check if projects directory is provided as a second parameter
# If not, use default ~/projects
PROJECTS_DIR="${2:-$HOME/projects}"

# Ensure the projects directory exists
if [ ! -d "$PROJECTS_DIR" ]; then
  echo "Warning: Projects directory $PROJECTS_DIR does not exist. Creating it."
  mkdir -p "$PROJECTS_DIR"
fi

echo "Using host user: $HOST_USER"
echo "Using projects directory: $PROJECTS_DIR"

# Stop and remove existing container if it exists
docker stop jb-gateway || true
docker rm jb-gateway || true

# Create named volume for cache if it doesn't exist
docker volume create jb-gateway-cache

docker run -it -d --name jb-gateway \
  -e HOST_USER="$HOST_USER" \
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
echo "======= SSH PUBLIC KEY ======="
docker exec jb-gateway cat /home/jb-gateway/.ssh/id_rsa.pub
echo "=============================="
echo "Connect using: ssh -p 1022 jb-gateway@localhost"
echo "Projects directory: $PROJECTS_DIR is mounted at /home/jb-gateway/projects"
echo "Host commands will run as user: $HOST_USER"
