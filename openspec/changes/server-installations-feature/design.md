## Context

The jb-gateway container currently has installation requirements (software packages, directory mounts, exposed ports) hardcoded in multiple places:
- Software packages are listed in `Dockerfile` RUN commands
- Directory mounts are configured in `run.sh` with inline logic
- Port mappings are scattered across `run.sh` and documentation

This makes it difficult to:
- Understand what's installed and why
- Add new tools or modify configurations
- Maintain consistency between documentation and actual configuration
- Customize installations for different use cases

**Stakeholders:**
- Developers extending jb-gateway with new tools
- Users customizing their development environments
- CI/CD systems building container images

**Constraints:**
- Must maintain backward compatibility with existing `host.env` configuration
- Must work with existing Docker and shell script infrastructure
- Changes should not significantly impact build time or container startup time

## Goals / Non-Goals

**Goals:**
- Create a single source of truth for installation requirements via declarative manifest
- Enable easy addition of new software packages without editing Dockerfile
- Provide standard directory mount locations under `~/.jb-gateway` on host
- Document exposed ports with their purposes
- Validate installations at container startup
- Provide sensible defaults while allowing customization

**Non-Goals:**
- Runtime package installation (packages installed during build only)
- Dynamic port allocation (ports remain static, defined in manifest)
- Package dependency resolution (rely on system package managers)
- Cross-platform manifest differences (single manifest for Linux container)
- GUI or web interface for manifest management

## Decisions

### Decision 1: YAML manifest format

**Choice:** Use YAML for the installation manifest file (`installations.yaml`)

**Rationale:**
- Human-readable and commonly used for configuration
- Good support for comments and documentation
- Native YAML parsing available in shell scripts via `yq`
- Consistent with other declarative formats (Kubernetes, Docker Compose, etc.)

**Alternatives considered:**
- JSON: Less human-friendly, no comments
- TOML: Less common, fewer parsing tools available
- Custom DSL: Unnecessary complexity

**Structure:**
```yaml
# Note: Required tools (git, ssh, docker-cli, nodejs, openspec, samba, basic system tools)
# are hardcoded in Dockerfile and not configurable via manifest

installations:
  # SDKMAN for Java/Gradle/Maven version management
  sdkman:
    install: |
      curl -s "https://get.sdkman.io" | bash
      bash -c "source /home/jb-gateway/.sdkman/bin/sdkman-init.sh && sdk version"
    mounts:
      - container_path: /home/jb-gateway/.sdkman
        host_subdir: .sdkman
        mode: rw

  # noVNC + Chromium for browser-based remote desktop
  chromium-vnc:
    install: |
      apt-get install -y novnc websockify x11vnc xvfb fluxbox
      apt-get install -y --no-install-recommends software-properties-common
      add-apt-repository -y ppa:xtradeb/apps
      apt-get update
      apt-get install -y chromium
      apt-get install -y \
        libgtk-4-1 libgraphene-1.0-0 libvpx9 libevent-2.1-7 \
        libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        libgstreamer-plugins-bad1.0-0 libflite1 libavif16 libharfbuzz-icu0 \
        libenchant-2-2 libhyphen0 libwayland-server0 libmanette-0.2-0 \
        libx264-164 libwoff1
    ports:
      - container: 6080
        host: 6080
        purpose: noVNC web interface
        protocol: tcp
      - container: 9222
        host: 9222
        purpose: Chrome DevTools Protocol
        protocol: tcp
    mounts:
      - container_path: /home/jb-gateway/.config/chromium
        host_subdir: .config/chromium
        mode: rw

# Example user customization in server/installations.yaml:
# installations:
#   maven:
#     install: |
#       source /home/jb-gateway/.sdkman/bin/sdkman-init.sh
#       sdk install maven
#     mounts:
#       - container_path: /home/jb-gateway/.m2
#         host_subdir: .m2
#         mode: rw
#
#   custom-tool:
#     install: |
#       wget https://example.com/tool.tar.gz -O /tmp/tool.tar.gz
#       tar -xzf /tmp/tool.tar.gz -C /usr/local/bin
#       chmod +x /usr/local/bin/tool
```

### Decision 2: Software-grouped manifest structure

**Choice:** Group all configuration by software/service, not by type (installation/mounts/ports)

**Rationale:**
- **Cohesion**: Each software entry contains all its related configuration (how to install, what mounts it needs, what ports it uses)
- **Clarity**: Easy to see complete picture of what a tool requires
- **Maintainability**: Adding/removing a tool means editing one section, not three separate lists
- **Optional sections**: Not all software needs all sections (e.g., ssh only needs ports, git only needs installation)
- **Documentation**: Self-documenting - the manifest shows "chromium needs these ports and mounts"

**Alternatives considered:**
- Type-grouped (separate software/mounts/ports sections): Requires cross-referencing multiple sections to understand one tool
- Flat list with tags: Less structured, harder to validate

**Benefits:**
- Remove a tool = delete one entry
- Add a tool = add one complete entry
- Understand tool requirements = read one section

### Decision 3: Build-time vs runtime installation

**Choice:** Install software packages during Docker image build, validate at runtime

**Rationale:**
- Faster container startup (packages pre-installed)
- Reproducible builds (same image contains same tools)
- Better error detection (build fails immediately if package unavailable)
- Aligns with Docker best practices (immutable images)

**Alternatives considered:**
- Runtime installation: Slower startup, inconsistent environments
- Hybrid approach: Unnecessary complexity

