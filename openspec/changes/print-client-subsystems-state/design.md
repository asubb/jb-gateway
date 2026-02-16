## Context

The jb-gateway project provides client-side scripts (`proxy.sh` and `smb-connect.sh`) that establish HTTP proxy tunnels
and SMB mounts. These subsystems run as background processes, storing their state in:

- PID files in `~/.jb-gateway/proxy/` (e.g., `proxy_7070.pid`, `monitor.pid`)
- Log files in `~/.jb-gateway/logs/`
- Configuration in `client/.env`

Currently, users must manually check multiple locations (PID files, process lists, mount tables, logs) to understand
what's running. This is cumbersome for troubleshooting and operational awareness.

The new `status.sh` script will consolidate all this information into a single view, similar to how `systemctl status`
works for systemd services.

**Constraints:**

- Must be pure bash for portability
- Must work on both macOS and Linux (different process, mount commands)
- Must be read-only (no modifications to running subsystems)
- Must handle cases where `~/.jb-gateway/` directories don't exist yet

## Goals / Non-Goals

**Goals:**

- Provide a single command to check operational status of all client subsystems
- Display HTTP proxy tunnel status (active ports, PIDs, uptime, health)
- Display SMB mount status (mount points, shares, accessibility)
- Show relevant configuration from `.env` files
- Detect stale PIDs and unhealthy mounts
- Format output clearly with visual indicators
- Reference log file locations for troubleshooting

**Non-Goals:**

- Starting/stopping subsystems (use existing `proxy.sh`, `smb-connect.sh`)
- Real-time monitoring (use existing monitor in `proxy.sh` with `AUTO_REFRESH`)
- Detailed log analysis (just point to log locations)
- JSON/machine-readable output format (human-readable only)
- Remote status checking (local only)

## Decisions

### Decision 1: Single bash script in client/status.sh

**Rationale:** Keep all client-side tools together. Bash is already used for proxy.sh and smb-connect.sh, so no new
dependencies. Easy for users to execute directly.

**Alternatives considered:**

- Python script: Would require Python installation, adds dependency
- Separate status scripts per subsystem: Would require users to run multiple commands

### Decision 2: Read PID files from ~/.jb-gateway/proxy/

**Rationale:** This is where `proxy.sh` already stores PID files. We follow the existing convention: `proxy_<port>.pid`
for tunnels and `monitor.pid` for the monitor process.

**Alternatives considered:**

- Change PID file location to `~/.jb-gateway/pids/`: Would break compatibility with existing proxy.sh
- Store state in a database: Overengineering for simple state tracking

**Note:** The proposal mentions `~/.jb-gateway/pids/tunnel_*.pid`, but the actual implementation uses
`~/.jb-gateway/proxy/proxy_*.pid`. We'll use the actual existing paths.

### Decision 3: Platform detection for mount/process checks

**Rationale:** macOS uses `mount -t smbfs` and `ps -p`, while Linux uses `mount -t cifs` and may have different ps
flags. We'll detect `$OSTYPE` or use command availability checks.

**Implementation:**

```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS commands
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux commands
fi
```

**Alternatives considered:**

- Assume Linux only: Would break for macOS users
- Try commands and fall back: More complex error handling

### Decision 4: Visual status indicators using symbols

**Rationale:** Make status easy to scan at a glance. Use symbols and colors:

- ✓ (green) = healthy/running
- ✗ (red) = error/not running
- ⚠ (yellow) = warning/stale
- ℹ (blue) = info/configuration

**Alternatives considered:**

- Text-only (OK/ERROR): Less visually scannable
- Colors only: Not accessible to colorblind users or terminals without color support
- Use both symbols and colors for best accessibility

### Decision 5: Section-based output format

**Structure:**

1. Header with timestamp
2. Configuration section (from .env)
3. HTTP Proxy Tunnels section
4. SMB Mounts section
5. Summary section with overall health

**Rationale:** Matches the logical grouping in requirements. Users can quickly jump to the section they care about.

**Alternatives considered:**

- Flat list: Harder to scan
- JSON output: Not human-friendly, violates non-goals

### Decision 6: Process validation using ps -p

**Rationale:** Reading a PID file isn't enough—the process might have died. We'll validate with `ps -p $pid` and check
the command line matches expected patterns (ssh tunnel, etc.).

**Implementation:**

```bash
if ps -p "$pid" > /dev/null 2>&1; then
  # Process exists, check command line
  cmd=$(ps -p "$pid" -o command=)
  if [[ "$cmd" =~ ssh.*-L ]]; then
    # Valid tunnel
  fi
fi
```

**Alternatives considered:**

- Trust PID files: Would show stale processes as active
- Kill stale PIDs: Violates read-only constraint

### Decision 7: Mount validation using test -d and df

**Rationale:** Check if mount point exists and is accessible. Use `df "$mountpoint"` to verify it's actually mounted,
then `test -r "$mountpoint"` for accessibility.

**Alternatives considered:**

- Parse `mount` output: Fragile, platform-dependent formatting
- Try to read directory: Simple and reliable

## Risks / Trade-offs

### [Risk] Platform-specific command differences → Mitigation: Extensive testing on both macOS and Linux

The script needs to handle:

- Different mount command output formats
- Different ps command flags and output
- Different SMB client tools (smbutil vs smbclient)

**Mitigation:** Use platform detection and test on both platforms before release.

### [Risk] Race conditions reading PID files → Mitigation: Graceful handling of missing/invalid PIDs

A process might die between reading the PID file and checking if it's running.

**Mitigation:**

- Use `2>/dev/null` to suppress errors
- Check file existence before reading
- Handle empty/malformed PID files

### [Risk] Permissions issues accessing ~/.jb-gateway/ → Mitigation: Clear error messages

User might not have read access to PID/log directories.

**Mitigation:**

- Check directory existence with `-d`
- Provide clear message if directories don't exist
- Continue with available information (partial status is better than none)

### [Risk] Long output for many tunnels/mounts → Trade-off: Prioritize clarity over brevity

With many tunnels, output could be verbose.

**Trade-off:** Accept longer output for completeness. Users can pipe to `less` or `grep` if needed. Clarity is more
important than brevity for a status command.

### [Risk] Stale monitor.pid file → Mitigation: Validate monitor PID like tunnel PIDs

The monitor process might have died but left a PID file.

**Mitigation:** Apply the same validation logic (check process exists, verify command line).

## Migration Plan

N/A - This is a new additive feature with no migration required. The script will work immediately after creation and can
coexist with existing tools.

## Open Questions

None - design is complete and ready for implementation.
