## Why

Developers need to access web applications running inside the container (e.g., development servers on localhost:3000,
localhost:8080) from their client machine's browser. The current HTTP proxy only forwards to the remote host network,
not to the container's own localhost where development servers typically run.

## What Changes

- Extend HTTP proxy to support proxying to container's localhost (not just remote host network)
- Add client configuration to specify proxy destination (host network vs container localhost)
- Allow per-port destination configuration (e.g., port 3000 → container localhost, port 80 → host network)
- Update proxy routing logic to handle both destinations through the double-SSH hop architecture

## Capabilities

### New Capabilities

### Modified Capabilities

- `http-proxy`: Add container localhost as a proxy destination option alongside existing host network proxying,
  configurable per-port in client settings

## Impact

- **Proxy routing logic**: Update gateway proxy forwarding to route to container localhost when configured
- **Client configuration**: Extend client/.env to specify proxy destinations (HOST_NETWORK or CONTAINER_LOCALHOST)
- **Gateway SSH commands**: Modify SSH tunnel commands to support localhost forwarding
- **Documentation**: Document how to configure proxy destinations for different use cases
- **Backward compatibility**: Ensure existing host network proxying continues to work as default
