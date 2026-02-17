## Why

Currently, jb-gateway supports only a single client configuration per machine. Users who need multiple isolated development environments (e.g., different projects, different team contexts, or different SDK versions) must either use separate machines or manually switch configurations. This limits productivity and increases operational overhead.

## What Changes

- Add optional profile support via `--profile <name>` flag on client commands
- Implement profile-isolated configuration storage (separate config directories per profile)
- Support concurrent operation of multiple profiles with independent SSH tunnels and proxy connections
- Maintain backward compatibility: when no profile is specified, use default (no-profile) configuration

## Capabilities

### New Capabilities

- `profile-config-isolation`: Profile-specific configuration storage and isolation

### Modified Capabilities

- `client-tools`: Add optional `--profile` flag for profile-specific operations
- `ssh-access`: Support profile-specific SSH tunnel establishment
- `http-proxy`: Enable profile-aware proxy configuration

## Impact

**Affected Code:**

- `client/` scripts: Add optional `--profile` parameter handling
- Configuration storage: Support both default (no-profile) and profile-based directory structure
- SSH tunnel scripts: Add profile context to tunnel establishment
- Proxy management: Use profile-specific configuration when specified

**APIs:**

- Client CLI: Add optional `--profile <name>` flag to all client commands

**Dependencies:**

- No new external dependencies
- Backward compatibility: No profile specified = use default behavior

**Systems:**

- Configuration directory structure: `~/.jb-gateway/` (default) or `~/.jb-gateway/profiles/<name>/` (when profile specified)
- SSH tunnel tracking per profile
- Independent proxy ports per profile (no conflict checking)
