## ADDED Requirements

### Requirement: Container isolation
The system SHALL use Docker containerization to isolate processes from the host system.

#### Scenario: Process isolation
- **WHEN** processes run within container
- **THEN** processes cannot directly access host filesystem outside mounted volumes

#### Scenario: Network isolation
- **WHEN** container network is configured
- **THEN** container processes cannot access host network interfaces except via configured ports

#### Scenario: Resource isolation
- **WHEN** container runs
- **THEN** Docker provides CPU and memory isolation from other host processes

### Requirement: Limited filesystem access
The system SHALL restrict container filesystem access to explicitly mounted directories.

#### Scenario: Projects directory access only
- **WHEN** default configuration is used
- **THEN** container can only access files in mounted projects directory

#### Scenario: Host filesystem protection
- **WHEN** container processes attempt to access unmounted host paths
- **THEN** system prevents access to host filesystem

#### Scenario: Configurable mount points
- **WHEN** HOST_DIRS specifies additional mounts
- **THEN** container gains access only to explicitly configured paths

### Requirement: AI agent blast radius limitation
The system SHALL contain AI agent actions within the container boundary.

#### Scenario: AI agent file operations
- **WHEN** AI agent modifies files
- **THEN** changes are limited to mounted project directories

#### Scenario: AI agent command execution
- **WHEN** AI agent executes commands
- **THEN** commands run within container with limited system access

#### Scenario: AI agent cannot access sensitive host data
- **WHEN** AI agent attempts to access host files
- **THEN** system prevents access to unmounted host directories

### Requirement: Non-root container execution
The system SHALL run container processes as non-root user to limit privilege escalation.

#### Scenario: Default user execution
- **WHEN** container starts
- **THEN** processes run as jb-gateway user (UID 1000), not root

#### Scenario: Limited system operations
- **WHEN** jb-gateway user attempts privileged operations
- **THEN** system denies operations requiring root privileges

#### Scenario: Sudo not available
- **WHEN** user attempts to use sudo
- **THEN** sudo is not installed or configured for jb-gateway user

### Requirement: Controlled host access
The system SHALL require explicit mechanisms for accessing the host system.

#### Scenario: No direct host access
- **WHEN** container is running
- **THEN** processes cannot directly SSH or connect to host without explicit tunnel

#### Scenario: Explicit host-ssh command
- **WHEN** user needs to access host on macOS
- **THEN** user must explicitly use host-ssh command

#### Scenario: Host access auditing
- **WHEN** host-ssh command is used
- **THEN** access is explicit and traceable in command history

### Requirement: Docker daemon access control
The system SHALL provide Docker access while maintaining security boundaries.

#### Scenario: Docker socket access
- **WHEN** Docker socket is mounted
- **THEN** user can manage containers but not escape container isolation

#### Scenario: Docker operations isolated
- **WHEN** user runs Docker commands in container
- **THEN** new containers run on host but inherit host's security policies

### Requirement: Network service exposure control
The system SHALL expose only explicitly configured network services to the host.

#### Scenario: Limited port exposure
- **WHEN** container starts
- **THEN** only configured ports (SSH, SMB, noVNC) are accessible from host

#### Scenario: Service discovery prevention
- **WHEN** services run in container
- **THEN** services not explicitly exposed are not accessible from host network

#### Scenario: Internal services isolation
- **WHEN** processes listen on container-internal ports
- **THEN** ports remain inaccessible from host unless mapped

### Requirement: Credential and secret isolation
The system SHALL isolate credentials and secrets within the container.

#### Scenario: SSH keys in container
- **WHEN** SSH keys are generated or stored in container
- **THEN** keys remain in container's cache volume

#### Scenario: Environment variable isolation
- **WHEN** sensitive data is in environment variables
- **THEN** variables are not exposed to host processes

### Requirement: Safe development environment
The system SHALL provide a recoverable environment for development and experimentation.

#### Scenario: Container destruction and recreation
- **WHEN** container is stopped and removed
- **THEN** user can recreate fresh container without affecting host

#### Scenario: Persistent data in mounted volumes
- **WHEN** container is recreated
- **THEN** only data in mounted volumes persists from previous container

#### Scenario: Cache volume isolation
- **WHEN** cache volume is removed
- **THEN** container starts fresh without affecting host or projects

### Requirement: Resource consumption limits
The system SHALL prevent container processes from consuming all host resources.

#### Scenario: Docker resource constraints
- **WHEN** container runs with Docker defaults
- **THEN** Docker daemon enforces resource limits to prevent host starvation

#### Scenario: Container restart on failure
- **WHEN** container process crashes
- **THEN** Docker restarts container without affecting host stability

### Requirement: Security boundary documentation
The system SHALL clearly document security boundaries and limitations.

#### Scenario: Security model transparency
- **WHEN** user reads documentation
- **THEN** documentation explains what is protected and what is accessible

#### Scenario: Limitation disclosure
- **WHEN** user reviews security features
- **THEN** documentation acknowledges this is development-focused, not production-hardened

#### Scenario: Trust boundary clarity
- **WHEN** configuring the system
- **THEN** user understands Docker daemon access provides significant capabilities
