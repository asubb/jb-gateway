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

### Container Configuration with host.env

You can customize the container environment by creating a `host.env` file in the project root. This file allows you to configure:

1. **PROJECTS_DIR**: The projects directory to mount in the container
   ```
   PROJECTS_DIR=/path/to/your/projects
   ```
   If not specified, defaults to `$HOME/projects` or the directory provided as command-line argument to `run.sh`.

2. **HOST_DIRS**: Additional directories to mount from host to container
   ```
   HOST_DIRS=/path/on/host:/path/in/container,/another/path/on/host:/another/path/in/container
   ```
   Each mapping should be in the format: `/host/path:/container/path`
   Multiple mappings should be separated by commas.

3. **CONTAINER_ENV**: Global environment variables to set in the container
   ```
   CONTAINER_ENV="VAR1=value1 VAR2=value2 VAR3=~/path"
   ```
   Use `~` to reference the container user's home directory (`/home/jb-gateway`).

4. **DISABLE_HOST_SSH**: Option to disable the installation of the HOST SSH server on macOS
   ```
   DISABLE_HOST_SSH=true
   ```
   By default, on macOS systems, the script installs a standalone SSH server on port 2022 to allow the container to connect back to the host machine. Set this to `true` to disable this feature.

A template file `host.env.example` is provided as a reference. Copy it to `host.env` and customize as needed:
```
cp host.env.example host.env
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

## SMB File Sharing

JB Gateway includes SMB (Samba) file sharing capabilities, allowing you to access your projects directory over the network from other devices.

### Accessing Shared Folders

The container shares the projects directory via SMB with the following details:

- **Share Name**: projects
- **Server Address**: Your host machine's IP address
- **Ports**: 139, 445 (standard SMB ports)
- **Username**: jb-gateway
- **Password**: password

#### From Windows

1. Open File Explorer
2. In the address bar, type `\\your-host-ip\projects` (replace `your-host-ip` with your host machine's IP address)
3. When prompted, enter the username `jb-gateway` and password `password`

#### From macOS

1. In Finder, select "Go" > "Connect to Server..."
2. Enter `smb://your-host-ip/projects` (replace `your-host-ip` with your host machine's IP address)
3. When prompted, enter the username `jb-gateway` and password `password`

#### From Linux

