## Context

Currently, both server and client contexts have configuration files (server/host.env, client/.env) but no unified way to view their locations and current values together. The `client/status.sh` script displays some configuration values but doesn't show source file paths. Server configuration has no dedicated inspection tool.

Current state:
- Server configuration: server/host.env exists but no command to view it
- Client configuration: client/.env displayed in status.sh but locations not shown
- No unified command interface for configuration inspection
- No `jbg` command infrastructure exists yet

## Goals / Non-Goals

**Goals:**
- Create new `jbg server config` and `jbg client config` commands
- Display configuration file paths with existence indicators
- Show current configuration values alongside their source files
- Support both server and client contexts with context-appropriate information
- Use consistent visual formatting across both commands

**Non-Goals:**
- Not modifying existing status.sh or other scripts
- Not adding config file editing capabilities
- Not creating interactive configuration prompts
- Not validating configuration values (just display)

## Decisions

### Decision 1: Create dedicated `jbg` command with subcommands
Create a new `jbg` CLI tool with `server config` and `client config` subcommands rather than modifying existing scripts.

**Alternatives considered:**
- Modify status.sh: Would clutter existing output and doesn't help server context
- Separate scripts: Less discoverable, no unified interface
- Single `jbg config` command: Less clear which context (server vs client)

**Rationale:** Dedicated subcommands provide clear separation between server and client contexts, allow for future expansion of the `jbg` CLI, and don't disrupt existing tools.

### Decision 2: Implement `jbg` as a shell script dispatcher
Create `jbg` as a main script that dispatches to subcommand scripts (e.g., `jbg-server-config`, `jbg-client-config`).

**Alternatives considered:**
- Single monolithic script: Harder to maintain and extend
- Python/Node.js CLI: Adds runtime dependencies

**Rationale:** Shell script dispatcher is lightweight, follows Unix conventions, and allows independent subcommand development.

### Decision 3: Server config shows host.env, client config shows .env and runtime dirs
Each command shows context-appropriate information:
- Server: server/host.env location and container settings
- Client: client/.env location, PID directory, log directory

**Alternatives considered:**
- Show all locations in both: Confusing and mixes contexts
- Separate location vs values commands: Unnecessary complexity

**Rationale:** Context-specific display keeps output focused and relevant to the user's current task.

### Decision 4: Use consistent visual formatting with status.sh
Adopt the same color/symbol conventions from status.sh (✓/⚠/ℹ with colors).

**Alternatives considered:**
- Plain text: Less scannable
- Different visual style: Inconsistent user experience

**Rationale:** Consistency across all jb-gateway tools improves usability.

## Risks / Trade-offs

**Risk:** Adding new `jbg` command creates another entry point to maintain
→ **Mitigation:** Keep dispatcher simple and delegate to focused subcommand scripts

**Risk:** Users may not discover the new commands
→ **Mitigation:** Add help output and consider mentioning in status.sh or other tools

**Risk:** Duplication between config display and status.sh configuration section
→ **Acceptable:** Different use cases (dedicated config inspection vs overall status)

**Trade-off:** Shell script implementation limits future rich CLI features
→ **Acceptable:** Keeps dependencies minimal and works everywhere bash works
