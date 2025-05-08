# JB Gateway

A Docker-based SSH gateway container that provides a development environment with your projects directory mounted inside, specifically designed to work with JetBrains Gateway.

## Description

JB Gateway creates a Docker container with SSH access, allowing you to:
- Connect to a consistent development environment via SSH
- Access your local projects directory inside the container
- Use common development tools (git, curl, etc.)
- Persist SSH keys and configuration between container restarts
- Provide a tunnel for JetBrains Gateway to access your project files remotely

The current setup is optimized for:

1. Java applications with the Gradle build system
2. Running and managing Docker containers and services from within the development environment
3. The host machine is macOS

## Prerequisites

- Docker installed on your system
- Bash shell
- sshpass (required for password authentication with the proxy)
  - On Ubuntu/Debian: `sudo apt-get install sshpass`
  - On macOS: `brew install hudochenkov/sshpass/sshpass`

## Installation

1. Clone this repository:
   ```
   git clone <repository-url>
   cd jb-gateway
   ```

2. Build the Docker image:
   ```
   ./build.sh
   ```

## Usage

### Starting the Container

Run the container with:

```
./run.sh [PROJECTS_DIRECTORY]
```

Where:
- `PROJECTS_DIRECTORY` is an optional parameter specifying the directory to mount (defaults to ~/projects)

Example:
```
./run.sh ~/my-projects
```

### Connecting to the Container

After starting the container, you can connect to it using SSH:

```
ssh -p 1022 jb-gateway@localhost
```

Default credentials:
- Username: jb-gateway
- Password: password

### SSH Keys

The container generates SSH keys on the first run. These keys are persisted in the `~/.jb-gateway/.ssh/` directory on your host machine.

## Using with JetBrains Gateway

JetBrains Gateway is a tool that allows you to connect to remote development environments from your local JetBrains IDEs. This container is specifically designed to work as a remote development environment for JetBrains Gateway.

### Connecting with JetBrains Gateway

1. Start the container using the instructions above
2. Open JetBrains Gateway on your local machine
3. Select the "Connect to SSH" option
4. Enter the following connection details:
   - Host: localhost
   - Port: 1022
   - Username: jb-gateway
   - Password: password
5. Select the project you want to open from the `/home/jb-gateway/projects/` directory
6. JetBrains Gateway will establish a secure tunnel to your container and open the project in your preferred IDE

JetBrains Gateway will use the SSH connection to create a tunnel to your project files, allowing you to develop remotely while using your local IDE.

## Security Note

This container is intended for development purposes only and is not secured for production use. The default password is hardcoded and SSH root login is enabled.

## Using the HTTP Proxy

JB Gateway includes a proxy feature that allows you to forward HTTP requests from your local machine to the remote host via the gateway container. This is useful when you need to access services running on the remote host network.

### Configuring Ports

You can configure which ports to tunnel in two ways:

1. Using a `.env` file (recommended for multiple ports):
   ```
   # .env file example
   PROXY_PORTS=8080,8081,8082-8085

   # Optional SSH settings
   SSH_PORT=1022
   SSH_USER=jb-gateway
   SSH_HOST=localhost
   SSH_PASSWORD=password
   ```

2. Using command-line arguments (for quick, one-time tunneling):
   ```bash
   ./proxy.sh -p 8080,8081,8082-8085
   ```

The port specification supports:
- Individual ports: `8080,8081,8082`
- Port ranges: `8082-8085` (equivalent to 8082,8083,8084,8085)
- Combinations: `8080,8081,8082-8085`

### Starting the Proxy

Run the proxy with:

```bash
./proxy.sh [options]
```

Options:
- `-p, --ports PORTS`: Comma-separated list of ports or port ranges to tunnel
- `-s, --ssh-port PORT`: SSH port for jb-gateway container (default: from .env or 1022)
- `-u, --user USER`: SSH user for jb-gateway container (default: from .env or jb-gateway)
- `-w, --password PASS`: SSH password for jb-gateway container (default: from .env or none)
- `-h, --help`: Show help message

Example:
```bash
./proxy.sh -p 8080,8081,8082-8085
```

With password:
```bash
./proxy.sh -p 8080,8081,8082-8085 -w password
```

This will set up tunnels for ports 8080, 8081, 8082, 8083, 8084, and 8085, forwarding each port from your local machine to the same port on the remote host via the jb-gateway container.

The proxy script automatically checks if tunnels are already running for the specified ports:
- If a tunnel is already running for a port, it will be skipped (verified by both PID and process details)
- If a process with the saved PID exists but is not actually a tunnel for the specific port, a new tunnel will be started
- If a stale PID file is found (process not running), a new tunnel will be started
- Only ports without active tunnels will have new tunnels created

This allows you to run the proxy script multiple times without creating duplicate tunnels, and ensures that only the necessary tunnels are started.

All tunnels run in the background, allowing you to continue using your terminal.

### Stopping the Proxy

To stop all running proxy tunnels:

```bash
./proxy-stop.sh
```

This will terminate all proxy tunnels that were started by the proxy.sh script.

### Proxy Logs

The proxy system creates several types of log files for easier troubleshooting:

1. **Main proxy script logs**:
   All output from the proxy.sh script is redirected to a log file:
   ```
   ~/.jb-gateway/logs/proxy_YYYYMMDD_HHMMSS.log
   ```

2. **Individual tunnel logs**:
   Each tunnel has its own dedicated log file:
   ```
   ~/.jb-gateway/logs/tunnel_PORT_YYYYMMDD_HHMMSS.log
   ```
   Where `PORT` is the port number being tunneled.

3. **Proxy stop script logs**:
   Output from the proxy-stop.sh script is also logged:
   ```
   ~/.jb-gateway/logs/proxy-stop_YYYYMMDD_HHMMSS.log
   ```

In all cases, `YYYYMMDD_HHMMSS` is the timestamp when the respective script was started.

The main script output is also displayed in the terminal while the scripts run, but having logs saved to files makes it easier to debug issues that might occur while tunnels are running in the background. The individual tunnel logs are particularly useful for troubleshooting connection issues with specific ports.

## Known Issues

- If you experience any persistent issues with the cache, you can reset the cache volume:
    ```bash
    docker stop jb-gateway
    docker volume rm jb-gateway-cache
    ./run.sh
    ```
