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

# Start VNC and Chrome services
echo "Starting VNC and Chrome services..."
Xvfb :1 -screen 0 1920x1080x24 &
sleep 2 # Give Xvfb time to start
DISPLAY=:1 fluxbox &
DISPLAY=:1 chromium --no-sandbox --disable-dev-shm-usage --remote-debugging-port=9222 &
x11vnc -display :1 -nopw -forever -rfbport 5900 &
websockify --web /usr/share/novnc 6080 localhost:5900 &

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

  # Check VNC/Chrome related services
  if ! pgrep -x "Xvfb" > /dev/null; then
    echo "Xvfb is not running. Restarting VNC stack..."
    Xvfb :1 -screen 0 1920x1080x24 &
    sleep 2
    DISPLAY=:1 fluxbox &
    DISPLAY=:1 chromium --no-sandbox --disable-dev-shm-usage --remote-debugging-port=9222 &
    x11vnc -display :1 -nopw -forever -rfbport 5900 &
  fi

  if ! pgrep -f "websockify" > /dev/null; then
    echo "websockify is not running. Restarting..."
    websockify --web /usr/share/novnc 6080 localhost:5900 &
  fi

  # Sleep for a while before checking again
  sleep 30
done