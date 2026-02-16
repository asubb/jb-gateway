## Why

Users need visibility into what configuration is active and where configuration files can be modified. Currently, configuration values are displayed in status output but the source files and their locations are not clearly indicated, making troubleshooting and customization harder than necessary. Both server and client contexts need this capability.

## What Changes

- Add new `jbg server config` command to display server configuration and file locations
- Add new `jbg client config` command to display client configuration and file locations
- Show paths to configuration files (server/host.env, client/.env) with existence indicators
- Display runtime directories (PID directory, log directory) where applicable
- Provide clear output that shows both current values and their source file locations

## Capabilities

### New Capabilities

- `config-inspection`: Display active configuration values along with the file paths where they can be modified for both server and client contexts

### Modified Capabilities

None - this adds new commands without modifying existing behavior

## Impact

- Creates new `jbg` command infrastructure if not already present
- Adds `server config` and `client config` subcommands
- Server context: displays server/host.env location and container-related settings
- Client context: displays client/.env location and client runtime directories
- No breaking changes to existing status display or other commands
- Improves user experience for configuration management across both server and client