1. Open your file manager
2. Connect to server with the address `smb://your-host-ip/projects` (replace `your-host-ip` with your host machine's IP address)
3. When prompted, enter the username `jb-gateway` and password `password`

Alternatively, you can mount the share using the command line:
```bash
sudo mount -t cifs //your-host-ip/projects /mnt/projects -o username=jb-gateway,password=password
```

### Using the smb-connect.sh Script

JB Gateway includes a convenient script for viewing and mounting SMB shares from the command line:

```bash
./smb-connect.sh
```

#### Viewing Available Shares

To view all available shares on the JB Gateway container:

```bash
./smb-connect.sh view
```

This will display a list of all available shares, including the default "projects" share.

You can also view shares on a specific host by providing the hostname or IP address:

```bash
./smb-connect.sh view 192.168.1.100
```

#### Mounting Shares

To mount a share to a local directory:

```bash
./smb-connect.sh mount <share> <mountpoint>
```

For example, to mount the "projects" share to a directory called "smb-mount" in your home directory:

```bash
./smb-connect.sh mount projects ~/smb-mount
```

You can also mount a share from a specific host by providing the hostname or IP address:

```bash
./smb-connect.sh mount projects ~/smb-mount 192.168.1.100
```

The script will automatically create the mount point directory if it doesn't exist.

#### Configuration

The script reads configuration from `.env` or `host.env` files if they exist. You can customize the following parameters:

- `SMB_HOST`: The default hostname or IP address of the SMB server (default: localhost)
- `SMB_USER`: The username for authentication (default: jb-gateway)
- `SMB_PASSWORD`: The password for authentication (default: password)

You can override the default host by specifying a host directly in the command line.

### Security Note

The SMB share is protected with the same credentials as the SSH access. For production environments, consider changing the default password.

## Directory Synchronization

JB Gateway includes bidirectional directory synchronization tools that allow you to keep two directories in sync. This is useful for synchronizing local and remote project directories.

### Using the Kotlin Application (sync-dirs)

The Kotlin application synchronizes two directories bidirectionally, logging all changes. If there is a conflict (a file has been modified in both directories), it will prompt the user and show the diff.

#### Building and Running the Application

The application comes with a wrapper script that handles building and running the application. To use it:

```bash
./sync-dirs <dir1> <dir2>
```

Example:
```bash
./sync-dirs ~/projects/local ~/projects/remote
```

If you prefer to build and run the application manually:

1. Build the application:
   ```bash
   cd sync
   ./gradlew build
   ```

2. Run the application:
   ```bash
   java -jar build/libs/sync-dirs-1.0-SNAPSHOT.jar <dir1> <dir2>
   ```

#### Monitoring Mode

The application can also run in monitoring mode, continuously watching for changes and synchronizing the directories at regular intervals:

```bash
./sync-dirs --monitor [--interval SECONDS] <dir1> <dir2>
```

Options:
- `--monitor` (or `-m`): Run in monitoring mode, continuously watching for changes
- `--interval SECONDS` (or `-i SECONDS`): Set the interval between checks in monitoring mode (default: 10 seconds)

Example:
```bash
./sync-dirs --monitor --interval 30 ~/projects/local ~/projects/remote
```

This will synchronize the directories every 30 seconds until you press Ctrl+C to stop the monitoring.

#### Ignoring Files and Directories

You can specify files and directories to ignore during synchronization using glob patterns:

```bash
./sync-dirs --ignore 'pattern1,pattern2,...' <dir1> <dir2>
```

Options:
- `--ignore PATTERNS` (or `-g PATTERNS`): Comma-separated list of glob patterns to ignore
- `--log-ignored` (or `-l`): Log ignored files (by default, ignored files are not logged)

Example:
```bash
./sync-dirs --ignore '*.tmp,*.log,build/,node_modules/' ~/projects/local ~/projects/remote
```

This will synchronize the directories while ignoring any files or directories that match the specified patterns.

If you want to see which files are being ignored during synchronization, you can use the `--log-ignored` option:

```bash
./sync-dirs --ignore '*.tmp,*.log,build/,node_modules/' --log-ignored ~/projects/local ~/projects/remote
```

#### Configuration File

Instead of specifying options on the command line, you can use a configuration file:

```bash
./sync-dirs --config <config_file>
```

Options:
- `--config FILE` (or `-c FILE`): Path to the configuration file

Example:
```bash
./sync-dirs --config sync-dirs.conf
```

The configuration file should be in a simple key-value format:

```
# Source and destination directories
DIR1=/path/to/source/directory
DIR2=/path/to/destination/directory

# Files and directories to ignore (optional)
IGNORE=*.tmp,*.log,build/,node_modules/,*.bak

# Monitoring mode (optional, default: false)
MONITOR=false

# Interval in seconds for monitoring mode (optional, default: 10)
INTERVAL=30

# Log ignored files (optional, default: false)
LOG_IGNORED_FILES=false
```

A template file `sync-dirs.conf.example` is provided as a reference. Copy it to `sync-dirs.conf` and customize as needed:
```bash
cp sync-dirs.conf.example sync-dirs.conf
```

#### Features

- Bidirectional synchronization: Changes from both directories are synchronized
- Conflict detection and resolution: When a file has been modified in both directories, the application shows a diff and prompts for resolution
- Handling of deleted files: The application detects files that have been deleted in one directory and prompts for action
- Continuous monitoring: Option to run in monitoring mode, continuously watching for changes
- Ignore patterns: Ability to specify files and directories to ignore during synchronization
- Configuration file: Support for reading options from a configuration file
- Detailed logging: All actions are logged to both the console and a log file
- Colored output: Different types of messages are color-coded for better readability

#### Log Files

The application creates log files in the `~/.sync-dirs/` directory with timestamps in the filename. These logs contain detailed information about all synchronization actions.

### Using the Bash Script (sync-dirs.sh)

For backward compatibility, the original bash script `sync-dirs.sh` is still available with the same functionality as the Kotlin application. See the Kotlin application documentation above for usage details.

## Known Issues

- If you experience any persistent issues with the cache, you can reset the cache volume:
    ```bash
    docker stop jb-gateway
    docker volume rm jb-gateway-cache
    ./run.sh
    ```
