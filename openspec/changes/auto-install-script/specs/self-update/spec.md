## ADDED Requirements

### Requirement: Update command availability
The system SHALL provide a `jbg update` command accessible from the shell after installation.

#### Scenario: Update command availability
- **WHEN** shell environment is configured
- **THEN** the `jbg update` command SHALL be available

#### Scenario: Update command execution
- **WHEN** user runs `jbg update`
- **THEN** the command SHALL execute the update process

### Requirement: Update mechanism with Git
The update command SHALL use git pull when the installation was done via git clone.

#### Scenario: Git-based installation update
- **WHEN** `$HOME/.jb-gateway/bin/.git` directory exists
- **THEN** the update command SHALL run `git pull origin <branch>` to update files from the installed branch

#### Scenario: Git pull success
- **WHEN** git pull completes successfully
- **THEN** the update command SHALL display updated files and success message

#### Scenario: Git pull failure
- **WHEN** git pull fails (e.g., merge conflicts, network error)
- **THEN** the update command SHALL display error message and suggest manual resolution

### Requirement: Update mechanism without Git
The update command SHALL re-download files when installation was not git-based.

#### Scenario: Non-git installation update
- **WHEN** `$HOME/.jb-gateway/bin/.git` directory does not exist
- **THEN** the update command SHALL re-download files from GitHub using curl/wget

#### Scenario: File download update
- **WHEN** updating via file download
- **THEN** the update command SHALL download and replace files while preserving user configuration

### Requirement: Installation mode preservation
The update command SHALL preserve the original installation mode (server, client, or both).

#### Scenario: Mode preservation from metadata
- **WHEN** update command runs
- **THEN** it SHALL read `.install-mode` file to determine which files to update

### Requirement: Installation branch preservation
The update command SHALL preserve the original installation branch.

#### Scenario: Branch preservation from metadata
- **WHEN** update command runs
- **THEN** it SHALL read `.install-branch` file to determine which branch to update from

#### Scenario: Git-based branch update
- **WHEN** updating via git pull and `.install-branch` contains branch name
- **THEN** the update SHALL pull from the specified branch

#### Scenario: Non-git branch update
- **WHEN** updating via file download and `.install-branch` contains branch name
- **THEN** the update SHALL re-run installer with JBG_BRANCH environment variable set to the stored branch

#### Scenario: Server mode update
- **WHEN** original installation was server mode only
- **THEN** the update SHALL only update server-related files

#### Scenario: Client mode update
- **WHEN** original installation was client mode only
- **THEN** the update SHALL only update client-related files

#### Scenario: Both modes update
- **WHEN** original installation has both server and client modes
- **THEN** the update SHALL update all files for both modes

### Requirement: Configuration preservation
The update command SHALL preserve user configuration files during update.

#### Scenario: Config file preservation
- **WHEN** update command runs
- **THEN** it SHALL not overwrite user-modified configuration files

#### Scenario: New config file handling
- **WHEN** update introduces new configuration files
- **THEN** the update SHALL create them with `.new` extension if user versions exist

### Requirement: Update feedback
The update command SHALL provide clear feedback about the update process.

#### Scenario: Update progress
- **WHEN** update is in progress
- **THEN** the command SHALL display progress messages for each step

#### Scenario: No updates available
- **WHEN** installation is already up to date
- **THEN** the command SHALL display message indicating no updates are needed

#### Scenario: Update success
- **WHEN** update completes successfully
- **THEN** the command SHALL display summary of updated files and any action items

#### Scenario: Update failure
- **WHEN** update fails
- **THEN** the command SHALL display error message and suggest rollback or manual intervention

### Requirement: Update safety
The update command SHALL implement safety checks to prevent broken installations.

#### Scenario: Backup before update
- **WHEN** update begins
- **THEN** the command SHALL create a backup of critical files

#### Scenario: Verification after update
- **WHEN** update completes
- **THEN** the command SHALL verify that essential files are present and executable

#### Scenario: Rollback on failure
- **WHEN** update verification fails
- **THEN** the command SHALL restore from backup and notify user
