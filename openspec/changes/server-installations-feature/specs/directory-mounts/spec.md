## ADDED Requirements

### Requirement: Directory mount configuration
The system SHALL configure directory mounts based on installation manifest declarations.

#### Scenario: Mount definition parsing
- **WHEN** manifest includes directory mounts
- **THEN** system parses container path and host subdirectory for each mount

#### Scenario: Host directory path resolution
- **WHEN** mount specifies host subdirectory
- **THEN** system resolves full host path as `~/.jb-gateway/<subdirectory>`

#### Scenario: Multiple mount configuration
- **WHEN** manifest lists multiple directory mounts
- **THEN** system configures all mounts for container

### Requirement: Host directory creation
The system SHALL ensure host directories exist before mounting.

#### Scenario: Directory existence check
- **WHEN** container starts with configured mounts
- **THEN** system checks if host directories exist

#### Scenario: Automatic directory creation
- **WHEN** host directory does not exist
- **THEN** system creates directory at `~/.jb-gateway/<subdirectory>` with appropriate permissions

#### Scenario: Nested directory creation
- **WHEN** host subdirectory path includes nested directories
- **THEN** system creates all necessary parent directories

### Requirement: Mount permissions
The system SHALL apply appropriate permissions to mounted directories.

#### Scenario: Read-write mount
- **WHEN** manifest specifies read-write mount (or no permission specified)
- **THEN** container can read and write files in mounted directory

#### Scenario: Read-only mount
- **WHEN** manifest specifies read-only mount
- **THEN** container can read but not modify files in mounted directory

#### Scenario: Permission persistence
- **WHEN** files are created in mounted directory
- **THEN** files have appropriate ownership for access from both host and container

### Requirement: Mount validation
The system SHALL validate mount configurations before container start.

#### Scenario: Valid mount path
- **WHEN** mount configuration is validated
- **THEN** system verifies container path is absolute and valid

#### Scenario: Host path accessibility
- **WHEN** container starts
- **THEN** system verifies host directory is accessible

#### Scenario: Mount conflict detection
- **WHEN** multiple mounts target same container path
- **THEN** system reports configuration error

### Requirement: Default directory mounts
The system SHALL include standard directory mounts in default configuration.

#### Scenario: Maven cache mount
- **WHEN** default installation manifest is used
- **THEN** container `.m2` directory is mounted to host `~/.jb-gateway/.m2`

#### Scenario: Gradle cache mount
- **WHEN** default installation manifest is used
- **THEN** container `.gradle` directory is mounted to host `~/.jb-gateway/.gradle`

#### Scenario: SDKMAN directory mount
- **WHEN** default installation manifest is used
- **THEN** container `.sdkman` directory is mounted to host `~/.jb-gateway/.sdkman`

### Requirement: Mount runtime behavior
The system SHALL ensure mounted directories function correctly during container operation.

#### Scenario: File synchronization
- **WHEN** files are modified in mounted directory from container
- **THEN** changes are immediately visible on host

#### Scenario: File synchronization from host
- **WHEN** files are modified in host directory
- **THEN** changes are immediately visible in container

#### Scenario: Performance characteristics
- **WHEN** container accesses mounted directories
- **THEN** file operations have acceptable performance

### Requirement: Mount documentation
The system SHALL provide documentation for directory mount configuration.

#### Scenario: Configuration format documentation
- **WHEN** user needs to configure directory mounts
- **THEN** documentation describes mount specification format

#### Scenario: Use case examples
- **WHEN** user needs mount configuration examples
- **THEN** documentation includes common scenarios (caches, config files, data directories)

### Requirement: Mount cleanup
The system SHALL handle mounted directory lifecycle appropriately.

#### Scenario: Host directory persistence
- **WHEN** container is stopped and removed
- **THEN** host directories under `~/.jb-gateway` persist

#### Scenario: Container directory cleanup
- **WHEN** container is removed
- **THEN** container-only files are cleaned up, mounted content remains
