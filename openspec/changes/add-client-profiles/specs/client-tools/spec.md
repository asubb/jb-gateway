## ADDED Requirements

### Requirement: Profile flag support
The system SHALL accept an optional `--profile` flag on all client commands to specify which profile to use.

#### Scenario: Explicit profile specification
- **WHEN** user runs any client command with `--profile <name>` flag
- **THEN** system operates using specified profile's configuration directory
- **AND** uses `~/.jb-gateway/profiles/<name>/` for all config and state

#### Scenario: No profile specified
- **WHEN** user runs client command without `--profile` flag
- **THEN** system uses default `~/.jb-gateway/` directory
- **AND** behavior is identical to current implementation

#### Scenario: Profile directory auto-creation
- **WHEN** user provides `--profile <name>` flag and directory doesn't exist
- **THEN** system automatically creates `~/.jb-gateway/profiles/<name>/` with subdirectories
- **AND** proceeds with command execution using new profile directory

### Requirement: Profile-aware configuration loading
The system SHALL load configuration from profile directory when profile is specified.

#### Scenario: Load config with profile
- **WHEN** client script needs configuration and `--profile` is specified
- **THEN** system reads configuration from `~/.jb-gateway/profiles/<name>/`
- **AND** looks for config files in profile directory
- **AND** falls back to defaults if config files missing

#### Scenario: Load config without profile
- **WHEN** client script needs configuration and no `--profile` is specified
- **THEN** system reads configuration from `~/.jb-gateway/`
- **AND** uses existing default paths and behavior

### Requirement: Configuration display with profile support
The system SHALL display profile-aware configuration information.

#### Scenario: Display config for profile
- **WHEN** user runs `client/config.sh --profile <name>`
- **THEN** system displays profile name
- **AND** shows configuration file location for that profile
- **AND** displays runtime directories for that profile

#### Scenario: Display default config
- **WHEN** user runs `client/config.sh` without `--profile`
- **THEN** system displays "(default)" as profile
- **AND** shows default configuration file locations
- **AND** displays default runtime directories

## MODIFIED Requirements

### Requirement: Client directory organization
The system SHALL organize client-side tools in dedicated client directory with optional profile support.

#### Scenario: Client scripts location
- **WHEN** user accesses project
- **THEN** all client-side scripts are in client/ directory

#### Scenario: Client configuration location without profile
- **WHEN** user needs to configure client tools and doesn't use profiles
- **THEN** configuration is in `~/.jb-gateway/` (existing behavior)

#### Scenario: Client configuration location with profile
- **WHEN** user specifies `--profile <name>`
- **THEN** configuration is in `~/.jb-gateway/profiles/<name>/`
