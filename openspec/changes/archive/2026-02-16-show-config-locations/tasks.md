## 1. Create config command scripts

- [x] 1.1 Create server/config.sh script
- [x] 1.2 Create client/config.sh script
- [x] 1.3 Make scripts executable
- [x] 1.4 Update installer to integrate config commands into jbg wrapper
- [x] 1.5 Add config subcommands to help documentation

## 2. Implement shared formatting utilities

- [x] 2.1 Create lib/config-display.sh with color and symbol constants (matching status.sh)
- [x] 2.2 Add function to format file location with existence indicator (✓/⚠)
- [x] 2.3 Add function to format directory location with existence indicator (✓/ℹ)
- [x] 2.4 Add function to display section separator lines
- [x] 2.5 Add function to read and parse .env files

## 3. Implement server config command

- [x] 3.1 Detect server/host.env location and check existence
- [x] 3.2 Display "Configuration Files:" section with host.env path and indicator
- [x] 3.3 Parse and display server configuration values (PROJECTS_DIR, HOST_DIRS, CONTAINER_ENV, SMB_ENABLED, etc.)
- [x] 3.4 Display "Current Values:" section with formatted key-value pairs
- [x] 3.5 Handle missing host.env with appropriate warning

## 4. Implement client config command

- [x] 4.1 Detect client/.env location and check existence
- [x] 4.2 Display "Configuration Files:" section with .env path and indicator
- [x] 4.3 Parse and display client configuration values (SSH_HOST, SSH_PORT, PROXY_PORTS, SMB_HOST, etc.)
- [x] 4.4 Display "Runtime Directories:" section with PID_DIR and LOG_DIR paths and indicators
- [x] 4.5 Handle missing .env with appropriate warning

## 5. Testing and validation

- [x] 5.1 Test jbg help output
- [x] 5.2 Test jbg server config when server/host.env exists
- [x] 5.3 Test jbg server config when server/host.env does not exist
- [x] 5.4 Test jbg client config when client/.env exists
- [x] 5.5 Test jbg client config when client/.env does not exist
- [x] 5.6 Test jbg client config runtime directory display
- [x] 5.7 Verify visual formatting matches status.sh style
