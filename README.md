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

## Known Issues

- If JetBrains Gateway fails to open or create an existing project with cache-related errors, try the following:
    1. Stop the container
    2. Remove the `~/.jb-gateway/.cache` directory
    3. Restart the container and create the project again
