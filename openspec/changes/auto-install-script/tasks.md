## 1. Installation Script Core

- [x] 1.1 Create install.sh at repository root
- [x] 1.2 Add command-line argument parsing for --mode, --force flags
- [x] 1.3 Implement mode validation (server/client/both) with error messages
- [x] 1.4 Add help/usage message display function
- [x] 1.5 Implement existing installation detection and mode merging logic
- [x] 1.6 Handle --force flag for overwriting existing installations

## 2. File Download Mechanism

- [x] 2.1 Implement git detection (check if git is in PATH)
- [x] 2.2 Create git-based download function (git clone --depth 1)
- [x] 2.3 Create fallback download function using curl/wget
- [x] 2.4 Add retry logic with exponential backoff for network failures
- [x] 2.5 Determine file lists for server mode
- [x] 2.6 Determine file lists for client mode
- [x] 2.7 Handle downloading files for both modes when --mode=both

## 3. Directory Structure Setup

- [x] 3.1 Create directory structure creation function ($HOME/.jb-gateway/bin)
- [x] 3.2 Implement directory cleanup for fresh installation
- [x] 3.3 Create .install-mode metadata file in bin/ with mode (server/client/both) and timestamp
- [x] 3.4 Implement logic to update .install-mode when adding new mode to existing installation
- [x] 3.5 Set proper permissions on created directories

## 4. Shell Integration

- [x] 4.1 Implement shell detection (check $SHELL for bash/zsh)
- [x] 4.2 Determine appropriate RC file (.bashrc, .bash_profile, .zshrc)
- [x] 4.3 Create RC file backup function (.bak extension)
- [x] 4.4 Implement source line addition with duplicate detection for bin/env.sh
- [x] 4.5 Create env.sh script in bin/ with PATH modification
- [x] 4.6 Set JBG_HOME environment variable in env.sh
- [x] 4.7 Source bin/env.sh in current shell session after installation

## 5. jbg Command Wrapper

- [x] 5.1 Create jbg wrapper script in bin/ directory
- [x] 5.2 Implement subcommand routing (update, server, client, etc.)
- [x] 5.3 Add help/usage display for available subcommands
- [x] 5.4 Implement update subcommand logic
- [x] 5.5 Add git-based update logic (git pull when bin/.git exists)
- [x] 5.6 Add file download-based update logic (re-download when no bin/.git)
- [x] 5.7 Read bin/.install-mode to preserve installation mode (server/client/both) during update
- [x] 5.8 Handle updating files for both modes when .install-mode contains both
- [x] 5.9 Implement user-modified file preservation logic
- [x] 5.10 Create backup before update
- [x] 5.11 Add post-update verification (check essential files exist)
- [x] 5.12 Implement rollback on update failure

## 6. User Feedback and Error Handling

- [x] 6.1 Add progress messages for each installation step
- [x] 6.2 Create success message with next steps
- [x] 6.3 Implement error message function with clear diagnostics
- [x] 6.4 Add network error handling with helpful messages
- [x] 6.5 Add unsupported shell warning message
- [x] 6.6 Create manual integration instructions for unsupported shells

## 7. Testing and Validation

- [x] 7.1 Test server mode installation on clean environment
- [x] 7.2 Test client mode installation on clean environment
- [x] 7.3 Test both modes installation (--mode=both) on clean environment
- [x] 7.4 Test adding client to existing server installation
- [x] 7.5 Test adding server to existing client installation
- [x] 7.6 Test installation over existing installation with --force
- [x] 7.7 Test update command with git-based installation (server only)
- [x] 7.8 Test update command with git-based installation (both modes)
- [x] 7.9 Test update command with non-git installation
- [x] 7.10 Test shell integration for bash
- [x] 7.11 Test shell integration for zsh
- [x] 7.12 Test error scenarios (missing mode, network failure, etc.)
- [x] 7.13 Verify idempotency by running installer multiple times

## 8. Documentation

- [x] 8.1 Update README.md with single-line installation command
- [x] 8.2 Document --mode flag options (server/client/both) and usage
- [x] 8.3 Document installing both modes on same machine (sequential installs or --mode=both)
- [x] 8.4 Document --force flag for overwriting existing installations
- [x] 8.5 Document jbg command structure and available subcommands
- [x] 8.6 Document jbg update command
- [x] 8.7 Add examples of common jbg commands
- [x] 8.8 Document manual integration steps for unsupported shells
- [x] 8.9 Add troubleshooting section for common issues
