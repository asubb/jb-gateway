## ADDED Requirements

### Requirement: SSH server availability
The system SHALL run an SSH server within the container accessible from the host.

#### Scenario: SSH server listening
- **WHEN** container starts
- **THEN** SSH server listens on container port 22

#### Scenario: Host port mapping
- **WHEN** SSH server is running
- **THEN** host port 1022 forwards connections to container port 22

### Requirement: Password authentication
The system SHALL support SSH password authentication with default credentials.

#### Scenario: Default credentials
- **WHEN** user connects via SSH
- **THEN** system accepts username 'jb-gateway' with password 'password'

#### Scenario: Authentication failure
- **WHEN** user provides incorrect credentials
- **THEN** SSH server rejects the connection

### Requirement: SSH key persistence
The system SHALL persist SSH host keys across container restarts.

#### Scenario: Host keys on first start
- **WHEN** container starts for the first time
- **THEN** SSH server generates and stores host keys in cache volume

#### Scenario: Host keys on subsequent starts
- **WHEN** container restarts
- **THEN** SSH server reuses existing host keys from cache volume

#### Scenario: Consistent host fingerprint
- **WHEN** user connects after container restart
- **THEN** SSH host fingerprint remains unchanged

### Requirement: User SSH key support
The system SHALL support SSH public key authentication.

#### Scenario: Authorized keys file
- **WHEN** user places SSH public key in ~/.ssh/authorized_keys
- **THEN** system allows key-based authentication with corresponding private key

#### Scenario: Key-based login
- **WHEN** user connects with valid SSH key
- **THEN** system authenticates without requiring password

### Requirement: Shell environment
The system SHALL provide a fully configured bash shell environment for SSH sessions.

#### Scenario: Default shell
- **WHEN** user connects via SSH
- **THEN** system starts a bash shell session

#### Scenario: Shell initialization
- **WHEN** bash shell starts
- **THEN** system sources ~/.bashrc with user configuration and tool initialization

#### Scenario: Interactive features
- **WHEN** user works in SSH session
- **THEN** shell provides command history, tab completion, and aliases

### Requirement: JetBrains Gateway compatibility
The system SHALL be compatible with JetBrains Gateway for remote development.

#### Scenario: Gateway connection
- **WHEN** user configures JetBrains Gateway with host localhost, port 1022
- **THEN** Gateway successfully connects and establishes remote development session

#### Scenario: Project access from Gateway
- **WHEN** user opens project in Gateway
- **THEN** Gateway can access and modify files in /home/jb-gateway/projects directory

#### Scenario: IDE backend deployment
- **WHEN** Gateway connects
- **THEN** system allows Gateway to deploy and run IDE backend processes

### Requirement: Multiple concurrent sessions
The system SHALL support multiple simultaneous SSH connections.

#### Scenario: Multiple users
- **WHEN** multiple SSH clients connect simultaneously
- **THEN** system accepts all connections without conflict

#### Scenario: Session isolation
- **WHEN** multiple sessions are active
- **THEN** each session maintains independent shell state and working directory

### Requirement: SSH connection security
The system SHALL enforce SSH security best practices within container context.

#### Scenario: Protocol version
- **WHEN** SSH client negotiates connection
- **THEN** server requires SSH protocol version 2

#### Scenario: Root login disabled
- **WHEN** user attempts to SSH as root with password
- **THEN** server rejects the connection

### Requirement: Standard SSH port on host
The system SHALL expose SSH on a non-standard host port to avoid conflicts.

#### Scenario: Non-standard port selection
- **WHEN** container starts
- **THEN** SSH is accessible on host port 1022, not port 22

#### Scenario: Port conflict avoidance
- **WHEN** host already has SSH service on port 22
- **THEN** container SSH service does not conflict with host SSH

### Requirement: SSH subsystem support
The system SHALL support SSH subsystems required for remote development tools.

#### Scenario: SFTP subsystem
- **WHEN** client requests SFTP subsystem
- **THEN** server provides SFTP functionality for file transfers

#### Scenario: SCP support
- **WHEN** user runs scp command to container
- **THEN** system successfully transfers files
