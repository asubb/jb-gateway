## Context

jb-gateway is a containerized development environment for AI agents with both server (JetBrains IDE gateway) and
client (container runtime) components. Currently, users must manually clone the repository and understand the directory
structure to set up either component. The installation should be streamlined to a single command that handles
downloading, configuration, and shell integration.

The installation script needs to be accessible via GitHub's raw content URL and work with both curl and wget. The script
must be idempotent (safe to run multiple times) and support both fresh installations and updates.

## Goals / Non-Goals

**Goals:**

- Provide a single-line installation command for both server and client modes
- Install all necessary files to `$HOME/.jb-gateway` from the GitHub main branch
- Automatically detect and integrate with bash/zsh shells
- Enable users to update their installation with a single command
- Support both initial installation and upgrade scenarios
- Provide clear feedback during installation (progress, success, errors)

**Non-Goals:**

- Supporting shells other than bash and zsh in the initial version
- Windows installation (focus on Linux/macOS)
- Customization of installation directory (always use `$HOME/.jb-gateway`)
- Backup/restore of previous installation versions
- Uninstallation functionality (can be added later)

## Decisions

### 1. Installation Script Location and Access

**Decision**: Host `install.sh` at repository root, accessible via
`https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh`

**Rationale**:

- Standard pattern used by popular tools (rustup, nvm, etc.)
- Simple URL that's easy to remember and type
- No additional hosting infrastructure needed

**Alternatives considered**:

- GitHub Releases: More complex, requires tagging releases
- Separate hosting: Adds infrastructure overhead

### 2. Installation Mode Detection

**Decision**: Use command-line flag to specify mode: `--mode=server|client|both`

**Rationale**:

- Explicit choice prevents accidental installation of wrong mode
- Clear error messages when flag is missing
- `--mode=both` allows installing server and client on same machine
- Users can run installer multiple times with different modes to add components

**Alternatives considered**:

- Auto-detection based on environment: Too error-prone, unclear to user
- Interactive prompt: Doesn't work well with single-line installer pattern
- Separate directories per mode: More complex, harder to maintain

### 3. File Download Strategy

**Decision**: Use `git clone --depth 1` or direct file downloads via GitHub API for specific files

**Rationale**:

- Server mode needs: Docker files, scripts, configuration
- Client mode needs: Client scripts, status monitoring tools
- Download only what's needed for the selected mode
- Use git if available (faster, includes .git for updates), fall back to curl/wget

**Alternatives considered**:

- Always download full repository: Wasteful bandwidth
- Tarball download: Less flexible for selective file downloads

### 4. Shell Integration Approach

**Decision**: Add a single source line to shell RC files that loads `$HOME/.jb-gateway/bin/env.sh`

**Rationale**:

- Minimal modification to user's RC files
- Easy to identify and remove if needed
- All jb-gateway configuration lives in one place
- Idempotent (check if line exists before adding)

**Pattern**:

```bash
# jb-gateway
[ -f "$HOME/.jb-gateway/bin/env.sh" ] && source "$HOME/.jb-gateway/bin/env.sh"
```

**Command interface**: Use `jbg <command>` pattern for all operations (e.g., `jbg update`, `jbg server start`, `jbg client status`). This provides a clean namespace and clear command structure.

**Alternatives considered**:

- Directly modify PATH in RC files: Harder to maintain
- Symlinks to `/usr/local/bin`: Requires sudo, more invasive
- Individual jb-* commands: More cluttered namespace, harder to organize subcommands

### 5. Update Mechanism

**Decision**: Provide `jbg update` command that re-runs the installer or does `git pull` if .git exists

**Rationale**:

- Leverages existing installer logic
- Simple for users (`jbg update`)
- Preserves user's installation mode
- Git pull is faster when available
- Consistent with overall `jbg <command>` pattern

**Alternatives considered**:

- Separate update script: Code duplication
- Version checking with selective downloads: More complexity
- Auto-update on shell startup: Too invasive, could break user's session

### 6. Installation Directory Structure

**Decision**: Install all repository files directly under `$HOME/.jb-gateway/bin/`

```
$HOME/.jb-gateway/
└── bin/              # All jb-gateway files (scripts, configs, etc.)
    ├── env.sh        # Environment setup sourced by shell
    └── .install-mode # Stores 'server', 'client', or 'both'
```

**Rationale**:

- Simplified structure - all files in one location
- Repository contents copied directly to bin/ directory
- PATH only needs `$HOME/.jb-gateway/bin` added
- `.install-mode` tracks which components are installed (server, client, or both)
- Both server and client can coexist in same directory without conflicts
- Easier to maintain and understand

**Alternatives considered**:

- Multiple subdirectories (bin/, lib/, config/): More complex, unnecessary for this use case
- Flat structure in $HOME/.jb-gateway/: Would mix scripts with metadata files like env.sh
- Separate directories per mode (bin/server/, bin/client/): Over-engineered, files don't conflict

## Risks / Trade-offs

**[Risk] Network failures during installation** → Use curl/wget retry flags, verify checksums if available

**[Risk] Shell RC file corruption** → Backup RC file before modification, provide recovery instructions

**[Risk] Conflicts with existing installations** → Detect existing `$HOME/.jb-gateway`, prompt user or use `--force`
flag

**[Risk] GitHub rate limiting** → Use git clone when possible (no rate limits), fall back to raw.githubusercontent.com

**[Trade-off] Only bash/zsh support** → Covers 95%+ of use cases, reduces complexity. Other shells can be added
incrementally.

**[Trade-off] Modifying user's RC files** → Essential for PATH integration. We minimize the change to a single
conditional source line.

**[Trade-off] No automatic updates** → Users must run `jbg update`. Automatic updates could be surprising and introduce
breaking changes unexpectedly.

## Migration Plan

**Deployment**:

1. Merge install.sh and supporting scripts to main branch
2. Update README.md with installation instructions
3. Test installation on clean Linux and macOS environments
4. Announce new installation method in release notes

**Rollback**:

- Users can remove `$HOME/.jb-gateway` directory
- Users can remove the source line from their shell RC files
- No server-side rollback needed (script is versioned with the repo)

**Backward compatibility**:

- Existing manual installations continue to work
- New installer can be used to upgrade manual installations