**Implementation:**
- Dockerfile will source manifest and install packages
- Container startup script will verify installations (quick checks)

### Decision 4: Directory mount location strategy

**Choice:** All host mounts go under `~/.jb-gateway/<subdirectory>`

**Rationale:**
- Single predictable location for all jb-gateway data
- Easy to backup/sync entire jb-gateway configuration
- Prevents cluttering user home directory
- Clear separation between host and container paths

**Alternatives considered:**
- Direct home directory mounts: Clutters `~/`, harder to manage
- Arbitrary host paths: User confusion, harder to document
- Fixed paths only: Less flexible for edge cases

**Backward compatibility:**
- Existing `HOST_DIRS` in `host.env` continues to work
- Manifest mounts and `HOST_DIRS` are merged (not mutually exclusive)

### Decision 5: Installation manifest location

**Choice:**
- Default manifest: `src/docker/installations.yaml` (in repository)
- Custom override: `server/installations.yaml` (git-ignored, optional)

**Rationale:**
- Default manifest provides sensible defaults for all users
- Custom override allows user-specific tools without modifying source
- Custom override is git-ignored to prevent accidental commits
- Build script checks for custom first, falls back to default

**Alternatives considered:**
- Single location only: No customization without editing source
- Environment variable path: Over-engineered for this use case

### Decision 6: Software installation methods

**Choice:** Support multiple installation methods via `install` field
- `apt`: System package manager
- `sdkman`: SDK manager for JVM tools
- `script`: Custom installation script path
- `binary`: Download and extract binary

**Rationale:**
- Different tools have different optimal installation methods
- Flexibility for future additions
- Clear documentation of how each tool is installed

**Implementation:**
- Dockerfile generates installation scripts from manifest
- Each method has standardized handler in build process

### Decision 7: Validation strategy

**Choice:** Lightweight validation on container startup
- Check software version (if specified)
- Verify mount points are accessible
- Log port mappings (no validation needed, Docker handles)

**Rationale:**
- Fast startup (validation in parallel, non-blocking)
- Early detection of misconfiguration
- Helpful error messages for troubleshooting

**Alternatives considered:**
- No validation: Silent failures, harder to debug
- Heavy validation: Slow startup, diminishing returns

## Risks / Trade-offs

### Risk: Increased Dockerfile complexity
**Impact:** Dockerfile needs to parse YAML and handle multiple installation methods
**Mitigation:**
- Use well-tested `yq` for YAML parsing
- Separate installation logic into shell functions
- Add validation during build to fail fast on errors

### Risk: Build time increase
**Impact:** Parsing manifest and installing packages may slow builds
**Mitigation:**
- Docker layer caching minimizes rebuilds
- Only changed packages trigger reinstallation
- Most common case (no manifest changes) has no overhead

### Risk: Breaking changes for existing users
**Impact:** Changes to `run.sh` and `Dockerfile` could break existing workflows
**Mitigation:**
- Maintain backward compatibility with `host.env` and `HOST_DIRS`
- Default manifest replicates current hardcoded configuration
- Test with existing setups before release

### Risk: Schema evolution
**Impact:** Future manifest changes may break old manifests
**Mitigation:**
- Version manifest format (e.g., `version: 1` field)
- Validate schema during build with clear error messages
- Document breaking changes in migration guides

### Trade-off: Flexibility vs simplicity
**Decision:** Support multiple installation methods (apt, sdkman, script, binary)
**Trade-off:** More complex implementation, more to document
**Justification:** Necessary for real-world tools (gradle via sdkman, custom binaries)

### Trade-off: Validation depth
**Decision:** Lightweight validation (version checks, accessibility)
**Trade-off:** Won't catch all issues (e.g., broken symlinks, missing dependencies)
**Justification:** Container startup should be fast; Docker build failures are primary quality gate

## Migration Plan

### Phase 1: Create manifest and tooling (this change)
1. Create default `src/docker/installations.yaml` matching current hardcoded setup
2. Update `Dockerfile` to parse manifest and install packages
3. Update `run.sh` to read manifest and configure mounts/ports
4. Add validation script for container startup
5. Test that default manifest produces identical container to current setup

### Phase 2: Documentation and examples
1. Document manifest format in README
2. Provide example custom manifests (minimal, full-featured, specialized)
3. Add troubleshooting guide for common issues

### Phase 3: Optional enhancements (future)
- Manifest validation tool (`validate-installations.sh`)
- Pre-built images for common configurations
- Manifest composition (extend default with additions)

### Rollback Strategy
If issues arise:
- Default manifest can be empty (fallback to hardcoded Dockerfile)
- Manifest parsing failures fail the build (safe)
- Users can delete custom manifest to revert to defaults

### Compatibility Testing
- Verify existing `host.env` configurations work unchanged
- Test custom `HOST_DIRS` mount paths
- Confirm port mappings remain accessible
- Validate SDKMAN and other critical tools function correctly

## Open Questions

1. **Should manifest support conditional installations?**
   - Example: Install tool X only on ARM architecture
   - Decision: Defer to future enhancement if needed

2. **How to handle software version conflicts?**
   - Example: User requests gradle 7.x but manifest requires 8.x
   - Current approach: Last writer wins (build-time installation)
   - May need explicit conflict detection in future

3. **Should mount directories be pre-created or created on-demand?**
   - Current design: Create on-demand during `run.sh`
   - Alternative: Pre-create common ones in Dockerfile
   - Decision: On-demand is more flexible (supports custom manifests)
