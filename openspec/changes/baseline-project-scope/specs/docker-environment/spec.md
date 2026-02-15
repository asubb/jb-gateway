## ADDED Requirements

### Requirement: Container image build
The system SHALL provide a script to build the Docker container image with all required dependencies and tools.

#### Scenario: Building container image
- **WHEN** user runs the build script
- **THEN** system creates a Docker image named 'jb-gateway:latest' with all development tools installed

#### Scenario: Build includes all required tools
- **WHEN** container image is built
- **THEN** image includes git, curl, htop, telnet, jq, yq, Docker CLI, OpenSSH server, Samba, noVNC, and Chromium

### Requirement: Container lifecycle management
The system SHALL provide scripts to start and stop the container with proper configuration.

#### Scenario: Starting container
- **WHEN** user runs the run script
- **THEN** system starts a container named 'jb-gateway' with all configured services

#### Scenario: Stopping container
- **WHEN** user runs the stop script
- **THEN** system stops and removes the 'jb-gateway' container

#### Scenario: Container restarts automatically
- **WHEN** container process exits unexpectedly
- **THEN** Docker restarts the container automatically

### Requirement: Projects directory mounting
The system SHALL mount a configurable host directory into the container for project access.

#### Scenario: Default projects directory mount
- **WHEN** no custom configuration is provided
- **THEN** system mounts ~/projects from host to /home/jb-gateway/projects in container

#### Scenario: Custom projects directory
- **WHEN** PROJECTS_DIR is set in host.env
- **THEN** system mounts the specified directory to /home/jb-gateway/projects in container

#### Scenario: Projects directory is writable
- **WHEN** user modifies files in /home/jb-gateway/projects
- **THEN** changes are immediately visible on the host filesystem

### Requirement: Additional directory mounting
The system SHALL support mounting additional host directories into the container.

#### Scenario: Multiple directory mounts
- **WHEN** HOST_DIRS is configured with multiple paths
- **THEN** system mounts each specified host directory to its corresponding container path

#### Scenario: Directory mount format
- **WHEN** HOST_DIRS contains entries in format /host/path:/container/path
- **THEN** system mounts /host/path from host to /container/path in container

### Requirement: Environment variable injection
The system SHALL support injecting custom environment variables into the container.

#### Scenario: Global environment variables
- **WHEN** CONTAINER_ENV is set in host.env
- **THEN** system makes specified environment variables available to all container processes

#### Scenario: Environment variables persist across sessions
- **WHEN** user opens new SSH session
- **THEN** injected environment variables are available in the session

### Requirement: Persistent cache volume
The system SHALL maintain a persistent Docker volume for caching between container restarts.

#### Scenario: Cache volume creation
- **WHEN** container starts for the first time
- **THEN** system creates a named Docker volume 'jb-gateway-cache'

#### Scenario: Cache persists across restarts
- **WHEN** container is stopped and restarted
- **THEN** cached data from previous session is available

#### Scenario: Cache volume reset
- **WHEN** user removes the cache volume
- **THEN** new container start creates fresh cache volume

### Requirement: SDKMAN directory mounting
The system SHALL mount the host's SDKMAN installation into the container for SDK access.

#### Scenario: SDKMAN directory detection
- **WHEN** ~/.sdkman exists on macOS host
- **THEN** system mounts it to /home/jb-gateway/.sdkman in container

#### Scenario: SDK versions available in container
- **WHEN** SDKMAN directory is mounted
- **THEN** all installed SDKs are accessible within container

### Requirement: Host Docker daemon access
The system SHALL provide container access to the host's Docker daemon for Docker-in-Docker functionality.

#### Scenario: Docker socket mounting
- **WHEN** container starts
- **THEN** system mounts /var/run/docker.sock from host into container

#### Scenario: Docker commands work in container
- **WHEN** user runs Docker commands in container
- **THEN** commands execute against host's Docker daemon

### Requirement: User and permissions
The system SHALL run container processes as a non-root user with appropriate permissions.

#### Scenario: Default user
- **WHEN** user connects to container
- **THEN** session runs as 'jb-gateway' user with UID 1000

#### Scenario: Docker group membership
- **WHEN** jb-gateway user executes Docker commands
- **THEN** user has permission to access Docker socket

#### Scenario: Project directory permissions
- **WHEN** jb-gateway user accesses mounted project directory
- **THEN** user can read and write files without permission errors

### Requirement: Port exposure
The system SHALL expose container ports to the host for external access to services.

#### Scenario: SSH port exposure
- **WHEN** container starts
- **THEN** container port 22 is mapped to host port 1022

#### Scenario: SMB ports exposure
- **WHEN** container starts
- **THEN** container ports 139 and 445 are mapped to host ports 139 and 445

#### Scenario: noVNC port exposure
- **WHEN** container starts
- **THEN** container port 6080 is mapped to host port 6080

### Requirement: Configuration via host.env
The system SHALL support configuration through an optional host.env file.

#### Scenario: Loading configuration
- **WHEN** host.env exists in server directory
- **THEN** system loads configuration values from the file

#### Scenario: Configuration precedence
- **WHEN** host.env defines a value
- **THEN** system uses that value instead of default

#### Scenario: Missing configuration file
- **WHEN** host.env does not exist
- **THEN** system uses default configuration values
