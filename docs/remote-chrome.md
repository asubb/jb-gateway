# Remote Chrome Access Details

The container includes a remote Chrome instance that can be accessed via a web browser using noVNC.

## How to Access

1. Ensure the container is running.
2. Open your web browser and navigate to:
   ```
   http://localhost:6080/vnc.html
   ```
3. Click "Connect".
4. You will see a Fluxbox desktop environment with Chromium running.

This is useful for debugging web applications or accessing web-based tools from within the container's network environment.

## Configuration

- **Port**: 6080 (noVNC)
- **VNC Port**: 5900 (Internal)
- **Chromium Debug Port**: 9222
- **Display**: :1
- **Screen Resolution**: 1920x1080x24
