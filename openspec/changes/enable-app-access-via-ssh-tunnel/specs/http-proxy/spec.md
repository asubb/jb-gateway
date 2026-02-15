## ADDED Requirements

### Requirement: Proxy destination configuration
The system SHALL support configuring proxy destination for each port (host network or container localhost).

#### Scenario: Default destination
- **WHEN** no destination is configured for a port
- **THEN** system defaults to host network destination for backward compatibility

#### Scenario: Container localhost destination
- **WHEN** port is configured with CONTAINER_LOCALHOST destination
- **THEN** system routes proxy traffic to container's localhost

#### Scenario: Host network destination
- **WHEN** port is configured with HOST_NETWORK destination
- **THEN** system routes proxy traffic to remote host network

#### Scenario: Per-port destination configuration
- **WHEN** user configures multiple ports with different destinations
- **THEN** system routes each port to its configured destination independently

### Requirement: Destination configuration in environment file
The system SHALL support configuring proxy destinations via .env file.

#### Scenario: PROXY_DESTINATIONS configuration
- **WHEN** PROXY_DESTINATIONS is set in client/.env
- **THEN** system parses destination configuration for each port

#### Scenario: Destination format
- **WHEN** PROXY_DESTINATIONS contains "3000:CONTAINER_LOCALHOST,80:HOST_NETWORK"
- **THEN** port 3000 routes to container localhost and port 80 routes to host network

#### Scenario: Missing destination for port
- **WHEN** port has no destination specified in PROXY_DESTINATIONS
- **THEN** system uses default HOST_NETWORK destination

### Requirement: Container localhost routing
The system SHALL route requests to container's localhost when configured.

#### Scenario: Localhost SSH tunnel
- **WHEN** tunnel is established with CONTAINER_LOCALHOST destination
- **THEN** client SSH command uses localhost as target instead of host.docker.internal

#### Scenario: Localhost port forwarding
- **WHEN** request reaches gateway for CONTAINER_LOCALHOST port
- **THEN** gateway forwards to 127.0.0.1 on container

#### Scenario: Localhost service accessibility
- **WHEN** application listens on container's localhost
- **THEN** client can access application through proxy tunnel

## MODIFIED Requirements

### Requirement: Configuration via environment file
The system SHALL support configuring proxy settings via .env file.

#### Scenario: Load configuration from .env
- **WHEN** client/.env file exists
- **THEN** proxy script loads configuration values from file

#### Scenario: PROXY_PORTS configuration
- **WHEN** PROXY_PORTS is set in client/.env
- **THEN** system uses configured ports as default

#### Scenario: SSH connection settings
- **WHEN** SSH_PORT, SSH_USER, SSH_HOST, SSH_PASSWORD are in client/.env
- **THEN** system uses these values for SSH connection to gateway

#### Scenario: PROXY_DESTINATIONS configuration
- **WHEN** PROXY_DESTINATIONS is set in client/.env
- **THEN** system uses configured destinations for proxy routing

### Requirement: Double SSH hop architecture
The system SHALL route HTTP requests through the gateway container to configured destination.

#### Scenario: SSH to gateway
- **WHEN** tunnel is established
- **THEN** client connects to jb-gateway container via SSH

#### Scenario: Gateway to remote host
- **WHEN** request reaches gateway with HOST_NETWORK destination
- **THEN** gateway forwards request to remote host network

#### Scenario: Gateway to container localhost
- **WHEN** request reaches gateway with CONTAINER_LOCALHOST destination
- **THEN** gateway forwards request to container's localhost

#### Scenario: Response routing
- **WHEN** destination responds
- **THEN** response travels back through gateway to client
