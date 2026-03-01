## ADDED Requirements

### Requirement: Installation manifest consumption
The system SHALL read and apply installation manifest during container configuration.

#### Scenario: Manifest file discovery
- **WHEN** container build or startup process begins
- **THEN** system locates and loads installation manifest file

#### Scenario: Manifest-driven configuration
- **WHEN** installation manifest is loaded
- **THEN** system configures container based on manifest declarations (software, mounts, ports)

#### Scenario: Manifest validation
- **WHEN** installation manifest is loaded
- **THEN** system validates manifest schema and reports errors before proceeding

## MODIFIED Requirements

### Requirement: Container image build
The system SHALL provide a script to build the Docker container image with all required dependencies and tools.

#### Scenario: Building container image
- **WHEN** user runs the build script
- **THEN** system creates a Docker image named 'jb-gateway:latest' with all development tools installed

#### Scenario: Build includes tools from manifest
- **WHEN** container image is built
- **THEN** image includes all software packages declared in installation manifest

### Requirement: Additional directory mounting
The system SHALL support mounting additional host directories into the container.

#### Scenario: Manifest-driven directory mounts
- **WHEN** installation manifest declares directory mounts
- **THEN** system mounts each declared directory from host `~/.jb-gateway/<subdirectory>` to specified container path

#### Scenario: Legacy HOST_DIRS support
- **WHEN** HOST_DIRS is configured in host.env
- **THEN** system continues to support legacy mount format for backwards compatibility

#### Scenario: Combined mount sources
- **WHEN** both manifest mounts and HOST_DIRS are configured
- **THEN** system applies mounts from both sources

### Requirement: Port exposure
The system SHALL expose container ports to the host for external access to services.

#### Scenario: Manifest-driven port exposure
- **WHEN** installation manifest declares exposed ports
- **THEN** system maps each declared port between container and host

#### Scenario: Port metadata usage
- **WHEN** ports are exposed from manifest
- **THEN** system uses metadata (purpose, protocol) for logging and documentation

#### Scenario: Legacy port configuration support
- **WHEN** explicit port mappings exist in run script or host.env
- **THEN** system continues to support legacy configuration for backwards compatibility
