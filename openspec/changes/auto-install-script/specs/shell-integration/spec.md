## ADDED Requirements

### Requirement: Shell detection
The installer SHALL detect the user's default shell and integrate with bash or zsh.

#### Scenario: Bash shell detected
- **WHEN** user's shell is bash
- **THEN** the installer SHALL modify `.bashrc` or `.bash_profile` to source jb-gateway environment

#### Scenario: Zsh shell detected
- **WHEN** user's shell is zsh
- **THEN** the installer SHALL modify `.zshrc` to source jb-gateway environment

#### Scenario: Unsupported shell
- **WHEN** user's shell is not bash or zsh
- **THEN** the installer SHALL display a warning and provide manual integration instructions

### Requirement: Shell RC file modification
The installer SHALL add a source line to the user's shell RC file to load jb-gateway environment.

#### Scenario: Adding source line
- **WHEN** shell RC file does not contain jb-gateway source line
- **THEN** the installer SHALL append the source line with a comment marker

#### Scenario: Source line already exists
- **WHEN** shell RC file already contains jb-gateway source line
- **THEN** the installer SHALL skip adding the line to avoid duplicates

#### Scenario: RC file backup
- **WHEN** installer modifies shell RC file
- **THEN** the installer SHALL create a backup copy with `.bak` extension

### Requirement: Environment setup script
The installer SHALL create `$HOME/.jb-gateway/bin/env.sh` that configures the shell environment.

#### Scenario: PATH modification
- **WHEN** env.sh is sourced
- **THEN** it SHALL add `$HOME/.jb-gateway/bin` to the beginning of PATH

#### Scenario: jbg command availability
- **WHEN** env.sh is sourced
- **THEN** the `jbg` command SHALL be available in PATH

#### Scenario: Environment variables
- **WHEN** env.sh is sourced
- **THEN** it SHALL set `JBG_HOME` environment variable to `$HOME/.jb-gateway`

### Requirement: Immediate environment availability
The installer SHALL make jb-gateway commands available without requiring shell restart.

#### Scenario: Source in current shell
- **WHEN** installation completes
- **THEN** the installer SHALL source env.sh in the current shell session

#### Scenario: Availability verification
- **WHEN** installation completes
- **THEN** the installer SHALL verify that jb-gateway commands are in PATH

### Requirement: Command interface
All jb-gateway operations SHALL be accessible via the `jbg <command>` interface.

#### Scenario: Subcommand structure
- **WHEN** user runs `jbg <command>`
- **THEN** the jbg wrapper SHALL execute the appropriate subcommand (e.g., `jbg update`, `jbg server start`, `jbg client status`)

#### Scenario: Command discovery
- **WHEN** user runs `jbg` without arguments or with `--help`
- **THEN** it SHALL display available subcommands and usage information

### Requirement: Shell integration source line format
The source line SHALL be conditional and safe to include in shell RC files.

#### Scenario: Conditional sourcing
- **WHEN** shell RC file is sourced
- **THEN** the source line SHALL check if env.sh exists before sourcing to prevent errors

#### Scenario: Source line format
- **WHEN** installer adds source line
- **THEN** it SHALL use the format: `[ -f "$HOME/.jb-gateway/bin/env.sh" ] && source "$HOME/.jb-gateway/bin/env.sh"`

#### Scenario: Comment markers
- **WHEN** installer adds source line
- **THEN** it SHALL include a comment marker `# jb-gateway` for easy identification
