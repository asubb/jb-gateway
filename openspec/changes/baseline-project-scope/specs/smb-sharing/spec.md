## ADDED Requirements

### Requirement: Samba server availability
The system SHALL run a Samba server within the container for network file sharing.

#### Scenario: Samba service running
- **WHEN** container starts
- **THEN** Samba server is running and accepting connections

#### Scenario: SMB ports exposure
- **WHEN** Samba server is configured
- **THEN** container ports 139 and 445 are exposed to host

### Requirement: Projects directory sharing
The system SHALL share the projects directory via SMB protocol.

#### Scenario: Share name
- **WHEN** Samba server is configured
- **THEN** projects directory is shared with name 'projects'

#### Scenario: Share path
- **WHEN** client accesses 'projects' share
- **THEN** share maps to /home/jb-gateway/projects in container

#### Scenario: Bidirectional access
- **WHEN** client modifies files via SMB
- **THEN** changes are reflected in container filesystem and mounted host directory

### Requirement: SMB authentication
The system SHALL require authentication to access SMB shares.

#### Scenario: Default credentials
- **WHEN** client connects to SMB share
- **THEN** system requires username 'jb-gateway' and password 'password'

#### Scenario: Anonymous access denied
- **WHEN** client attempts anonymous connection
- **THEN** system rejects connection without credentials

### Requirement: Multi-platform client support
The system SHALL support SMB clients from Windows, macOS, and Linux.

#### Scenario: Windows client connection
- **WHEN** Windows client connects via \\localhost\projects
- **THEN** system provides access to projects share

#### Scenario: macOS client connection
- **WHEN** macOS client connects via smb://localhost/projects
- **THEN** system provides access to projects share

#### Scenario: Linux client connection
- **WHEN** Linux client connects via smb://localhost/projects
- **THEN** system provides access to projects share

### Requirement: Read and write access
The system SHALL provide read and write access to shared directory for authenticated users.

#### Scenario: File creation
- **WHEN** SMB client creates new file
- **THEN** file appears in container and host filesystem

#### Scenario: File modification
- **WHEN** SMB client modifies existing file
- **THEN** changes are saved to container and host filesystem

#### Scenario: File deletion
- **WHEN** SMB client deletes file
- **THEN** file is removed from container and host filesystem

#### Scenario: Directory operations
- **WHEN** SMB client creates or removes directories
- **THEN** operations succeed and reflect in filesystem

### Requirement: SMB configuration
The system SHALL support configuring SMB settings via environment file.

#### Scenario: Default configuration
- **WHEN** no custom SMB configuration is provided
- **THEN** system uses default share name, path, and credentials

#### Scenario: Custom configuration loading
- **WHEN** SMB settings are in configuration file
- **THEN** Samba server uses custom configuration

### Requirement: File permissions compatibility
The system SHALL handle file permissions appropriately for SMB access.

#### Scenario: SMB user mapping
- **WHEN** SMB client accesses files as jb-gateway user
- **THEN** file operations use jb-gateway user's permissions in container

#### Scenario: Permission preservation
- **WHEN** files are created via SMB
- **THEN** files have appropriate permissions for container user

### Requirement: Network discovery
The system SHALL support network discovery of SMB shares on local network.

#### Scenario: NetBIOS name resolution
- **WHEN** clients browse network neighborhood
- **THEN** gateway container appears as available SMB server

#### Scenario: Share enumeration
- **WHEN** client queries available shares
- **THEN** system lists 'projects' share

### Requirement: Concurrent client connections
The system SHALL support multiple simultaneous SMB client connections.

#### Scenario: Multiple clients
- **WHEN** multiple clients connect to SMB share simultaneously
- **THEN** all clients can access files concurrently

#### Scenario: File locking
- **WHEN** multiple clients access same file
- **THEN** Samba handles file locking to prevent conflicts

### Requirement: SMB protocol version support
The system SHALL support modern SMB protocol versions for security and compatibility.

#### Scenario: SMB2/SMB3 support
- **WHEN** modern SMB clients connect
- **THEN** system negotiates SMB2 or SMB3 protocol

#### Scenario: Legacy SMB1 handling
- **WHEN** configuration defines SMB1 policy
- **THEN** system follows configured policy for SMB1 connections
