## ADDED Requirements

### Requirement: Installation manifest file format
The system SHALL support a declarative manifest file format for defining installation requirements.

#### Scenario: Manifest file location
- **WHEN** system looks for installation configuration
- **THEN** system reads manifest from a standard location (e.g., `installations.yaml`)

#### Scenario: YAML format support
- **WHEN** manifest file is parsed
- **THEN** system accepts valid YAML syntax

#### Scenario: Manifest validation
- **WHEN** manifest file is loaded
- **THEN** system validates schema and reports any errors with clear messages

### Requirement: Software package declarations
The system SHALL allow declaring software packages to be pre-installed in the manifest.

#### Scenario: Package list definition
- **WHEN** manifest includes software packages section
- **THEN** each package is defined with name and optional version constraints

#### Scenario: Multiple packages
- **WHEN** manifest lists multiple software packages
- **THEN** all listed packages are included in installation requirements

### Requirement: Directory mount declarations
The system SHALL allow declaring directory mount points in the manifest.

#### Scenario: Mount point definition
- **WHEN** manifest includes directory mounts section
- **THEN** each mount is defined with container path and host subdirectory under `~/.jb-gateway`

#### Scenario: Multiple mounts
- **WHEN** manifest lists multiple directory mounts
- **THEN** all listed mounts are included in container configuration

#### Scenario: Mount permissions
- **WHEN** directory mount is declared
- **THEN** manifest can optionally specify permissions (read-only, read-write)

### Requirement: Port declarations
The system SHALL allow declaring exposed ports in the manifest.

#### Scenario: Port definition
- **WHEN** manifest includes exposed ports section
- **THEN** each port is defined with container port, optional host port, and metadata

#### Scenario: Port metadata
- **WHEN** port is declared
- **THEN** manifest can include purpose description and protocol (TCP/UDP)

#### Scenario: Multiple ports
- **WHEN** manifest lists multiple ports
- **THEN** all listed ports are included in container configuration

### Requirement: Default installation manifest
The system SHALL provide a default installation manifest with commonly used tools.

#### Scenario: Default manifest location
- **WHEN** no custom manifest is provided
- **THEN** system uses default manifest from project

#### Scenario: Default software packages
- **WHEN** default manifest is used
- **THEN** manifest includes git, gradle, mvn, sdkman, and built-in browser

#### Scenario: Default directory mounts
- **WHEN** default manifest is used
- **THEN** manifest includes standard development directory mounts

#### Scenario: Default ports
- **WHEN** default manifest is used
- **THEN** manifest includes SSH, SMB, and noVNC ports

### Requirement: Manifest override capability
The system SHALL allow users to override the default manifest with custom installation requirements.

#### Scenario: Custom manifest location
- **WHEN** custom manifest exists at expected location
- **THEN** system uses custom manifest instead of default

#### Scenario: Partial override
- **WHEN** custom manifest is provided
- **THEN** system merges custom requirements with defaults or replaces entirely based on configuration

### Requirement: Manifest documentation
The system SHALL provide documentation for the manifest file format.

#### Scenario: Schema documentation
- **WHEN** user needs to create custom manifest
- **THEN** documentation describes all available fields and their formats

#### Scenario: Example manifests
- **WHEN** user needs manifest examples
- **THEN** documentation includes sample manifests for common use cases
