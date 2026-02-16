## ADDED Requirements

### Requirement: Single-line installation command
The installer SHALL be accessible via a single curl or wget command that downloads and executes the installation script from the GitHub repository main branch.

#### Scenario: Installation via curl
- **WHEN** user runs `curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=server`
- **THEN** the installation script SHALL download and execute successfully

#### Scenario: Installation via wget
- **WHEN** user runs `wget -qO- https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=client`
- **THEN** the installation script SHALL download and execute successfully

### Requirement: Installation mode selection
The installer SHALL require a `--mode` flag with value `server`, `client`, or `both` to determine which components to install.

#### Scenario: Server mode installation
- **WHEN** user specifies `--mode=server`
- **THEN** the installer SHALL download and configure server-side components (Docker files, server scripts, IDE gateway configuration)

#### Scenario: Client mode installation
- **WHEN** user specifies `--mode=client`
- **THEN** the installer SHALL download and configure client-side components (client scripts, container runtime tools, status monitoring)

#### Scenario: Both modes installation
- **WHEN** user specifies `--mode=both`
- **THEN** the installer SHALL download and configure both server and client components

#### Scenario: Adding mode to existing installation
- **WHEN** user runs installer with a different mode than previously installed
- **THEN** the installer SHALL add the new components and update `.install-mode` to reflect both modes

#### Scenario: Missing mode flag
- **WHEN** user runs installer without `--mode` flag
- **THEN** the installer SHALL exit with an error message explaining the required flag

#### Scenario: Invalid mode value
- **WHEN** user specifies `--mode=invalid`
- **THEN** the installer SHALL exit with an error message listing valid modes (server, client, both)

### Requirement: Installation directory
The installer SHALL install all files to `$HOME/.jb-gateway/bin` directory.

#### Scenario: Fresh installation
- **WHEN** `$HOME/.jb-gateway/bin` does not exist
- **THEN** the installer SHALL create the directory structure

#### Scenario: Existing installation detected
- **WHEN** `$HOME/.jb-gateway` already exists
- **THEN** the installer SHALL prompt the user to confirm overwrite or exit

#### Scenario: Installation with force flag
- **WHEN** user specifies `--force` flag and `$HOME/.jb-gateway` exists
- **THEN** the installer SHALL overwrite existing installation without prompting

### Requirement: File download from GitHub
The installer SHALL download required files from the GitHub repository main branch.

#### Scenario: Git available
- **WHEN** git command is available in PATH
- **THEN** the installer SHALL use `git clone --depth 1` to download files

#### Scenario: Git not available
- **WHEN** git command is not available
- **THEN** the installer SHALL fall back to downloading individual files via curl/wget from raw.githubusercontent.com

#### Scenario: Network failure
- **WHEN** network request fails
- **THEN** the installer SHALL retry up to 3 times with exponential backoff before failing

### Requirement: Installation metadata
The installer SHALL record installation metadata in `$HOME/.jb-gateway/bin/.install-mode` file.

#### Scenario: Mode persistence
- **WHEN** installation completes successfully
- **THEN** the installer SHALL write the installation mode (server, client, or both) to `.install-mode` file

#### Scenario: Multiple mode tracking
- **WHEN** user installs additional mode after initial installation
- **THEN** the installer SHALL update `.install-mode` to show both modes are installed

#### Scenario: Installation timestamp
- **WHEN** installation completes successfully
- **THEN** the installer SHALL record the installation timestamp in `.install-mode` file

### Requirement: Installation feedback
The installer SHALL provide clear progress feedback and error messages to the user.

#### Scenario: Progress indicators
- **WHEN** installation is in progress
- **THEN** the installer SHALL display progress messages for each major step (downloading, configuring, integrating)

#### Scenario: Success message
- **WHEN** installation completes successfully
- **THEN** the installer SHALL display a success message with next steps

#### Scenario: Error messages
- **WHEN** an error occurs during installation
- **THEN** the installer SHALL display a clear error message explaining what failed and how to resolve it

### Requirement: Idempotent installation
The installer SHALL be safe to run multiple times without adverse effects.

#### Scenario: Re-running installer
- **WHEN** user runs installer on an existing installation (with --force)
- **THEN** the installer SHALL update files without creating duplicates or breaking configuration

#### Scenario: Interrupted installation recovery
- **WHEN** previous installation was interrupted
- **THEN** the installer SHALL clean up partial installation and proceed with fresh installation
