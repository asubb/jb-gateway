## Context

jb-gateway currently stores client configuration in a single location (`~/.jb-gateway/` or similar), which means only one client instance can be configured per machine. The system manages SSH tunnels, proxy connections, and Docker container state, all tied to this single configuration.

The current architecture includes:
- Shell scripts in `client/` directory for client operations
- Configuration files stored in a fixed location
- SSH tunnel management via `client/proxy.sh`
- HTTP proxy support with port configuration
- Status monitoring via `client/status.sh`

Adding optional profile support requires enabling profile-based configuration storage while maintaining full backward compatibility when no profile is specified.

## Goals / Non-Goals

**Goals:**
- Enable optional profile isolation via `--profile <name>` flag
- Isolate configuration, state, and credentials per profile when specified
- Support concurrent operation of different profiles
- Maintain 100% backward compatibility (no profile = default behavior)
- Keep profiles simple: just isolated config directories

**Non-Goals:**
- Profile management commands (no create/list/delete/switch - just use --profile flag)
- Port conflict detection or registry (users manage their own port assignments)
- Active profile tracking or default profile selection (no profile = use default paths)
- Profile validation or enforcement (if directory doesn't exist, create it)

## Decisions

### 1. Configuration Directory Structure

**Decision:**
- No profile specified: Use `~/.jb-gateway/` (existing behavior)
- Profile specified: Use `~/.jb-gateway/profiles/<profile-name>/`

**Rationale:**
- Zero breaking changes for existing users
- Clear separation when profiles are used
- Simple to understand and implement
- No migration needed

**Alternatives Considered:**
- Always use profiles with "default" profile - rejected due to unnecessary migration complexity
- Environment variable for profile - rejected to keep it simple (just --profile flag)

### 2. Profile Directory Creation

**Decision:** Auto-create profile directory on first use when `--profile <name>` is specified.

**Rationale:**
- No separate "create profile" command needed
- Simpler user experience: just specify --profile and go
- Directory creation is idempotent and safe

**Alternatives Considered:**
- Require explicit profile creation - rejected as too complex for simple use case
- Validate profile names - rejected as unnecessary restriction

### 3. Profile Isolation Scope

**Decision:** Isolate these per profile:
- Configuration files (proxy.conf, etc.)
- SSH keys (`ssh/` subdirectory)
- State files (PIDs, connection state) (`state/` subdirectory)
- Logs (`logs/` subdirectory)
- Secrets/credentials (`secrets/` subdirectory)

**Rationale:**
- Complete isolation prevents cross-profile interference
- Simple directory structure is easy to understand and debug
- Each profile is fully self-contained

### 4. No Port Conflict Management

**Decision:** No port registry or conflict detection. Users are responsible for configuring different ports for different profiles.

**Rationale:**
- Simpler implementation
- Users know their port assignments
- Profiles are for isolation, not for intelligent resource management
- Port conflicts will naturally fail at OS level with clear errors

**Alternatives Considered:**
- Port registry with conflict detection - rejected as over-engineering for this use case
- Automatic port assignment - rejected as users need predictable port numbers

### 5. No Profile Management Commands

**Decision:** No `client profile create/list/delete/switch` commands. Just use `--profile <name>` flag.

**Rationale:**
- Simpler UX: profiles are just directories
- No state to track (no "active profile")
- Users can list profiles with `ls ~/.jb-gateway/profiles/`
- Can delete profiles with `rm -rf ~/.jb-gateway/profiles/<name>/`
- Less code to maintain

### 6. Profile Flag Implementation

**Decision:** Add `--profile <name>` flag to all client scripts. When present, resolve paths to profile directory instead of default.

**Implementation approach:**
```bash
# In each script:
PROFILE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    # ... other flags
  esac
done

# Resolve config directory
if [[ -n "$PROFILE" ]]; then
  CONFIG_DIR="$HOME/.jb-gateway/profiles/$PROFILE"
  mkdir -p "$CONFIG_DIR"/{ssh,state,logs,secrets}
else
  CONFIG_DIR="$HOME/.jb-gateway"
fi
```

**Rationale:**
- Simple conditional logic in each script
- No shared library complexity
- Easy to understand and debug

## Risks / Trade-offs

**Risk:** Users specify same ports in different profiles and get conflicts
**Mitigation:** Document that users must use different ports for different profiles. OS will clearly fail on port binding.

**Risk:** Profile names with special characters could cause filesystem issues
**Trade-off:** Accept this risk for simplicity. Document recommended naming (alphanumeric, hyphens).

**Risk:** Users might have many stale profile directories
**Trade-off:** Profiles are just directories - users can manually clean up with standard tools.

**Risk:** No visibility into which profiles exist without checking filesystem
**Trade-off:** Users can use `ls ~/.jb-gateway/profiles/` or add this to status.sh later if needed.

## Migration Plan

**Phase 1: Add Profile Support to Scripts**
1. Update each client script to parse `--profile` flag
2. Add conditional config directory resolution
3. Ensure directory structure is created on first use

**Phase 2: Testing**
1. Test no-profile usage (backward compatibility)
2. Test profile usage with multiple concurrent profiles
3. Test profile isolation (separate configs, tunnels, logs)

**Phase 3: Documentation**
1. Document `--profile` flag usage
2. Document directory structure for profiles
3. Document port management (user responsibility)
4. Add examples of multi-profile workflows

**Rollback Strategy:**
- Changes are purely additive (new flag)
- No profile specified = existing behavior
- No rollback needed - just don't use --profile flag
