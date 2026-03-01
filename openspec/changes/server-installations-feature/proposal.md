## Why

The jb-gateway server needs a declarative way to define and manage installation requirements (software packages,
directory mounts, exposed ports) for development environments. Currently, these requirements are scattered across Docker
configuration files and shell scripts, making it difficult to understand, modify, or extend the server's capabilities.

## What Changes

- Add a declarative installation manifest format for defining server requirements
- Implement installation management for pre-installed software packages
- Add support for defining directory mount points from container paths to host `~/.jb-gateway` subdirectories
- Add support for declaring exposed ports and their purposes
- Create validation and verification tools for installation requirements
- Provide documentation and examples for common installation patterns

## Capabilities

### New Capabilities

- `installation-manifest`: Declarative format for defining software packages, directory mounts, ports, and other
  installation requirements
- `software-installation`: Management of pre-installed software tools with version control and verification (default
  configuration includes git, gradle, mvn, sdkman, built-in browser)
- `directory-mounts`: Configuration and management of directory mount points from container paths to host
  `~/.jb-gateway` subdirectories with permissions and validation
- `port-configuration`: Declaration and management of exposed ports with metadata (purpose, protocol, default values)

### Modified Capabilities

- `docker-environment`: Extend to consume installation manifests for Docker container configuration
- `container-lifecycle`: Update to validate and verify installation requirements during container startup

## Impact

- **Docker Configuration**: `Dockerfile`, `docker-compose.yml`, and `run.sh` will be modified to consume installation
  manifests
- **Container Initialization**: Startup scripts will be updated to validate installation requirements
- **Documentation**: New guides for defining and managing installation requirements
- **Build Process**: Docker image builds will incorporate software installation steps from manifests
- **Dependencies**: New configuration file format (likely YAML or JSON) for installation manifests
