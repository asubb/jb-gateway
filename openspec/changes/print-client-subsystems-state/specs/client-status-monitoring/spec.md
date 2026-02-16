## ADDED Requirements

### Requirement: Status script availability

The system SHALL provide a client-side script for checking the operational state of all client subsystems.

#### Scenario: Script location

- **WHEN** user accesses client directory
- **THEN** status.sh script is available in client/ directory

#### Scenario: Script execution

- **WHEN** user runs ./client/status.sh
- **THEN** system displays comprehensive status of all client subsystems

#### Scenario: Script permissions

- **WHEN** status script is checked
- **THEN** script has executable permissions

### Requirement: HTTP proxy tunnel status

The system SHALL display the status of all HTTP proxy tunnels.

#### Scenario: Active tunnels display

- **WHEN** HTTP proxy tunnels are running
- **THEN** status shows each active tunnel with port number and PID

#### Scenario: Tunnel uptime information

- **WHEN** tunnels are active
- **THEN** status displays how long each tunnel has been running

#### Scenario: Tunnel process verification

- **WHEN** PID files exist for tunnels
- **THEN** status verifies each PID is actually running

#### Scenario: No active tunnels

- **WHEN** no HTTP proxy tunnels are running
- **THEN** status clearly indicates no tunnels are active

#### Scenario: Stale PID detection

- **WHEN** PID file exists but process is not running
- **THEN** status marks tunnel as stale/inactive

### Requirement: SMB connection status

The system SHALL display the status of SMB mounts and connections.

#### Scenario: Active mounts display

- **WHEN** SMB shares are mounted
- **THEN** status shows mount point, share name, and host

#### Scenario: Mount verification

- **WHEN** checking SMB status
- **THEN** status verifies mount points are actually accessible

#### Scenario: No active mounts

- **WHEN** no SMB shares are mounted
- **THEN** status clearly indicates no mounts are active

#### Scenario: Mount health check

- **WHEN** mount exists
- **THEN** status indicates if mount is healthy or stale

### Requirement: Configuration display

The system SHALL display relevant configuration from environment files.

#### Scenario: Proxy configuration display

- **WHEN** client/.env contains PROXY_PORTS
- **THEN** status shows configured proxy ports

#### Scenario: SSH configuration display

- **WHEN** client/.env contains SSH connection settings
- **THEN** status shows SSH_HOST, SSH_PORT, SSH_USER

#### Scenario: SMB configuration display

- **WHEN** client/.env contains SMB settings
- **THEN** status shows SMB_HOST, SMB_USER

#### Scenario: Missing configuration

- **WHEN** client/.env does not exist
- **THEN** status indicates using default configuration

#### Scenario: Configuration file location

- **WHEN** displaying configuration
- **THEN** status shows which .env file is being used

### Requirement: Subsystem summary

The system SHALL provide a summary of active vs. configured subsystems.

#### Scenario: Active vs configured comparison

- **WHEN** displaying status
- **THEN** status shows count of active tunnels vs configured ports

#### Scenario: Overall health indicator

- **WHEN** displaying status
- **THEN** status provides overall health indicator (OK, warnings, errors)

#### Scenario: Missing subsystems notification

- **WHEN** configured subsystems are not running
- **THEN** status highlights which configured items are inactive

### Requirement: Status output formatting

The system SHALL format status output for readability.

#### Scenario: Structured output

- **WHEN** status is displayed
- **THEN** output is organized into clear sections for each subsystem

#### Scenario: Header sections

- **WHEN** displaying status
- **THEN** each subsystem has a clear header (e.g., "HTTP Proxy Tunnels", "SMB Mounts")

#### Scenario: Status indicators

- **WHEN** showing subsystem status
- **THEN** visual indicators (symbols, colors) distinguish active/inactive/error states

#### Scenario: Aligned columns

- **WHEN** displaying tabular data
- **THEN** columns are aligned for easy reading

### Requirement: PID file reading

The system SHALL read and validate PID files for running subsystems.

#### Scenario: PID file location

- **WHEN** checking for running tunnels
- **THEN** status reads from ~/.jb-gateway/pids/tunnel_*.pid

#### Scenario: PID validation

- **WHEN** PID is read from file
- **THEN** status verifies process exists with that PID

#### Scenario: PID file parsing

- **WHEN** reading PID files
- **THEN** status handles malformed or empty PID files gracefully

### Requirement: Log file awareness

The system SHALL reference log file locations for troubleshooting.

#### Scenario: Log location display

- **WHEN** displaying status
- **THEN** status shows path to relevant log files

#### Scenario: Recent errors indication

- **WHEN** log files contain recent errors
- **THEN** status indicates errors exist and where to find them

### Requirement: Platform compatibility

The system SHALL work on both macOS and Linux platforms.

#### Scenario: macOS compatibility

- **WHEN** status script runs on macOS
- **THEN** all status checks work correctly

#### Scenario: Linux compatibility

- **WHEN** status script runs on Linux
- **THEN** all status checks work correctly

#### Scenario: Platform-specific commands

- **WHEN** checking mounts or processes
- **THEN** status uses appropriate commands for detected platform

### Requirement: Error handling

The system SHALL handle errors gracefully when checking status.

#### Scenario: Missing directories

- **WHEN** ~/.jb-gateway directory does not exist
- **THEN** status reports no subsystems are active

#### Scenario: Permission errors

- **WHEN** unable to read PID or log files
- **THEN** status reports permission issue with clear message

#### Scenario: Partial status availability

- **WHEN** some status checks fail
- **THEN** status displays available information and notes failures

### Requirement: No side effects

The system SHALL only read state without modifying any subsystems.

#### Scenario: Read-only operations

- **WHEN** status script executes
- **THEN** no PID files, tunnels, or mounts are created or modified

#### Scenario: Safe to run repeatedly

- **WHEN** status script runs multiple times
- **THEN** each execution produces consistent results without side effects
