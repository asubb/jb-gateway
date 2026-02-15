## Purpose

SSH back-channel from container to macOS host for authorized host access

## Requirements

### Requirement: macOS-specific feature
The system SHALL provide host SSH back-channel functionality only on macOS hosts.

#### Scenario: macOS detection
- **WHEN** system runs on macOS
- **THEN** host SSH tunnel feature is enabled by default

#### Scenario: Non-macOS systems
- **WHEN** system runs on non-macOS platforms
- **THEN** host SSH tunnel feature is not available

### Requirement: Standalone SSH server on host
The system SHALL start a separate SSH server process on the macOS host for container back-connections.

#### Scenario: SSH server startup
- **WHEN** container starts on macOS
- **THEN** system starts standalone SSH server on host port 2022

#### Scenario: Dedicated port
- **WHEN** host SSH server runs
- **THEN** server listens on port 2022 to avoid conflict with system SSH on port 22

### Requirement: Container-to-host connectivity
The system SHALL allow the container to establish SSH connections back to the host.

#### Scenario: Host accessibility from container
- **WHEN** container is running
- **THEN** container can connect to host's port 2022

#### Scenario: Host IP resolution
- **WHEN** container needs to connect to host
- **THEN** system uses host.docker.internal or appropriate host IP

### Requirement: host-ssh convenience command
The system SHALL provide a host-ssh command in the container for easy host access.

#### Scenario: host-ssh command available
- **WHEN** user is in container shell
- **THEN** host-ssh command is available

#### Scenario: Automatic connection
- **WHEN** user runs host-ssh command
- **THEN** system establishes SSH connection to host port 2022

#### Scenario: Host shell access
- **WHEN** host-ssh connection succeeds
- **THEN** user has interactive shell on macOS host

### Requirement: Explicit authorization model
The system SHALL require explicit user action to access the host system.

#### Scenario: No automatic host access
- **WHEN** container is running
- **THEN** host access only occurs when user explicitly runs host-ssh

#### Scenario: Traceable access
- **WHEN** user accesses host via host-ssh
- **THEN** command appears in shell history providing audit trail

### Requirement: Configuration-based disable option
The system SHALL support disabling host SSH tunnel via configuration.

#### Scenario: Disable via DISABLE_HOST_SSH
- **WHEN** DISABLE_HOST_SSH is set to true in host.env
- **THEN** system does not start host SSH server

#### Scenario: Feature remains disabled
- **WHEN** host SSH is disabled
- **THEN** host-ssh command in container fails to connect

### Requirement: Host SSH authentication
The system SHALL authenticate container-to-host SSH connections.

#### Scenario: Host credentials
- **WHEN** host SSH server runs
- **THEN** server accepts host user's SSH keys or credentials

#### Scenario: User authentication
- **WHEN** container connects to host
- **THEN** system authenticates using configured credentials

### Requirement: Security boundary awareness
The system SHALL clearly document that host-ssh provides access outside the sandbox.

#### Scenario: Documentation clarity
- **WHEN** user reads documentation
- **THEN** documentation explains host-ssh breaks container isolation

#### Scenario: Intentional design
- **WHEN** user uses host-ssh
- **THEN** user understands this is for authorized host operations

### Requirement: Host SSH server lifecycle
The system SHALL manage host SSH server lifecycle with container lifecycle.

#### Scenario: Start with container
- **WHEN** container starts on macOS
- **THEN** host SSH server starts (unless disabled)

#### Scenario: Stop with container
- **WHEN** container stops
- **THEN** host SSH server is stopped

### Requirement: Network routing
The system SHALL configure container networking to route to host SSH port.

#### Scenario: Docker network configuration
- **WHEN** container starts with host SSH enabled
- **THEN** container can reach host port 2022 through Docker networking

#### Scenario: Port exposure
- **WHEN** host SSH server runs
- **THEN** port 2022 is accessible from container but not necessarily from external network
