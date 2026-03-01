## ADDED Requirements

### Requirement: Port declaration format
The system SHALL support declaring exposed ports in the installation manifest.

#### Scenario: Container port specification
- **WHEN** manifest includes port declarations
- **THEN** each port includes container port number

#### Scenario: Optional host port mapping
- **WHEN** port declaration includes host port
- **THEN** system maps container port to specified host port

#### Scenario: Automatic host port assignment
- **WHEN** port declaration omits host port
- **THEN** system uses same port number on host as container port

### Requirement: Port metadata
The system SHALL support descriptive metadata for exposed ports.

#### Scenario: Port purpose description
- **WHEN** port is declared in manifest
- **THEN** declaration can include human-readable purpose description

#### Scenario: Protocol specification
- **WHEN** port is declared in manifest
- **THEN** declaration can specify protocol (TCP or UDP)

#### Scenario: Default protocol
- **WHEN** port declaration omits protocol
- **THEN** system defaults to TCP

### Requirement: Port validation
The system SHALL validate port configurations before container start.

#### Scenario: Valid port range
- **WHEN** port is declared
- **THEN** system validates port number is within valid range (1-65535)

#### Scenario: Port conflict detection
- **WHEN** multiple services use same host port
- **THEN** system reports configuration error

#### Scenario: Privileged port warning
- **WHEN** host port is below 1024
- **THEN** system warns that elevated privileges may be required

### Requirement: Default port configuration
The system SHALL include standard service ports in default configuration.

#### Scenario: SSH port
- **WHEN** default installation manifest is used
- **THEN** container port 22 is exposed on host port 1022 for SSH access

#### Scenario: SMB ports
- **WHEN** default installation manifest is used
- **THEN** container ports 139 and 445 are exposed for SMB file sharing

#### Scenario: noVNC port
- **WHEN** default installation manifest is used
- **THEN** container port 6080 is exposed for browser-based remote desktop

#### Scenario: HTTP proxy port
- **WHEN** default installation manifest is used
- **THEN** container port 8888 is exposed for HTTP proxy service

### Requirement: Port exposure configuration
The system SHALL apply port mappings during container startup.

#### Scenario: Port mapping application
- **WHEN** container starts
- **THEN** all declared ports are mapped between container and host

#### Scenario: Port binding verification
- **WHEN** container is running
- **THEN** services are accessible on exposed host ports

#### Scenario: Port binding failure handling
- **WHEN** host port is already in use
- **THEN** container startup fails with clear error message

### Requirement: Dynamic port configuration
The system SHALL support runtime port configuration overrides.

#### Scenario: Environment variable override
- **WHEN** environment variable specifies alternate host port
- **THEN** system uses override instead of manifest default

#### Scenario: Configuration file override
- **WHEN** host.env specifies alternate port mappings
- **THEN** system applies configuration file values

### Requirement: Port documentation
The system SHALL provide documentation for port configuration.

#### Scenario: Port usage documentation
- **WHEN** user needs to understand exposed ports
- **THEN** documentation lists all default ports with their purposes

#### Scenario: Custom port configuration guide
- **WHEN** user needs to customize port mappings
- **THEN** documentation explains override mechanisms

#### Scenario: Port conflict resolution
- **WHEN** user encounters port conflicts
- **THEN** documentation provides troubleshooting steps

### Requirement: Port introspection
The system SHALL provide tools to inspect current port configuration.

#### Scenario: List exposed ports
- **WHEN** user queries container configuration
- **THEN** system displays all port mappings with metadata

#### Scenario: Port accessibility check
- **WHEN** user tests port configuration
- **THEN** system verifies each port is accessible from host
