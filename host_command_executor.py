#!/usr/bin/env python3
"""
Host Command Executor for JetBrains Gateway

This script provides functionality to execute commands on the host system from within
a Docker container. It is designed for use in the JetBrains Gateway environment to allow
controlled access to host resources while maintaining security boundaries.

Key features:
- Execute single commands on the host system
- Run interactive shell sessions with host access
- Support for user context switching

Security note: This script uses Docker with host volume mapping to execute commands on the host.
Proper container security configurations and user permissions should be in place.
"""

import argparse
import os
import pwd
import subprocess
import sys


def parse_arguments():
    """
    Parse command line arguments.
    
    Returns:
        argparse.Namespace: An object containing the parsed command-line arguments.
            - username (str, optional): Username to execute commands as on the host
            - command (list, optional): Command and arguments to execute on the host.
                                       If not provided, starts an interactive shell.
    """
    parser = argparse.ArgumentParser(description="Execute commands on the host system")
    parser.add_argument("-u", "--username", help="Username to execute commands as")
    parser.add_argument("command", nargs="*", help="Command to execute (if not provided, starts a regular container shell)")
    return parser.parse_args()

def get_user_shell(username):
    """
    Get the login shell for the specified user from the host system.
    
    This function queries the host's passwd database to determine the default
    shell for the given username. If the user doesn't exist or the shell
    information can't be retrieved, it defaults to '/bin/bash'.
    
    Args:
        username (str): The username to get the shell for
        
    Returns:
        str: Path to the user's shell (defaults to '/bin/bash' if not found)
    """
    try:
        # Try to get the user's shell from the host using getent passwd
        result = subprocess.run(
            ["getent", "passwd", username],
            capture_output=True,
            text=True,
            check=True
        )

        # Parse the output to get the shell (last field of passwd entry)
        user_info = result.stdout.strip().split(":")
        if len(user_info) >= 7:
            return user_info[6]
    except Exception as e:
        print(f"Warning: Could not determine shell for user {username}: {e}", file=sys.stderr)

    # Default to bash if we couldn't determine the shell
    return "/bin/bash"

def execute_host_command(command, username=None, working_dir=None):
    """
    Execute a command on the host system using Docker API.
    
    This function creates a temporary Docker container that has access to the host system.
    The container:
    1. Uses the host's PID namespace (--pid=host)
    2. Uses the host's network namespace (--network=host)
    3. Mounts the host's filesystem (--volume=/:/host)
    4. Executes the command in the host's filesystem context using chroot
    
    Security note: This approach provides full access to the host system.
    Use with caution and ensure proper access controls are in place.

    Args:
        command (str): The command to execute on the host
        username (str, optional): The username to execute the command as.
                                  If None, uses HOST_USER or USER env var, or 'root'
        working_dir (str, optional): The working directory to execute the command in.
                                     If None, uses '/'

    Returns:
        int: The exit code of the command (0 for success, non-zero for failure)
    """

    # If no username specified, use the current user
    if not username:
        username = os.environ.get("HOST_USER", os.environ.get("USER", "root"))

    # If no working directory specified, use the current directory
    if working_dir is None:
        working_dir = "/"

    try:
        # Create a temporary container that:
        # 1. Uses the host's PID namespace (--pid=host)
        # 2. Uses the host's network namespace (--network=host)
        # 3. Mounts the host's filesystem (--volume=/:/host)
        # 4. Runs as the specified user (--user) - currently commented out
        # 5. Executes the command in the host's filesystem (chroot /host)

        # Prepare the Docker command with working directory change
        command = "cd " + working_dir + " && " + command
        docker_cmd = [
            "docker", "run", "--rm",
            "--pid=host",
            "--network=host",
            "--volume=/:/host",
            # "--workdir=" + working_dir,  # Not used as we handle working dir with cd
            # "--user", username,          # User specification is commented out, may be implemented later
            "alpine:latest",               # Using lightweight Alpine image
            "chroot", "/host", "sh", "-c", command
        ]

        print(f">>>> Executing {docker_cmd}")

        # Execute the Docker command with I/O redirected to current process
        result = subprocess.run(
            docker_cmd,
            stdout=sys.stdout,  # Stream output directly to caller's stdout
            stderr=sys.stderr,  # Stream errors directly to caller's stderr
            text=True
        )
        print(f"<<<< Command executed on host successfully with exit code {result.returncode}")

        return result.returncode
    except Exception as e:
        print(f"Error executing command on host: {e}", file=sys.stderr)
        return 1  # Return error code 1 on exception

def interactive_host_shell(username=None):
    """
    Run an interactive shell that executes commands on the host system.
    
    This function provides a shell-like interface where all commands are executed
    on the host system through the execute_host_command function. The shell supports:
    - Basic command execution on the host
    - Directory navigation with 'cd' command
    - Session termination with 'exit' or 'quit'
    - Working directory tracking
    
    The shell will continue to run until the user types 'exit', 'quit', or
    sends an EOF signal (Ctrl+D).
    
    Args:
        username (str, optional): The username to execute commands as on the host.
                                  If None, uses HOST_USER or USER env var, or 'root'
    
    Returns:
        int: Exit code (0 for normal exit)
    """
    # If no username specified, use the current user
    if not username:
        username = os.environ.get("HOST_USER", os.environ.get("USER", "root"))

    # Get the user's shell to display appropriate shell info
    user_shell = get_user_shell(username)
    shell_name = os.path.basename(user_shell)

    # Initialize the working directory to the root directory
    working_dir = "/"

    # Display welcome message and instructions
    print("JB Gateway Host Command Executor")
    print(f"Interactive host shell mode for user: {username} (shell: {shell_name})")
    print("Type 'exit' to quit this mode")
    print()

    # Main command loop
    while True:
        try:
            # Display prompt showing user and current working directory
            command = input(f"host({username})[{working_dir}]$ ")

            # Handle exit commands
            if command.strip().lower() in ["exit", "quit"]:
                print("Exiting host shell mode")
                return 0

            # Handle directory navigation (cd command)
            if command.strip().startswith("cd "):
                # Extract the directory to change to
                new_dir = command.strip()[3:].strip()

                # Convert relative paths to absolute paths
                if not os.path.isabs(new_dir):
                    new_dir = os.path.normpath(os.path.join(working_dir, new_dir))

                # Verify directory exists by attempting to change to it on the host
                cd_result = execute_host_command(f"cd {new_dir}", username, working_dir)
                if cd_result == 0:
                    working_dir = new_dir
                    print(f"Changed directory to: {working_dir}")
                else:
                    print(f"Directory not found: {new_dir}")
            else:
                # Execute regular command on the host
                execute_host_command(command, username, working_dir)

        except KeyboardInterrupt:
            # Handle Ctrl+C gracefully
            print("\nUse 'exit' to quit")
        except EOFError:
            # Handle Ctrl+D (EOF) gracefully
            print("\nExiting host shell mode")
            return 0
        except Exception as e:
            # Handle other unexpected errors
            print(f"Error: {e}", file=sys.stderr)

def main():
    """
    Main entry point for the host command executor.
    
    This function serves as the primary entry point for the script.
    Currently, it directly launches the interactive host shell mode.
    
    Future enhancements may include:
    - Argument parsing for different modes of operation
    - Support for executing one-off commands
    - Configuration options for security settings
    
    Returns:
        int: Exit code from the interactive shell
    """
    # Currently, this always launches the interactive shell
    # Future versions could check arguments and support more modes
    return interactive_host_shell()

if __name__ == "__main__":
    sys.exit(main())
