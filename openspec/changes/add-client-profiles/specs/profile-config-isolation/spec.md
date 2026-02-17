## ADDED Requirements

### Requirement: Profile Directory Structure
The system SHALL support optional profile-based configuration directories.

#### Scenario: No profile specified (default behavior)
- **WHEN** user runs client command without `--profile` flag
- **THEN** system uses `~/.jb-gateway/` directory for all configuration and state
- **AND** behavior is identical to current implementation

#### Scenario: Profile specified
- **WHEN** user runs client command with `--profile <name>` flag
- **THEN** system uses `~/.jb-gateway/profiles/<name>/` directory
- **AND** creates directory structure if it doesn't exist

#### Scenario: Auto-create profile directory
- **WHEN** `--profile <name>` is specified and directory doesn't exist
- **THEN** system creates `~/.jb-gateway/profiles/<name>/`
- **AND** creates subdirectories: `ssh/`, `state/`, `logs/`, `secrets/`
- **AND** sets appropriate directory permissions (0700 for main and secrets)

### Requirement: Configuration File Isolation
The system SHALL isolate configuration files per profile when profile is specified.

#### Scenario: Profile config storage
- **WHEN** profile is specified via `--profile <name>`
- **THEN** SSH keys are stored in `~/.jb-gateway/profiles/<name>/ssh/`
- **AND** proxy configuration is read from `~/.jb-gateway/profiles/<name>/`
- **AND** connection state is stored in `~/.jb-gateway/profiles/<name>/state/`
- **AND** config data is completely isolated from other profiles

#### Scenario: No profile config storage
- **WHEN** no profile is specified
- **THEN** configuration uses `~/.jb-gateway/` paths (current behavior)
- **AND** no profile directory is created or accessed

### Requirement: Profile State Isolation
The system SHALL isolate runtime state between profiles when profiles are used.

#### Scenario: Profile PID file isolation
- **WHEN** profile establishes SSH tunnel or proxy connection
- **THEN** PID files are written to `~/.jb-gateway/profiles/<name>/state/`
- **AND** each profile maintains independent PID tracking

#### Scenario: No profile PID file location
- **WHEN** no profile is specified
- **THEN** PID files use existing `~/.jb-gateway/proxy/` path

#### Scenario: Profile log file isolation
- **WHEN** profile operations generate logs
- **THEN** logs are written to `~/.jb-gateway/profiles/<name>/logs/`

#### Scenario: No profile log file location
- **WHEN** no profile is specified
- **THEN** logs use existing `~/.jb-gateway/logs/` paths

### Requirement: Credential Isolation
The system SHALL ensure credentials and secrets are isolated per profile when profiles are used.

#### Scenario: Profile SSH key isolation
- **WHEN** profile is specified
- **THEN** profile uses SSH keys from `~/.jb-gateway/profiles/<name>/ssh/`
- **AND** SSH keys are never shared across profiles
- **AND** key permissions are enforced (0600 for private keys)

#### Scenario: No profile SSH keys
- **WHEN** no profile is specified
- **THEN** SSH keys use existing locations (system default or `~/.jb-gateway/ssh/`)

#### Scenario: Profile credential storage
- **WHEN** credentials are stored for a profile
- **THEN** secrets are written to `~/.jb-gateway/profiles/<name>/secrets/`
- **AND** directory has restrictive permissions (0700)
- **AND** files have restrictive permissions (0600)
