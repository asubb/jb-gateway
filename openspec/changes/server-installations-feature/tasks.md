## 1. Create Installation Manifest

- [ ] 1.1 Create default installations manifest at `src/docker/installations.yaml` with sdkman and chromium-vnc
- [ ] 1.2 Add manifest schema version field for future compatibility
- [ ] 1.3 Document manifest format in comments within the file
- [ ] 1.4 Add `.gitignore` entry for `server/installations.yaml` (custom user overrides)

## 2. Update Dockerfile for Manifest-Based Installation

- [ ] 2.1 Add YAML parsing logic to Dockerfile (using yq which is already installed)
- [ ] 2.2 Create shell function to parse and execute installation commands from manifest
- [ ] 2.3 Update Dockerfile to read default manifest and execute installations
- [ ] 2.4 Update Dockerfile to check for custom manifest and merge/add additional installations
- [ ] 2.5 Ensure installations run as appropriate user (root for system packages, jb-gateway for user tools)
- [ ] 2.6 Verify existing hardcoded installations (git, ssh, samba, docker-cli, nodejs, openspec) remain unchanged

## 3. Update run.sh for Manifest-Based Mounts and Ports

- [ ] 3.1 Add function to parse manifest and extract mount configurations
- [ ] 3.2 Create host directories under `~/.jb-gateway` for each mount if they don't exist
- [ ] 3.3 Generate Docker volume mount flags from manifest mount declarations
- [ ] 3.4 Add function to parse manifest and extract port configurations
- [ ] 3.5 Generate Docker port mapping flags from manifest port declarations
- [ ] 3.6 Merge manifest-based mounts with existing HOST_DIRS from host.env (backward compatibility)
- [ ] 3.7 Ensure hardcoded ports (SSH 1022, SMB 139/445) remain mapped

## 4. Create Installation Validation Script

- [ ] 4.1 Create validation script at `src/docker/validate-installations.sh`
- [ ] 4.2 Add logic to verify each installed software is accessible
- [ ] 4.3 Add logic to verify mounted directories are accessible and have correct permissions
- [ ] 4.4 Add logic to log port mappings for documentation purposes
- [ ] 4.5 Format validation output with clear success/failure messages

## 5. Integrate Validation into Container Startup

- [ ] 5.1 Copy validation script to container in Dockerfile
- [ ] 5.2 Update `entrypoint.sh` or `start-services.sh` to run validation on startup
- [ ] 5.3 Make validation non-blocking (log warnings but don't prevent startup)
- [ ] 5.4 Add environment variable to disable validation if needed (e.g., SKIP_VALIDATION=true)

## 6. Create Example Custom Manifest

- [ ] 6.1 Create example custom manifest at `server/installations.yaml.example`
- [ ] 6.2 Include examples for common use cases (maven, gradle via sdkman, custom binary tools)
- [ ] 6.3 Document how to enable custom manifest (copy example to `server/installations.yaml`)
- [ ] 6.4 Add comments explaining each section and available options

## 7. Update Documentation

- [ ] 7.1 Document installation manifest format in README or docs folder
- [ ] 7.2 Document which tools are hardcoded vs configurable
- [ ] 7.3 Document mount directory structure under `~/.jb-gateway`
- [ ] 7.4 Document exposed ports and their purposes
- [ ] 7.5 Add troubleshooting section for common installation issues
- [ ] 7.6 Add examples of customizing installations

## 8. Testing and Validation

- [ ] 8.1 Test build with default manifest produces working container
- [ ] 8.2 Test that all currently installed software still works (sdkman, chromium/noVNC)
- [ ] 8.3 Test custom manifest additions (add a new tool via server/installations.yaml)
- [ ] 8.4 Test backward compatibility with existing host.env and HOST_DIRS
- [ ] 8.5 Test mount directories are created correctly under `~/.jb-gateway`
- [ ] 8.6 Test validation script reports correct status
- [ ] 8.7 Verify hardcoded services (SSH, SMB, git) continue to work
- [ ] 8.8 Test that manifest parsing errors fail build with clear messages
