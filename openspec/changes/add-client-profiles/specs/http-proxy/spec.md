## MODIFIED Requirements

### Requirement: Tunnel lifecycle management
The system SHALL track and manage running proxy tunnels with optional profile isolation.

#### Scenario: Profile PID file creation
- **WHEN** tunnel is established with `--profile <name>`
- **THEN** system stores process ID in `~/.jb-gateway/profiles/<name>/state/tunnel_PORT.pid`

#### Scenario: Default PID file creation
- **WHEN** tunnel is established without profile
- **THEN** system stores process ID in existing default location (`~/.jb-gateway/proxy/proxy_PORT.pid`)

#### Scenario: Profile-specific PID tracking
- **WHEN** different profiles establish tunnels on same port number
- **THEN** each profile tracks its tunnel PID independently in its own directory
- **AND** PIDs are isolated per profile directory
- **AND** no port conflict checking is performed

### Requirement: Logging
The system SHALL log proxy operations with optional profile-specific logs.

#### Scenario: Profile proxy log
- **WHEN** proxy script runs with `--profile <name>`
- **THEN** output is logged to `~/.jb-gateway/profiles/<name>/logs/proxy_YYYYMMDD_HHMMSS.log`

#### Scenario: Default proxy log
- **WHEN** proxy script runs without profile
- **THEN** output is logged to existing default location (`~/.jb-gateway/logs/tunnel_PORT_YYYYMMDD_HHMMSS.log`)

#### Scenario: Profile tunnel logs
- **WHEN** tunnel is established with profile
- **THEN** tunnel output is logged to `~/.jb-gateway/profiles/<name>/logs/tunnel_PORT_YYYYMMDD_HHMMSS.log`

#### Scenario: Default tunnel logs
- **WHEN** tunnel is established without profile
- **THEN** tunnel output is logged to existing default location (`~/.jb-gateway/logs/tunnel_PORT_YYYYMMDD_HHMMSS.log`)

#### Scenario: Console output preservation
- **WHEN** proxy script runs
- **THEN** output is displayed in terminal and saved to log file

## ADDED Requirements

### Requirement: Profile-aware proxy configuration
The system SHALL load proxy configuration from profile-specific directory when profile is specified.

#### Scenario: Load proxy config from profile
- **WHEN** proxy script runs with `--profile <name>`
- **THEN** reads configuration from `~/.jb-gateway/profiles/<name>/`
- **AND** uses profile-specific PROXY_PORTS and PROXY_DESTINATIONS
- **AND** ignores other profiles' proxy configurations

#### Scenario: Load proxy config from default location
- **WHEN** proxy script runs without profile
- **THEN** reads configuration from default location (existing behavior)

#### Scenario: Profile-specific proxy defaults
- **WHEN** profile proxy config is missing values
- **THEN** system uses global defaults
- **AND** logs which defaults are applied

### Requirement: Profile context in proxy scripts
The system SHALL accept optional profile parameter in proxy management scripts.

#### Scenario: Start proxy with profile
- **WHEN** user runs `./client/proxy.sh --profile <name>`
- **THEN** proxy script uses specified profile's configuration
- **AND** stores state and logs in profile directory

#### Scenario: Start proxy without profile
- **WHEN** user runs `./client/proxy.sh` without `--profile`
- **THEN** proxy script uses default configuration and paths (existing behavior)

#### Scenario: Stop proxy for profile
- **WHEN** user runs `./client/proxy-stop.sh --profile <name>`
- **THEN** system stops only tunnels belonging to specified profile
- **AND** cleans up profile-specific PID files

#### Scenario: Stop proxy without profile
- **WHEN** user runs `./client/proxy-stop.sh` without `--profile`
- **THEN** system stops tunnels in default location (existing behavior)
