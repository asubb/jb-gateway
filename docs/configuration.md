# Container Configuration

You can customize the container environment by creating a `host.env` file in the `server/` directory.

A template file `host.env.example` is provided as a reference. Copy it to `host.env` and customize as needed:

```bash
cp server/host.env.example server/host.env
```

Key configuration options:

- `PROJECTS_DIR`: The projects directory to mount (defaults to `~/projects`).
- `HOST_DIRS`: Additional directories to mount (format: `/host/path:/container/path`).
- `CONTAINER_ENV`: Global environment variables to set in the container.
- `DISABLE_HOST_SSH`: Set to `true` to disable the back-tunnel SSH server on macOS.

## Manual Installation

If you prefer manual installation:

1. Clone this repository:
   ```shell
   git clone https://github.com/asubb/jb-gateway
   cd jb-gateway
   ```

2. Build the Docker image:
   ```shell
   ./server/build.sh
   ```

### Installation from Custom Branch

To install or update from a specific branch (e.g., `develop`), use the `JBG_BRANCH` environment variable along with the
corresponding branch URL:

```bash
curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/develop/install.sh | JBG_BRANCH=develop bash -s -- --mode=both
```

This ensures that subsequent updates via `jbg update` will also track the same branch.
