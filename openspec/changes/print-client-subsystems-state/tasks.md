## 1. Script Setup

- [ ] 1.1 Create client/status.sh with bash shebang and basic structure
- [ ] 1.2 Set executable permissions on status.sh (chmod +x)
- [ ] 1.3 Define color codes for output formatting (GREEN, RED, YELLOW, BLUE, NC)
- [ ] 1.4 Define status symbols (✓, ✗, ⚠, ℹ)
- [ ] 1.5 Add platform detection logic using $OSTYPE

## 2. Configuration Reading

- [ ] 2.1 Implement function to check if client/.env exists
- [ ] 2.2 Implement function to read PROXY_PORTS from .env
- [ ] 2.3 Implement function to read SSH settings (SSH_HOST, SSH_PORT, SSH_USER) from .env
- [ ] 2.4 Implement function to read SMB settings (SMB_HOST, SMB_USER) from .env
- [ ] 2.5 Implement function to display configuration section with file location

## 3. HTTP Proxy Tunnel Status

- [ ] 3.1 Implement function to check if ~/.jb-gateway/proxy/ directory exists
- [ ] 3.2 Implement function to find all proxy_*.pid files in ~/.jb-gateway/proxy/
- [ ] 3.3 Implement function to read and validate PID from file (handle empty/malformed files)
- [ ] 3.4 Implement function to check if PID process is running using ps -p
- [ ] 3.5 Implement function to verify process command line matches SSH tunnel pattern
- [ ] 3.6 Implement function to calculate tunnel uptime from process start time
- [ ] 3.7 Implement function to extract port number from PID filename
- [ ] 3.8 Implement function to display tunnel status (port, PID, uptime, health indicator)
- [ ] 3.9 Implement function to detect and mark stale PID files
- [ ] 3.10 Implement function to check monitor.pid status separately

## 4. SMB Mount Status

- [ ] 4.1 Implement platform-specific function to list SMB mounts (macOS: mount -t smbfs, Linux: mount -t cifs)
- [ ] 4.2 Implement function to parse mount output for share name and host
- [ ] 4.3 Implement function to check if mount point directory exists
- [ ] 4.4 Implement function to verify mount accessibility using test -r
- [ ] 4.5 Implement function to display mount status (mount point, share, host, health indicator)
- [ ] 4.6 Implement function to handle case when no SMB mounts are active

## 5. Status Summary

- [ ] 5.1 Implement function to count configured proxy ports from PROXY_PORTS
- [ ] 5.2 Implement function to count active tunnel PIDs
- [ ] 5.3 Implement function to compare active vs configured tunnels
- [ ] 5.4 Implement function to determine overall health status (OK/WARNING/ERROR)
- [ ] 5.5 Implement function to highlight missing/inactive configured subsystems
- [ ] 5.6 Implement function to display summary section

## 6. Output Formatting

- [ ] 6.1 Implement function to print header with timestamp
- [ ] 6.2 Implement function to print section headers (HTTP Proxy Tunnels, SMB Mounts, etc.)
- [ ] 6.3 Implement function to align columns in tabular output
- [ ] 6.4 Implement function to display log file locations (~/. jb-gateway/logs/)
- [ ] 6.5 Implement main output orchestration that calls all section functions in order

## 7. Error Handling

- [ ] 7.1 Handle case when ~/.jb-gateway/ directory does not exist
- [ ] 7.2 Handle permission errors reading PID files with clear messages
- [ ] 7.3 Handle permission errors reading log directory with clear messages
- [ ] 7.4 Handle race conditions when PID file is deleted between read and validation
- [ ] 7.5 Ensure script continues with partial information if some checks fail
- [ ] 7.6 Add error suppression (2>/dev/null) for expected failures

## 8. Testing and Validation

- [ ] 8.1 Test script with no active tunnels or mounts
- [ ] 8.2 Test script with active tunnels (verify PID validation works)
- [ ] 8.3 Test script with stale PID files (verify stale detection)
- [ ] 8.4 Test script with missing .env file (verify defaults are shown)
- [ ] 8.5 Test script with active SMB mounts (macOS or Linux)
- [ ] 8.6 Test script on macOS platform
- [ ] 8.7 Test script on Linux platform
- [ ] 8.8 Verify script has no side effects (read-only operations)
- [ ] 8.9 Verify script can be run multiple times with consistent results
