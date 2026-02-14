#!/bin/bash

# Enable exit on error
set -e

echo "Starting services..."

# Start SSH service in the background
/usr/sbin/sshd
echo "SSH service started."

# Set up Samba user
echo "Setting up Samba user..."
(echo "password"; echo "password") | smbpasswd -a jb-gateway
smbpasswd -e jb-gateway

# Start Samba service
echo "Starting Samba service..."
service smbd start
service nmbd start

echo "All services started. Monitoring services..."

# Monitor services and restart if they fail
while true; do
  # Check if SSH service is running
  if ! pgrep -x "sshd" > /dev/null; then
    echo "SSH service is not running. Restarting..."
    /usr/sbin/sshd
  fi

  # Check if Samba services are running
  if ! pgrep -x "smbd" > /dev/null; then
    echo "Samba service is not running. Restarting..."
    service smbd start
  fi

  if ! pgrep -x "nmbd" > /dev/null; then
    echo "Samba NetBIOS service is not running. Restarting..."
    service nmbd start
  fi

  # Sleep for a while before checking again
  sleep 30
done