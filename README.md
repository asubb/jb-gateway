# JB Gateway: Remote Development & AI Agent Sandbox

A secure, Docker-based environment for remote development and sandboxing AI agents. This gateway provides a controlled workspace with your projects directory mounted inside, specifically designed to limit the blast radius of AI agents and protect your host system.

![JB Gateway architecture](.assets/architecture.png)

## Quick Start

### 1. Installation

Install jb-gateway with a single command:

```bash
# Install both Server and Client components
curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=both
```

*Modes: `server`, `client`, or `both`.*

> [!TIP]
> **Custom Branch**: To install from a specific branch:
> `curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/<branch>/install.sh | JBG_BRANCH=<branch> bash -s -- --mode=both`

### 2. Start the Server

```bash
jbg server start
# Or manually: ./server/run.sh
```

### 3. Connect

*   **SSH**: `ssh -p 1022 jb-gateway@localhost` (Password: `password`)
*   **JetBrains Gateway**: Connect via SSH to `localhost:1022`.
*   **Web Browser (noVNC)**: [http://localhost:6080/vnc.html](http://localhost:6080/vnc.html)

---

## Core Features

- **Sandbox AI Agents**: Restricted environment to protect your host system.
- **Remote Development**: Consistent environment fully compatible with JetBrains Gateway.
- **Tool-Rich**: Pre-installed with git, curl, jq, yq, and [SDKMAN!](docs/sdk-management.md).
- **Docker-in-Docker**: Run Docker services from within the sandbox.
- **OpenSpec Workflow**: Native support for spec-driven development.

## User Commands (`jbg`)

The `jbg` tool is the main interface for managing your gateway:

- `jbg help`: Show all available commands.
- `jbg update`: Keep your installation current.
- `jbg server [start|stop|build|status|help]`: Manage the server container.
- `jbg client [status|proxy|help]`: Manage client connections and tunnels.

### Server Commands
- `jbg server start`: Start the jb-gateway container
- `jbg server stop`: Stop the jb-gateway container
- `jbg server build`: Build the Docker image
- `jbg server status`: Check if container is running
- `jbg server help`: Show server command help

### Client Commands
- `jbg client status`: Show status of all client subsystems
- `jbg client proxy start`: Start proxy tunnels
- `jbg client proxy stop`: Stop proxy tunnels
- `jbg client help`: Show client command help

## Advanced Topics & Documentation

For detailed guides and configuration, see the `docs/` directory:

- [Container Configuration](docs/configuration.md) - Customizing `host.env` and mounts.
- [SDK Management](docs/sdk-management.md) - Using SDKMAN! for Java, Gradle, etc.
- [Docker-in-Docker](docs/docker-in-docker.md) - Accessing host Docker and services.
- [OpenSpec Workflow](docs/openspec.md) - AI-driven development with Claude.
- [HTTP Proxy Tunnels](docs/http-proxy.md) - Accessing remote services via proxy.
- [SMB File Sharing](docs/smb-sharing.md) - Mounting projects as a network drive.
- [Remote Chrome Access](docs/remote-chrome.md) - Using the browser inside the container.
- [Host Connectivity](docs/host-connectivity.md) - Connecting back to the host machine.

## Prerequisites

- **Server**: Docker, Bash shell.
- **Client**: Bash shell, `sshpass` (for proxy usage).

## Security Note

This container is intended for development and sandboxing. It is not secured for production use. Default credentials are `jb-gateway:password`.

## Troubleshooting

- **Command not found**: Run `source ~/.bashrc` (or `.zshrc`).
- **Cache issues**: If files are out of sync, try `docker volume rm jb-gateway-cache`.
- See [Manual Installation](docs/configuration.md) if the installer fails.
