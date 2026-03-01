## ADDED Requirements

### Requirement: Installation validation on startup
The system SHALL validate installation requirements when container starts.

#### Scenario: Software verification check
- **WHEN** container starts
- **THEN** system verifies all software packages from manifest are installed and accessible

#### Scenario: Directory mount verification
- **WHEN** container starts
- **THEN** system verifies all declared directory mounts are properly configured

#### Scenario: Port availability verification
- **WHEN** container starts
- **THEN** system verifies services are listening on declared ports

#### Scenario: Validation failure reporting
- **WHEN** installation validation detects issues
- **THEN** system logs detailed error messages with remediation suggestions

## MODIFIED Requirements

### Requirement: Build script
The system SHALL provide a script to build the container image.

#### Scenario: Build script location
- **WHEN** user accesses server directory
- **THEN** build.sh script is available

#### Scenario: Image building
- **WHEN** user runs ./server/build.sh
- **THEN** system builds Docker image tagged as jb-gateway:latest

#### Scenario: Dependency installation from manifest
- **WHEN** image builds
- **THEN** all tools and services declared in installation manifest are installed

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
- **THEN** system loads configuration from host.env and installation manifest

#### Scenario: Volume mounting from manifest
- **WHEN** container starts
- **THEN** run script mounts directories declared in installation manifest

#### Scenario: Port mapping from manifest
- **WHEN** container starts
- **THEN** run script maps ports declared in installation manifest

#### Scenario: Environment variables
- **WHEN** container starts
- **THEN** run script injects configured environment variables
