#!/bin/bash

# Enable exit on error and command tracing for better debugging
set -e

echo "Starting container initialization..."

# Generate SSH keys for jb-gateway user if they don't exist
if [ ! -f /home/jb-gateway/.ssh/id_rsa ]; then
  echo "Generating SSH keys for jb-gateway user..."
  mkdir -p /home/jb-gateway/.ssh
  chown jb-gateway:jb-gateway /home/jb-gateway/.ssh
  
  # Generate the keys as the jb-gateway user
  sudo -u jb-gateway ssh-keygen -t rsa -b 4096 -f /home/jb-gateway/.ssh/id_rsa -N ""
  
  # Ensure proper permissions
  chown jb-gateway:jb-gateway /home/jb-gateway/.ssh/id_rsa
  chown jb-gateway:jb-gateway /home/jb-gateway/.ssh/id_rsa.pub
  chmod 600 /home/jb-gateway/.ssh/id_rsa
  chmod 644 /home/jb-gateway/.ssh/id_rsa.pub
  echo "SSH key generation complete."
fi

# grant our ssh user connection to docker
if [ -e /var/run/docker.sock ]; then
  chown jb-gateway:jb-gateway /var/run/docker.sock
fi

# Configure SSH client for the host connection
mkdir -p /home/jb-gateway/.ssh/
# Use HOST_USER environment variable if available, fallback to 'user'
HOST_USER="${HOST_USER:-user}"
echo "Configuring SSH for host user: $HOST_USER"

cat > /home/jb-gateway/.ssh/config << EOF
Host host.docker.internal
    User ${HOST_USER}
    Port 2022
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

chown -R jb-gateway:jb-gateway /home/jb-gateway/.ssh/
chmod 600 /home/jb-gateway/.ssh/config

echo "Container initialization complete. Starting SSH service..."

# Start SSH service in foreground
exec /usr/sbin/sshd -D
