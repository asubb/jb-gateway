# Project Context: JB Gateway

## Overview

JB Gateway is a secure, Docker-based environment designed for remote development and sandboxing AI agents. It provides a
controlled workspace where projects from the host machine are mounted into an isolated container, limiting the "blast
radius" of AI agents and protecting the host system.

## Tech Stack

- **Containerization**: Docker, Docker-in-Docker (DinD)
- **Base OS**: Ubuntu (within Docker)
- **Remote Access**: SSH (port 1022), noVNC/Remote Chrome (port 6080)
- **File Sharing**: Samba/SMB (ports 139, 445)
- **SDK Management**: SDKMAN! (pre-installed for `jb-gateway` user)
- **Tooling**: Bash scripts (server-side and client-side), OpenSpec CLI
- **Host Integration**: macOS optimization with host-ssh back-channel (port 2022)

## Key Conventions

- **Project Location**: Host projects are mounted to `/home/jb-gateway/projects/` inside the container.
- **Host Networking**: Use `host.docker.internal` to access services running on the host from within the container.
- **Service Management**: Use `server/build.sh`, `server/run.sh`, and `server/stop.sh` for lifecycle management.
- **Client Access**: Client scripts are located in `client/` (e.g., `proxy.sh`, `smb-connect.sh`).
- **Development Workflow**: Spec-driven development using OpenSpec.

## Architecture

JB Gateway creates an isolated boundary. The host machine (typically macOS) runs a Docker container. The container has
access to the host's Docker daemon for DinD capabilities but is otherwise restricted. A dedicated `jb-gateway` user is
used for all development activities.

## Configuration

- `server/host.env`: Configures server-side settings.
- `client/.env`: Configures client-side proxy and connection settings.
- `openspec/config.yaml`: OpenSpec workflow configuration.
