## Purpose

Docker CLI access within container connected to host Docker daemon

## Requirements

### Requirement: Docker CLI availability
The system SHALL provide Docker CLI tools within the container.

#### Scenario: Docker command available
- **WHEN** user runs 'docker' command in container
- **THEN** system executes the Docker CLI

#### Scenario: Docker version command
- **WHEN** user runs 'docker --version'
- **THEN** system displays installed Docker CLI version

### Requirement: Host Docker daemon connection
The system SHALL connect container Docker CLI to the host's Docker daemon.

#### Scenario: Docker socket access
- **WHEN** Docker CLI executes commands
- **THEN** commands are sent to host Docker daemon via mounted socket

#### Scenario: Docker daemon connectivity
- **WHEN** user runs 'docker info'
- **THEN** system displays information about host's Docker daemon

### Requirement: Container management from within container
The system SHALL allow managing Docker containers from within the gateway container.

#### Scenario: List running containers
- **WHEN** user runs 'docker ps'
- **THEN** system displays all containers running on the host

#### Scenario: Start new container
- **WHEN** user runs 'docker run' command
- **THEN** system starts new container on the host Docker daemon

#### Scenario: Stop containers
- **WHEN** user runs 'docker stop' with container ID
- **THEN** system stops the specified container on host

#### Scenario: Remove containers
- **WHEN** user runs 'docker rm' with container ID
- **THEN** system removes the specified container from host

### Requirement: Image management
The system SHALL allow building and managing Docker images from within the container.

#### Scenario: Build images
- **WHEN** user runs 'docker build' with Dockerfile
- **THEN** system builds image on host Docker daemon

#### Scenario: Pull images
- **WHEN** user runs 'docker pull' with image name
- **THEN** system downloads image to host Docker daemon

#### Scenario: List images
- **WHEN** user runs 'docker images'
- **THEN** system displays all images on host

#### Scenario: Remove images
- **WHEN** user runs 'docker rmi' with image ID
- **THEN** system removes image from host

### Requirement: Docker Compose support
The system SHALL support Docker Compose operations from within the container.

#### Scenario: Docker Compose available
- **WHEN** user runs 'docker compose' command
- **THEN** system executes Docker Compose CLI

#### Scenario: Multi-container applications
- **WHEN** user runs 'docker compose up' with compose file
- **THEN** system starts defined services on host

#### Scenario: Service management
- **WHEN** user runs 'docker compose down'
- **THEN** system stops and removes composed services on host

### Requirement: Volume management
The system SHALL allow managing Docker volumes from within the container.

#### Scenario: List volumes
- **WHEN** user runs 'docker volume ls'
- **THEN** system displays all volumes on host

#### Scenario: Create volumes
- **WHEN** user runs 'docker volume create'
- **THEN** system creates new volume on host

#### Scenario: Remove volumes
- **WHEN** user runs 'docker volume rm' with volume name
- **THEN** system removes volume from host

### Requirement: Network management
The system SHALL allow managing Docker networks from within the container.

#### Scenario: List networks
- **WHEN** user runs 'docker network ls'
- **THEN** system displays all networks on host

#### Scenario: Create networks
- **WHEN** user runs 'docker network create'
- **THEN** system creates new network on host

#### Scenario: Connect containers to networks
- **WHEN** user runs 'docker network connect'
- **THEN** system connects specified container to network

### Requirement: Container logs access
The system SHALL allow viewing logs of containers running on the host.

#### Scenario: View container logs
- **WHEN** user runs 'docker logs' with container ID
- **THEN** system displays logs from the specified container

#### Scenario: Follow logs
- **WHEN** user runs 'docker logs -f' with container ID
- **THEN** system streams real-time logs from the container

### Requirement: Container execution
The system SHALL allow executing commands in other containers from within the gateway container.

#### Scenario: Execute command in container
- **WHEN** user runs 'docker exec' with container ID and command
- **THEN** system executes command in specified container

#### Scenario: Interactive shell in container
- **WHEN** user runs 'docker exec -it' with container ID and shell
- **THEN** system provides interactive shell session in specified container

### Requirement: Docker permissions for jb-gateway user
The system SHALL grant Docker access to the jb-gateway user without requiring sudo.

#### Scenario: Non-root Docker access
- **WHEN** jb-gateway user runs Docker commands
- **THEN** commands execute successfully without permission errors

#### Scenario: Docker socket permissions
- **WHEN** Docker socket is mounted
- **THEN** jb-gateway user has read/write access to the socket
