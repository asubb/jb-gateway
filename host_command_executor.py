#!/usr/bin/env python3
"""
Host Command Executor

This script allows executing commands on the host system from within a Docker container.
It can be used in three ways:
1. To start a regular container shell (when no arguments are provided)
2. To execute a single command on the host (when command arguments are provided)
3. To enter an interactive mode where multiple commands can be executed on the host (with 'host-shell' command)

Usage:
  host_command_executor.py [options] [command...]
  host-shell                 # Shortcut to enter interactive host shell mode

Options:
  -u, --username USERNAME  Specify the username to execute commands as (default: current user)
  -h, --help               Show this help message and exit
"""

import argparse
import os
import subprocess
import sys
import pwd

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Execute commands on the host system")
    parser.add_argument("-u", "--username", help="Username to execute commands as")
    parser.add_argument("command", nargs="*", help="Command to execute (if not provided, starts a regular container shell)")
    return parser.parse_args()

def get_user_shell(username):
    """Get the shell for the specified user from the host system."""
    try:
        # Try to get the user's shell from the host
        result = subprocess.run(
            ["getent", "passwd", username],
            capture_output=True,
            text=True,
            check=True
        )

        # Parse the output to get the shell
        user_info = result.stdout.strip().split(":")
        if len(user_info) >= 7:
            return user_info[6]
    except Exception as e:
        print(f"Warning: Could not determine shell for user {username}: {e}", file=sys.stderr)

    # Default to bash if we couldn't determine the shell
    return "/bin/bash"

def execute_host_command(command, username=None):
    """Execute a command on the host system using Docker API.

    Args:
        command: The command to execute on the host
        username: The username to execute the command as (default: current user)

    Returns:
        The exit code of the command
    """

    # If no username specified, use the current user
    if not username:
        username = os.environ.get("HOST_USER", os.environ.get("USER", "root"))

    try:
        # Create a temporary container that:
        # 1. Uses the host's PID namespace (--pid=host)
        # 2. Uses the host's network namespace (--network=host)
        # 3. Mounts the host's filesystem (--volume=/:/host)
        # 4. Runs as the specified user (--user)
        # 5. Executes the command in the host's filesystem (chroot /host)

        # Prepare the Docker command
        docker_cmd = [
            "docker", "run", "--rm",
            "--pid=host",
            "--network=host",
            "--volume=/:/host",
            "--workdir=/host" + os.getcwd(),
            # "--user", username,
            "alpine:latest",
            "chroot", "/host", "sh", "-c", command
        ]

        print(f">>>> Executing {docker_cmd}")

        # Execute the Docker command
        result = subprocess.run(
            docker_cmd,
            stdout=sys.stdout,
            stderr=sys.stderr,
            text=True
        )
        print(f"<<<< Command executed on host successfully with exit code {result.returncode}")


        return result.returncode
    except Exception as e:
        print(f"Error executing command on host: {e}", file=sys.stderr)
        return 1

def interactive_host_shell(username=None):
    """Run an interactive shell that executes commands on the host until 'exit' is typed."""
    # If no username specified, use the current user
    if not username:
        username = os.environ.get("HOST_USER", os.environ.get("USER", "root"))

    # Get the user's shell
    user_shell = get_user_shell(username)
    shell_name = os.path.basename(user_shell)

    print("JB Gateway Host Command Executor")
    print(f"Interactive host shell mode for user: {username} (shell: {shell_name})")
    print("Type 'exit' to quit this mode")
    print()

    # Main command loop
    while True:
        try:
            # Get command from user
            command = input(f"host({username})$ ")

            # Check for exit command
            if command.strip().lower() in ["exit", "quit"]:
                print("Exiting host shell mode")
                return 0

            # Execute the command on the host
            execute_host_command(command, username)

        except KeyboardInterrupt:
            print("\nUse 'exit' to quit")
        except EOFError:
            print("\nExiting host shell mode")
            return 0
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)

def main():
    """Main entry point."""
    # Check if the script is called as "host-shell"
    return interactive_host_shell()

if __name__ == "__main__":
    sys.exit(main())
