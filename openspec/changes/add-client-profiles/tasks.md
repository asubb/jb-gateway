## 1. Profile Directory Auto-Creation

- [x] 1.1 Add profile directory initialization logic (create `~/.jb-gateway/profiles/<name>/` when --profile specified)
- [x] 1.2 Create subdirectories on first use: `ssh/`, `state/`, `logs/`, `secrets/`
- [x] 1.3 Set proper permissions on profile directories (0700 for main dir and secrets)

## 2. Update Client Scripts for Profile Flag Support

- [x] 2.1 Add `--profile <name>` flag parsing to `client/connect.sh` (N/A - functionality in proxy.sh)
- [x] 2.2 Add `--profile <name>` flag parsing to `client/proxy.sh`
- [x] 2.3 Add `--profile <name>` flag parsing to `client/proxy-stop.sh`
- [x] 2.4 Add `--profile <name>` flag parsing to `client/status.sh`
- [x] 2.5 Add `--profile <name>` flag parsing to `client/smb-connect.sh`

## 3. Profile-Aware Configuration Path Resolution

- [x] 3.1 Add config directory resolution logic: if `--profile` specified use `~/.jb-gateway/profiles/<name>/`, else use `~/.jb-gateway/`
- [x] 3.2 Update all client scripts to use resolved config directory for all file operations
- [x] 3.3 Ensure auto-creation of profile directory when profile flag is used

## 4. SSH Integration with Profiles

- [x] 4.1 Update `client/connect.sh` to use profile-specific SSH keys from `<config-dir>/ssh/` (implemented in proxy.sh)
- [x] 4.2 Store tunnel PID in `<config-dir>/state/tunnel_PORT.pid` (implemented in proxy.sh)
- [x] 4.3 Write tunnel logs to `<config-dir>/logs/tunnel_PORT_*.log` (implemented in proxy.sh)
- [x] 4.4 Support profile-specific SSH config from `<config-dir>/ssh/config` if it exists (SSH uses default config resolution)
- [x] 4.5 Fallback to default SSH key locations if profile keys don't exist (SSH uses default key resolution)

## 5. HTTP Proxy Integration with Profiles

- [x] 5.1 Update `client/proxy.sh` to load configuration from `<config-dir>/`
- [x] 5.2 Store proxy tunnel PIDs in `<config-dir>/state/tunnel_PORT.pid`
- [x] 5.3 Write proxy logs to `<config-dir>/logs/proxy_*.log` and `<config-dir>/logs/tunnel_PORT_*.log`
- [x] 5.4 Update `client/proxy-stop.sh` to clean up profile-specific PID files from `<config-dir>/state/`

## 6. Status Command Profile Support

- [x] 6.1 Update `client/status.sh` to show which profile is being used (if --profile specified)
- [x] 6.2 Display profile-specific tunnel and proxy status
- [x] 6.3 Read PID files from profile-specific locations when --profile used

## 7. Testing and Validation

- [ ] 7.1 Test running client commands without --profile (verify existing behavior unchanged)
- [ ] 7.2 Test running client commands with --profile (verify profile isolation)
- [ ] 7.3 Test auto-creation of profile directories on first use
- [ ] 7.4 Test concurrent SSH tunnels from different profiles
- [ ] 7.5 Test concurrent proxy tunnels from different profiles (same port, different profiles)
- [ ] 7.6 Test that profiles can use same port numbers without conflict
- [ ] 7.7 Test status command with and without --profile flag

## 8. Documentation

- [x] 8.1 Update README with profile support overview
- [x] 8.2 Document `--profile <name>` flag usage on all client commands
- [x] 8.3 Document profile directory structure (`~/.jb-gateway/profiles/<name>/`)
- [x] 8.4 Document that users must configure different ports for different profiles
- [x] 8.5 Add examples of multi-profile workflows
- [x] 8.6 Document how to manually manage profiles (ls, rm commands)
