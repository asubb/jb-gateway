# Connecting back to the Host

When running on macOS, a standalone SSH server is started on the host (port 2022). This allows the container to connect back to your host machine easily.

## The `host-ssh` Command

Inside the container, you can use the `host-ssh` command to quickly start an SSH session back to your host machine:

```bash
host-ssh
```

This is particularly useful if you need to run commands on your host machine while working inside the container.
