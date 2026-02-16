## Context

The current HTTP proxy implementation uses SSH tunnels to forward ports from the client machine to the remote host
network through the jb-gateway container. The tunnel command uses `host.docker.internal` as the target, which resolves
to the Docker host's network interface, not the container's localhost.

Developers running web applications inside the container (e.g., `npm run dev` on localhost:3000) cannot access these
applications from their client browser because the proxy only routes to the host network.

**Current architecture:**

```
Client → SSH tunnel → jb-gateway → host.docker.internal:PORT (host network)
```

**Needed architecture:**

```
Client → SSH tunnel → jb-gateway → 127.0.0.1:PORT (container localhost)
```

The system must support both destinations simultaneously, with per-port configuration.

## Goals / Non-Goals

**Goals:**

- Enable proxying to container's localhost while maintaining existing host network proxying
- Support per-port destination configuration
- Maintain backward compatibility (default to host network)
- Use simple configuration format in client/.env

**Non-Goals:**

- Dynamic destination switching for an already-established tunnel
- Automatic detection of where services are running (host vs container)
- Support for destinations other than host network or container localhost
- Per-application routing based on URL patterns

## Decisions

### Decision 1: Use PROXY_DESTINATIONS environment variable for configuration

**Rationale:** Extend the existing .env configuration pattern. The format `PORT:DESTINATION` allows explicit per-port
control.

**Format:** `PROXY_DESTINATIONS="3000:CONTAINER_LOCALHOST,80:HOST_NETWORK,8080:CONTAINER_LOCALHOST"`

**Alternatives considered:**

- Separate CONTAINER_PORTS variable: Would require maintaining two lists and risk port conflicts
- Configuration file: Over-engineered for simple mapping needs
- Auto-detection: Complex and unreliable; explicit configuration is clearer

### Decision 2: Modify SSH tunnel target based on destination

**Implementation:**

- HOST_NETWORK: `-L PORT:host.docker.internal:PORT` (existing behavior)
- CONTAINER_LOCALHOST: `-L PORT:127.0.0.1:PORT` (new behavior)

**Rationale:** SSH local forwarding syntax directly supports both targets. No gateway-side changes needed since the SSH
tunnel itself handles the routing.

**Alternatives considered:**

- Gateway-side proxy process: Adds complexity and another failure point
- Port forwarding through socat: Requires additional tools and configuration
- Dynamic SSH command on gateway: Would require gateway-side scripting changes

### Decision 3: Default to HOST_NETWORK for backward compatibility

**Rationale:** Existing users rely on host network proxying. Changing the default would break their workflows.

**Implementation:**

- If port not in PROXY_DESTINATIONS, use HOST_NETWORK
- Empty or missing PROXY_DESTINATIONS: all ports default to HOST_NETWORK

### Decision 4: Parse PROXY_DESTINATIONS at tunnel creation time

**Rationale:** Simple stateless design. Parse configuration when creating each tunnel in `start_tunnel()` function.

**Implementation:**

```bash
get_destination_for_port() {
    local port="$1"
    # Parse PROXY_DESTINATIONS, return "CONTAINER_LOCALHOST" or "HOST_NETWORK"
}
```

**Alternatives considered:**

- Pre-parse into associative array: Bash 3 compatibility issues on macOS
- External configuration parser: Over-engineered for simple key-value mapping
- JSON configuration: Adds jq dependency and complexity

## Risks / Trade-offs

### [Risk] Configuration syntax errors may cause silent failures

**Mitigation:** Validate PROXY_DESTINATIONS format on startup, warn about invalid entries, and log the parsed
destination for each port.

### [Risk] Users may forget which ports go where

**Mitigation:** Log destination explicitly when starting each tunnel (e.g., "Port 3000: Starting tunnel to
CONTAINER_LOCALHOST...")

### [Trade-off] Per-port configuration is verbose for many ports

**Impact:** If user has 20 ports all going to container localhost, configuration becomes long.
**Mitigation:** Document that listing only non-default ports reduces configuration (default is HOST_NETWORK). Future
enhancement could support wildcard patterns if needed.

### [Risk] Container localhost services must bind to 0.0.0.0 or 127.0.0.1

**Impact:** Services binding to specific interface may not be accessible.
**Mitigation:** Document requirement for services to bind to localhost or all interfaces when using CONTAINER_LOCALHOST
destination.

## Migration Plan

1. **Add configuration parsing:**
    - Add `get_destination_for_port()` function to parse PROXY_DESTINATIONS
    - Add validation on startup to check format

2. **Modify tunnel creation:**
    - Update `start_tunnel()` to call `get_destination_for_port()`
    - Change SSH command target based on returned destination
    - Update PID verification regex to handle both targets

3. **Update monitoring:**
    - Modify `check_tunnels()` to verify correct destination in process list
    - Handle both `host.docker.internal` and `127.0.0.1` patterns

4. **Testing:**
    - Test with no PROXY_DESTINATIONS (should default to host network)
    - Test with mixed destinations
    - Test with only CONTAINER_LOCALHOST destinations
    - Verify existing tunnels continue working

5. **Documentation:**
    - Add PROXY_DESTINATIONS to .env.example
    - Document destination options and format
    - Provide examples for common scenarios

**Rollback strategy:** Remove PROXY_DESTINATIONS parsing. System defaults to HOST_NETWORK for all ports (existing
behavior).

## Open Questions

None - design is ready for implementation.
