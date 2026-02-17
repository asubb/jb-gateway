## MODIFIED Requirements

### Requirement: SSH key persistence
The system SHALL persist SSH host keys and support optional profile-specific client keys.

#### Scenario: Host keys on first start
- **WHEN** container starts for the first time
- **THEN** SSH server generates and stores host keys in cache volume

#### Scenario: Host keys on subsequent starts
- **WHEN** container restarts
- **THEN** SSH server reuses existing host keys from cache volume

#### Scenario: Consistent host fingerprint
- **WHEN** user connects after container restart
- **THEN** SSH host fingerprint remains unchanged

#### Scenario: Profile-specific client keys
- **WHEN** profile is specified via `--profile <name>`
- **THEN** client uses SSH keys from `~/.jb-gateway/profiles/<name>/ssh/` directory
- **AND** keys are isolated from other profiles
- **AND** key permissions are enforced (0600 for private keys)

#### Scenario: Default client keys
- **WHEN** no profile is specified
- **THEN** client uses default SSH key locations (existing behavior)

### Requirement: User SSH key support
The system SHALL support SSH public key authentication with optional profile-specific key isolation.

#### Scenario: Authorized keys file
- **WHEN** user places SSH public key in ~/.ssh/authorized_keys
- **THEN** system allows key-based authentication with corresponding private key

#### Scenario: Key-based login
- **WHEN** user connects with valid SSH key
- **THEN** system authenticates without requiring password

#### Scenario: Profile-specific key usage
- **WHEN** profile connects via SSH tunnel
- **THEN** system uses private key from `~/.jb-gateway/profiles/<name>/ssh/id_rsa` or similar
- **AND** falls back to system default key locations if profile key missing

#### Scenario: Default key usage
- **WHEN** no profile is specified
- **THEN** system uses default SSH keys from standard locations

## ADDED Requirements

### Requirement: Profile-aware SSH tunnel management
The system SHALL establish and track SSH tunnels with optional profile isolation.

#### Scenario: Profile-specific tunnel establishment
- **WHEN** user runs `client/proxy.sh --profile <name>` to establish tunnels
- **THEN** system establishes SSH tunnel with profile-specific configuration
- **AND** stores tunnel PIDs in `~/.jb-gateway/profiles/<name>/state/tunnel_PORT.pid`
- **AND** writes tunnel logs to `~/.jb-gateway/profiles/<name>/logs/tunnel_PORT_YYYYMMDD_HHMMSS.log`

#### Scenario: Default tunnel establishment
- **WHEN** user runs `client/proxy.sh` without `--profile`
- **THEN** system establishes SSH tunnel using default paths
- **AND** stores tunnel PIDs in `~/.jb-gateway/proxy/proxy_PORT.pid` (existing location)
- **AND** writes tunnel logs to `~/.jb-gateway/logs/tunnel_PORT_YYYYMMDD_HHMMSS.log` (existing location)

#### Scenario: Concurrent profile tunnels
- **WHEN** multiple profiles establish SSH tunnels concurrently
- **THEN** each tunnel operates independently with separate PIDs
- **AND** tunnels use profile-specific SSH keys
- **AND** no conflicts occur between profile tunnels

#### Scenario: Profile tunnel status check
- **WHEN** user checks connection status with `--profile <name>`
- **THEN** system reads PID file from profile state directory
- **AND** validates tunnel process is running
- **AND** reports tunnel status for that profile only

### Requirement: Profile-specific SSH configuration
The system SHALL support optional profile-isolated SSH configuration.

#### Scenario: Profile SSH config loading
- **WHEN** profile establishes SSH tunnel
- **THEN** reads SSH config from `~/.jb-gateway/profiles/<name>/ssh/config` if it exists
- **AND** applies profile-specific settings (key files, host aliases, etc.)

#### Scenario: Default SSH config loading
- **WHEN** no profile is specified
- **THEN** uses default SSH configuration (existing behavior)

#### Scenario: Profile SSH directory initialization
- **WHEN** profile directory is auto-created
- **THEN** system creates `~/.jb-gateway/profiles/<name>/ssh/` directory
- **AND** sets appropriate permissions (0700)
