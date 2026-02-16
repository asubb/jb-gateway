## Why

Currently, users have no quick way to inspect the operational state of client subsystems (HTTP proxy tunnels, SMB
connections, etc.) without manually checking individual PID files, log files, and process status. A unified status
script would provide immediate visibility into which subsystems are active, their configuration, and health status,
improving operational awareness and troubleshooting.

## What Changes

- Add new `client/status.sh` script that prints the current state of all client subsystems
- Display status of HTTP proxy tunnels (which ports are active, PIDs, uptime)
- Display status of SMB connections (mounted shares, mount points)
- Show relevant configuration from `.env` files
- Provide summary of active vs. configured subsystems
- Include health checks (e.g., verify PIDs are actually running)

## Capabilities

### New Capabilities

- `client-status-monitoring`: Status inspection and reporting for all client-side subsystems including HTTP proxy
  tunnels, SMB mounts, and configuration state

### Modified Capabilities

<!-- No existing capabilities are being modified -->

## Impact

- **New file**: `client/status.sh` - main status script
- **Reads from**: `~/.jb-gateway/pids/tunnel_*.pid` - HTTP proxy tunnel PIDs
- **Reads from**: `~/.jb-gateway/logs/` - log files for status context
- **Reads from**: `client/.env` - client configuration
- **Integrates with**: existing `client/proxy.sh` and `client/smb-connect.sh` infrastructure
- **No breaking changes**: purely additive functionality
