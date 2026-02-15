## Why

Document the current scope of JB Gateway as a baseline specification. This establishes a clear reference point for all existing capabilities, making it easier to track future changes, maintain consistency, and onboard new contributors or AI agents working on the project.

## What Changes

This change introduces comprehensive specification documentation for all existing JB Gateway capabilities:

- Document the Docker-based isolated environment architecture
- Specify SSH remote access and authentication mechanisms
- Define Docker-in-Docker integration and capabilities
- Document SDKMAN SDK management integration
- Specify OpenSpec workflow integration for AI-assisted development
- Define AI agent sandboxing and security boundaries
- Document HTTP proxy tunneling system with multi-port support
- Specify host SSH back-channel for macOS environments
- Define SMB file sharing capabilities and configuration
- Document noVNC remote Chrome access system
- Specify project directory mounting and configuration
- Document build, run, and management scripts

## Capabilities

### New Capabilities
- `docker-environment`: Docker-based isolated container environment with configurable mounts and environment variables
- `ssh-access`: SSH server for remote development with JetBrains Gateway integration
- `docker-in-docker`: Docker CLI access within container connected to host Docker daemon
- `sdk-management`: SDKMAN integration for managing Java, Gradle, Maven and other SDK versions
- `openspec-workflow`: OpenSpec integration for spec-driven development with AI agents
- `security-sandboxing`: AI agent sandboxing with blast radius limitation and controlled access boundaries
- `http-proxy`: Client-side HTTP proxy for tunneling requests through the gateway with multi-port support
- `host-ssh-tunnel`: SSH back-channel from container to macOS host for authorized host access
- `smb-sharing`: Samba file sharing for network access to projects directory
- `remote-chrome`: noVNC-based remote Chrome access for web debugging and development
- `container-lifecycle`: Server-side scripts for building, running, and stopping the gateway container
- `client-tools`: Client-side utilities for SMB mounting, proxy management, and remote connectivity

### Modified Capabilities
<!-- No existing capabilities are being modified - this is initial baseline documentation -->

## Impact

This change creates the foundational specification documentation for the entire JB Gateway project:

- **Code Coverage**: All server scripts (`server/build.sh`, `server/run.sh`, `server/stop.sh`), client scripts (`client/proxy.sh`, `client/proxy-stop.sh`, `client/smb-connect.sh`), and Docker configuration
- **Configuration**: Documents `host.env` configuration system, SSH setup, SMB configuration, proxy settings
- **Services**: SSH (port 1022), SMB (ports 139, 445), noVNC (port 6080), host SSH (port 2022 on macOS), configurable HTTP proxy ports
- **Dependencies**: Docker, sshpass, various Linux utilities within container
- **Architecture**: Establishes clear boundaries between server-side (Docker host), container environment, and client-side tooling
- **Security Model**: Documents the security boundaries, authentication mechanisms, and sandboxing approach
- **Integration Points**: OpenSpec workflow, JetBrains Gateway, SDKMAN, Docker daemon

No code changes are required - this is documentation-only to establish the baseline specification.
