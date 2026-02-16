## Why

Manual installation of jb-gateway requires users to clone the repository, understand the directory structure, configure
shell integration, and manage updates manually. This creates friction for adoption and makes it difficult for users to
keep their installation current with the latest security patches and features.

## What Changes

- Add a single-line installer script accessible via curl/wget that sets up jb-gateway in `$HOME/.jb-gateway`
- Support two installation modes: server and client
- Automatically integrate with user's shell (bash/zsh) by modifying shell configuration files
- Provide a built-in update command that pulls the latest version from the main branch
- Download installation files directly from the GitHub repository (https://github.com/asubb/jb-gateway)

## Capabilities

### New Capabilities

- `auto-installer`: Single-command installation process that detects installation mode (server/client), downloads files
  from GitHub, and sets up the directory structure
- `shell-integration`: Automatic integration with user's shell environment, adding jb-gateway to PATH and configuring
  aliases/completions
- `self-update`: Built-in update mechanism that allows users to update their installation with a single command

### Modified Capabilities

<!-- No existing capabilities are being modified -->

## Impact

- **New files**: Installation script (likely `install.sh`) hosted in the repository root or under a `scripts/` directory
- **Documentation**: Installation instructions in README.md will be simplified to a single curl/wget command
- **Shell configurations**: User's `.bashrc`, `.zshrc`, or equivalent files will be modified to source jb-gateway
- **Deployment**: Simplified onboarding for new users and easier distribution of updates
- **GitHub repository**: Main branch becomes the canonical source for installation files
