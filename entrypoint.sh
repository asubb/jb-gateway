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

# Create a script to set environment variables for jb-gateway user
mkdir -p /home/jb-gateway/.config
env | grep -v "PATH\|HOME\|USER\|SHELL\|PWD\|LOGNAME\|_\|TERM\|SHLVL\|HOSTNAME\|SSH_\|MAIL\|LANG\|LANGUAGE\|LC_" > /home/jb-gateway/.config/container_env_vars
sed -i 's/^/export /' /home/jb-gateway/.config/container_env_vars

# Add environment variables to user's .bashrc and .profile
for rc_file in /home/jb-gateway/.bashrc /home/jb-gateway/.profile; do
  if [ ! -f "$rc_file" ]; then
    touch "$rc_file"
  else
    # Remove existing environment variables section if it exists
    sed -i '/# JB-GATEWAY ENVIRONMENT VARIABLES/,+4d' "$rc_file"
  fi

  # Always add the environment variables section
  echo "" >> "$rc_file"
  echo "# JB-GATEWAY ENVIRONMENT VARIABLES" >> "$rc_file"
  echo "if [ -f \$HOME/.config/container_env_vars ]; then" >> "$rc_file"
  echo "  source \$HOME/.config/container_env_vars" >> "$rc_file"
  echo "fi" >> "$rc_file"

  # Ensure proper permissions
  chown jb-gateway:jb-gateway "$rc_file"
  chmod 644 "$rc_file"
done

# Ensure proper permissions for the environment variables file
chown jb-gateway:jb-gateway /home/jb-gateway/.config/container_env_vars
chmod 644 /home/jb-gateway/.config/container_env_vars

echo "Container initialization complete. Starting SSH service..."

# Start SSH service in foreground
exec /usr/sbin/sshd -D
