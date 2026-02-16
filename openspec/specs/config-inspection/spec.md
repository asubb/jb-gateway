## Purpose

Configuration inspection utilities for displaying active configuration values and file locations

## Requirements

### Requirement: jbg command dispatcher
The system SHALL provide a `jbg` command that dispatches to subcommands.

#### Scenario: Execute server subcommands
- **WHEN** user runs `jbg server <subcommand>`
- **THEN** system dispatches to appropriate server subcommand handler

#### Scenario: Execute client subcommands
- **WHEN** user runs `jbg client <subcommand>`
- **THEN** system dispatches to appropriate client subcommand handler

#### Scenario: Show help for invalid usage
- **WHEN** user runs `jbg` without arguments or with invalid arguments
- **THEN** system displays usage help showing available subcommands

### Requirement: Server configuration display
The system SHALL provide `jbg server config` command to display server configuration.

#### Scenario: Show server config file location
- **WHEN** user runs `jbg server config`
- **THEN** system shows path to server/host.env with existence indicator

#### Scenario: Display server configuration values
- **WHEN** user runs `jbg server config`
- **THEN** system displays current values from server/host.env (PROJECTS_DIR, HOST_DIRS, CONTAINER_ENV, SMB_ENABLED, etc.)

#### Scenario: Indicate server config file exists
- **WHEN** server/host.env exists and is readable
- **THEN** system displays path with green checkmark indicator

#### Scenario: Indicate server config file missing
- **WHEN** server/host.env does not exist
- **THEN** system displays path with yellow warning and indicates defaults are used

### Requirement: Client configuration display
The system SHALL provide `jbg client config` command to display client configuration.

#### Scenario: Show client config file location
- **WHEN** user runs `jbg client config`
- **THEN** system shows path to client/.env with existence indicator

#### Scenario: Display client configuration values
- **WHEN** user runs `jbg client config`
- **THEN** system displays current values from client/.env (SSH_HOST, SSH_PORT, SSH_USER, PROXY_PORTS, SMB_HOST, SMB_USER)

#### Scenario: Show client runtime directories
- **WHEN** user runs `jbg client config`
- **THEN** system shows paths to PID directory and log directory with existence indicators

#### Scenario: Indicate client config file exists
- **WHEN** client/.env exists and is readable
- **THEN** system displays path with green checkmark indicator

#### Scenario: Indicate client config file missing
- **WHEN** client/.env does not exist
- **THEN** system displays path with yellow warning and indicates defaults are used

### Requirement: Configuration output formatting
The system SHALL format configuration output with clear section organization.

#### Scenario: Files section in output
- **WHEN** displaying configuration
- **THEN** system shows "Configuration Files:" section with file paths and existence indicators

#### Scenario: Values section in output
- **WHEN** displaying configuration
- **THEN** system shows "Current Values:" section with key-value pairs

#### Scenario: Directories section for client
- **WHEN** displaying client configuration
- **THEN** system shows "Runtime Directories:" section with directory paths

### Requirement: Consistent visual formatting
The system SHALL use consistent visual indicators across all config commands.

#### Scenario: Use status.sh color scheme
- **WHEN** displaying configuration information
- **THEN** system uses same colors as status.sh (green/yellow/cyan with ANSI codes)

#### Scenario: Use status.sh symbols
- **WHEN** displaying configuration information
- **THEN** system uses same symbols (✓/⚠/ℹ) as status.sh

#### Scenario: Use status.sh separator style
- **WHEN** displaying configuration sections
- **THEN** system uses same separator lines as status.sh
