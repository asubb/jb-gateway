## ADDED Requirements

### Requirement: Build script
The system SHALL provide a script to build the container image.

#### Scenario: Build script location
- **WHEN** user accesses server directory
- **THEN** build.sh script is available

#### Scenario: Image building
- **WHEN** user runs ./server/build.sh
- **THEN** system builds Docker image tagged as jb-gateway:latest

#### Scenario: Dependency installation
- **WHEN** image builds
- **THEN** all required tools and services are installed in image

#### Scenario: Build reproducibility
- **WHEN** build script runs multiple times
- **THEN** each build produces consistent container image

### Requirement: Run script
The system SHALL provide a script to start the container with proper configuration.

#### Scenario: Run script location
- **WHEN** user accesses server directory
- **THEN** run.sh script is available

#### Scenario: Container startup
- **WHEN** user runs ./server/run.sh
- **THEN** system starts container named 'jb-gateway'

#### Scenario: Configuration loading
- **WHEN** run script executes
- **THEN** system loads configuration from host.env if it exists

#### Scenario: Volume mounting
- **WHEN** container starts
- **THEN** run script mounts configured directories and volumes

#### Scenario: Port mapping
- **WHEN** container starts
- **THEN** run script maps all required ports to host

#### Scenario: Environment variables
- **WHEN** container starts
- **THEN** run script injects configured environment variables

### Requirement: Stop script
The system SHALL provide a script to stop and remove the container.

#### Scenario: Stop script location
- **WHEN** user accesses server directory
- **THEN** stop.sh script is available

#### Scenario: Container stopping
- **WHEN** user runs ./server/stop.sh
- **THEN** system stops the jb-gateway container gracefully

#### Scenario: Container removal
- **WHEN** stop script completes
- **THEN** system removes the stopped container

#### Scenario: Volume preservation
- **WHEN** container is stopped and removed
- **THEN** Docker volumes (cache) persist for future use

### Requirement: Container naming
The system SHALL use consistent container naming for management.

#### Scenario: Fixed container name
- **WHEN** container is created
- **THEN** container is named 'jb-gateway'

#### Scenario: Name uniqueness
- **WHEN** container already exists
- **THEN** system prevents creating duplicate container with same name

### Requirement: Restart policy
The system SHALL configure container restart behavior.

#### Scenario: Automatic restart on failure
- **WHEN** container process crashes
- **THEN** Docker automatically restarts the container

#### Scenario: No restart on manual stop
- **WHEN** user stops container via stop script
- **THEN** Docker does not automatically restart it

### Requirement: Health monitoring
The system SHALL support monitoring container health and status.

#### Scenario: Container status check
- **WHEN** user runs 'docker ps' or 'docker ps -a'
- **THEN** system shows jb-gateway container status

#### Scenario: Service availability check
- **WHEN** container is running
- **THEN** configured services are accessible on exposed ports

### Requirement: Configuration file support
The system SHALL support optional configuration via host.env file.

#### Scenario: Configuration file location
- **WHEN** scripts look for configuration
- **THEN** system checks for server/host.env

#### Scenario: Example configuration template
- **WHEN** user needs configuration reference
- **THEN** server/host.env.example provides template

#### Scenario: Default behavior without configuration
- **WHEN** host.env does not exist
- **THEN** scripts use default values

### Requirement: Idempotent operations
The system SHALL handle repeated script executions gracefully.

#### Scenario: Multiple run script executions
- **WHEN** run script is executed while container already exists
- **THEN** system handles the situation without error

#### Scenario: Multiple stop script executions
- **WHEN** stop script is executed on non-existent container
- **THEN** system handles the situation without error

### Requirement: Dockerfile
The system SHALL provide Dockerfile defining the container image.

#### Scenario: Dockerfile location
- **WHEN** build script executes
- **THEN** system uses Dockerfile from src/docker directory

#### Scenario: Base image selection
- **WHEN** Dockerfile builds
- **THEN** image uses appropriate Linux base image

#### Scenario: Multi-stage build support
- **WHEN** build process runs
- **THEN** Dockerfile supports efficient layer caching

### Requirement: Build context
The system SHALL organize build context for efficient image creation.

#### Scenario: Context organization
- **WHEN** build script runs
- **THEN** system uses appropriate build context directory

#### Scenario: File inclusion
- **WHEN** building image
- **THEN** only necessary files are included in build context

### Requirement: Script permissions
The system SHALL ensure scripts have executable permissions.

#### Scenario: Executable build script
- **WHEN** user runs build script
- **THEN** script has execute permission

#### Scenario: Executable run script
- **WHEN** user runs run script
- **THEN** script has execute permission

#### Scenario: Executable stop script
- **WHEN** user runs stop script
- **THEN** script has execute permission
