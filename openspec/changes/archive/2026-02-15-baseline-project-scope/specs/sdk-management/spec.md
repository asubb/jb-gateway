## ADDED Requirements

### Requirement: SDKMAN installation
The system SHALL provide SDKMAN installed and configured for the jb-gateway user.

#### Scenario: SDKMAN available
- **WHEN** user opens SSH session
- **THEN** sdk command is available in the shell

#### Scenario: SDKMAN initialization
- **WHEN** bash shell starts
- **THEN** system sources SDKMAN initialization from ~/.bashrc

### Requirement: SDK installation
The system SHALL allow installing multiple versions of SDKs via SDKMAN.

#### Scenario: List available SDKs
- **WHEN** user runs 'sdk list java'
- **THEN** system displays all available Java versions

#### Scenario: Install SDK version
- **WHEN** user runs 'sdk install java <version>'
- **THEN** system downloads and installs specified Java version

#### Scenario: Install other SDKs
- **WHEN** user runs 'sdk install' with gradle, maven, or other supported SDK
- **THEN** system installs the specified SDK

### Requirement: SDK version switching
The system SHALL allow switching between installed SDK versions.

#### Scenario: Use specific SDK version
- **WHEN** user runs 'sdk use java <version>'
- **THEN** system sets specified Java version for current shell session

#### Scenario: Set default SDK version
- **WHEN** user runs 'sdk default java <version>'
- **THEN** system sets specified version as default for all new sessions

#### Scenario: Verify active version
- **WHEN** user runs 'java --version' after switching
- **THEN** system shows the version selected via SDKMAN

### Requirement: Multiple SDK types support
The system SHALL support managing various SDK types through SDKMAN.

#### Scenario: Java SDK management
- **WHEN** user manages Java versions via SDKMAN
- **THEN** system supports multiple Java distributions (OpenJDK, Temurin, GraalVM, etc.)

#### Scenario: Build tool management
- **WHEN** user installs Gradle or Maven via SDKMAN
- **THEN** system manages multiple versions of build tools

#### Scenario: Other development tools
- **WHEN** user installs supported development tools
- **THEN** SDKMAN manages versions for tools like Kotlin, Scala, Groovy

### Requirement: SDK persistence
The system SHALL persist installed SDKs across container restarts when SDKMAN directory is mounted.

#### Scenario: Mounted SDKMAN directory on macOS
- **WHEN** host ~/.sdkman exists and container starts on macOS
- **THEN** system mounts host SDKMAN directory to container

#### Scenario: SDK availability after restart
- **WHEN** container restarts with mounted SDKMAN directory
- **THEN** previously installed SDKs remain available

#### Scenario: Shared SDKs between host and container
- **WHEN** SDKMAN directory is mounted from host
- **THEN** SDKs installed on host are accessible in container

### Requirement: SDK listing and management
The system SHALL allow querying and managing installed SDKs.

#### Scenario: List installed versions
- **WHEN** user runs 'sdk list java' with versions installed
- **THEN** system displays installed versions with indicators

#### Scenario: Current version indicator
- **WHEN** viewing installed SDKs
- **THEN** system marks currently active version

#### Scenario: Uninstall SDK version
- **WHEN** user runs 'sdk uninstall java <version>'
- **THEN** system removes specified version

### Requirement: SDKMAN self-management
The system SHALL allow updating SDKMAN itself.

#### Scenario: Update SDKMAN
- **WHEN** user runs 'sdk selfupdate'
- **THEN** system updates SDKMAN to latest version

#### Scenario: Update candidate information
- **WHEN** user runs 'sdk update'
- **THEN** system refreshes list of available SDK versions

### Requirement: Environment integration
The system SHALL integrate SDKMAN with the shell environment seamlessly.

#### Scenario: PATH modification
- **WHEN** SDK version is selected
- **THEN** system updates PATH to prioritize selected SDK binaries

#### Scenario: JAVA_HOME setting
- **WHEN** Java version is selected
- **THEN** system sets JAVA_HOME environment variable to selected version

#### Scenario: Automatic activation
- **WHEN** user opens new SSH session
- **THEN** default SDK versions are automatically activated

### Requirement: Offline SDK management
The system SHALL support using pre-installed SDKs without internet access.

#### Scenario: Use cached SDKs
- **WHEN** SDKs are already installed and network is unavailable
- **THEN** user can switch between and use installed SDK versions

#### Scenario: Offline version listing
- **WHEN** user runs 'sdk list' in offline mode
- **THEN** system shows installed versions without requiring network
