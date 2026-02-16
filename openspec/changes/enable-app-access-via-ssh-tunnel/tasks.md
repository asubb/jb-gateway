## 1. Configuration Parsing

- [x] 1.1 Add get_destination_for_port() function to parse PROXY_DESTINATIONS variable
- [x] 1.2 Implement format validation for PROXY_DESTINATIONS (PORT:DESTINATION,PORT:DESTINATION)
- [x] 1.3 Add validation for destination values (must be CONTAINER_LOCALHOST or HOST_NETWORK)
- [x] 1.4 Add startup validation that warns about invalid PROXY_DESTINATIONS entries
- [x] 1.5 Load PROXY_DESTINATIONS from client/.env file in environment loading section

## 2. Tunnel Creation Updates

- [x] 2.1 Update start_tunnel() to call get_destination_for_port() for each port
- [x] 2.2 Modify SSH tunnel command to use 127.0.0.1 target for CONTAINER_LOCALHOST destination
- [x] 2.3 Keep host.docker.internal target for HOST_NETWORK destination (existing behavior)
- [x] 2.4 Update tunnel startup log messages to display destination (e.g., "Port 3000: Starting tunnel to CONTAINER_LOCALHOST...")
- [x] 2.5 Update PID file validation regex to match both host.docker.internal and 127.0.0.1 patterns

## 3. Tunnel Monitoring Updates

- [x] 3.1 Update check_tunnels() process verification to handle both destination patterns
- [x] 3.2 Modify grep pattern in tunnel health check to match either host.docker.internal or 127.0.0.1
- [x] 3.3 Ensure tunnel restart logic preserves the correct destination for each port

## 4. Testing

- [x] 4.1 Test with no PROXY_DESTINATIONS set (verify default HOST_NETWORK behavior)
- [x] 4.2 Test with single CONTAINER_LOCALHOST destination
- [x] 4.3 Test with mixed destinations (some CONTAINER_LOCALHOST, some HOST_NETWORK)
- [x] 4.4 Test with all ports using CONTAINER_LOCALHOST
- [x] 4.5 Test invalid PROXY_DESTINATIONS format (verify validation warnings)
- [x] 4.6 Test with auto-refresh enabled to verify monitoring works with both destinations
- [x] 4.7 Verify existing tunnels continue working without configuration changes

## 5. Documentation

- [x] 5.1 Add PROXY_DESTINATIONS to client/.env.example with example values
- [x] 5.2 Document PROXY_DESTINATIONS format in client/README.md or inline comments
- [x] 5.3 Add usage examples for common scenarios (dev server on container localhost)
- [x] 5.4 Document that container services must bind to 127.0.0.1 or 0.0.0.0 for CONTAINER_LOCALHOST destination
- [x] 5.5 Update help message in show_help() function to mention PROXY_DESTINATIONS option
