## ADDED Requirements

### Requirement: HTTP proxy script availability
The system SHALL provide a client-side script for establishing HTTP proxy tunnels through the gateway.

#### Scenario: Proxy script location
- **WHEN** user accesses client directory
- **THEN** proxy.sh script is available

#### Scenario: Proxy script execution
- **WHEN** user runs ./client/proxy.sh
- **THEN** system establishes proxy tunnels

### Requirement: Multi-port tunneling
The system SHALL support tunneling multiple HTTP ports simultaneously.

#### Scenario: Single port tunnel
- **WHEN** user specifies single port with -p flag
- **THEN** system creates tunnel for specified port

#### Scenario: Multiple port tunnels
- **WHEN** user specifies comma-separated ports with -p flag
- **THEN** system creates separate tunnel for each port

#### Scenario: Port range tunneling
- **WHEN** user specifies port range like 8080-8085
- **THEN** system creates tunnels for all ports in range

#### Scenario: Mixed port specification
- **WHEN** user specifies "8080,8081,8082-8085"
- **THEN** system creates tunnels for ports 8080, 8081, 8082, 8083, 8084, 8085

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

### Requirement: Command-line configuration
The system SHALL support overriding configuration via command-line arguments.

#### Scenario: Port override
- **WHEN** user specifies -p flag
- **THEN** command-line ports override .env PROXY_PORTS

#### Scenario: SSH port override
- **WHEN** user specifies -s or --ssh-port flag
- **THEN** command-line value overrides .env SSH_PORT

#### Scenario: User and password override
- **WHEN** user specifies -u and -w flags
- **THEN** command-line values override .env settings

### Requirement: Duplicate tunnel prevention
The system SHALL prevent creating duplicate tunnels for the same port.

#### Scenario: Existing tunnel detection
- **WHEN** tunnel already exists for a port
- **THEN** system skips creating new tunnel for that port

#### Scenario: PID file validation
- **WHEN** PID file exists for a port
- **THEN** system verifies process is actually running before skipping

#### Scenario: Stale PID cleanup
- **WHEN** PID file exists but process is not running
- **THEN** system creates new tunnel and updates PID file

#### Scenario: Process verification
- **WHEN** checking for existing tunnel
- **THEN** system verifies process details match expected tunnel configuration

### Requirement: Background tunnel execution
The system SHALL run proxy tunnels in the background without blocking the terminal.

#### Scenario: Background tunnel process
- **WHEN** proxy script establishes tunnels
- **THEN** each tunnel runs as background process

#### Scenario: Terminal availability
- **WHEN** tunnels are established
- **THEN** user can continue using terminal for other commands

#### Scenario: Multiple script invocations
- **WHEN** user runs proxy script multiple times
- **THEN** only new tunnels are created, existing ones continue running

### Requirement: Tunnel lifecycle management
The system SHALL track and manage running proxy tunnels.

#### Scenario: PID file creation
- **WHEN** tunnel is established
- **THEN** system stores process ID in ~/.jb-gateway/pids/tunnel_PORT.pid

#### Scenario: PID file location
- **WHEN** multiple tunnels run
- **THEN** each has separate PID file with port number in filename

### Requirement: Proxy stop functionality
The system SHALL provide script to stop all running proxy tunnels.

#### Scenario: Stop all tunnels
- **WHEN** user runs ./client/proxy-stop.sh
- **THEN** system terminates all proxy tunnels

#### Scenario: PID file cleanup
- **WHEN** tunnels are stopped
- **THEN** system removes corresponding PID files

### Requirement: Logging
The system SHALL log proxy operations for troubleshooting.

#### Scenario: Main proxy log
- **WHEN** proxy script runs
- **THEN** output is logged to ~/.jb-gateway/logs/proxy_YYYYMMDD_HHMMSS.log

#### Scenario: Individual tunnel logs
- **WHEN** tunnel is established
- **THEN** tunnel output is logged to ~/.jb-gateway/logs/tunnel_PORT_YYYYMMDD_HHMMSS.log

#### Scenario: Proxy stop log
- **WHEN** proxy-stop script runs
- **THEN** output is logged to ~/.jb-gateway/logs/proxy-stop_YYYYMMDD_HHMMSS.log

#### Scenario: Console output preservation
- **WHEN** proxy script runs
- **THEN** output is displayed in terminal and saved to log file

### Requirement: SSH tunnel authentication
The system SHALL support password authentication for SSH tunnels via sshpass.

#### Scenario: Password authentication
- **WHEN** SSH_PASSWORD is configured
- **THEN** system uses sshpass for automatic authentication

#### Scenario: Passwordless authentication fallback
- **WHEN** no password is configured
- **THEN** system attempts SSH key-based authentication

### Requirement: Double SSH hop architecture
The system SHALL route HTTP requests through the gateway container to remote host.

#### Scenario: SSH to gateway
- **WHEN** tunnel is established
- **THEN** client connects to jb-gateway container via SSH

#### Scenario: Gateway to remote host
- **WHEN** request reaches gateway container
- **THEN** gateway forwards request to remote host network

#### Scenario: Response routing
- **WHEN** remote host responds
- **THEN** response travels back through gateway to client

### Requirement: Help documentation
The system SHALL provide usage help for the proxy script.

#### Scenario: Help flag
- **WHEN** user runs ./client/proxy.sh -h or --help
- **THEN** system displays usage instructions and available options
