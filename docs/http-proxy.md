# HTTP Proxy (client/proxy.sh)

JB Gateway includes a proxy feature that allows you to forward HTTP requests from your local machine to the remote host via the gateway container. This is useful when you need to access services running on the remote host network.

## Configuring Ports

You can configure which ports to tunnel in two ways:

1. Using a `.env` file in `client/` (recommended for multiple ports):
   ```
   # client/.env file example
   PROXY_PORTS=8080,8081,8082-8085

   # Optional SSH settings
   SSH_PORT=1022
   SSH_USER=jb-gateway
   SSH_HOST=localhost
   SSH_PASSWORD=password
   ```

2. Using command-line arguments (for quick, one-time tunneling):
   ```bash
   ./client/proxy.sh -p 8080,8081,8082-8085
   ```

The port specification supports:

- Individual ports: `8080,8081,8082`
- Port ranges: `8082-8085` (equivalent to 8082,8083,8084,8085)
- Combinations: `8080,8081,8082-8085`

## Starting the Proxy

Run the proxy with:

```bash
./client/proxy.sh [options]
```

Options:

- `-p, --ports PORTS`: Comma-separated list of ports or port ranges to tunnel
- `-s, --ssh-port PORT`: SSH port for jb-gateway container (default: from .env or 1022)
- `-u, --user USER`: SSH user for jb-gateway container (default: from .env or jb-gateway)
- `-w, --password PASS`: SSH password for jb-gateway container (default: from .env or none)
- `-h, --help`: Show help message

Example:

```bash
./client/proxy.sh -p 8080,8081,8082-8085
```

With password:

```bash
./client/proxy.sh -p 8080,8081,8082-8085 -w password
```

This will set up tunnels for ports 8080, 8081, 8082, 8083, 8084, and 8085, forwarding each port from your local machine to the same port on the remote host via the jb-gateway container.

The proxy script automatically checks if tunnels are already running for the specified ports:

- If a tunnel is already running for a port, it will be skipped (verified by both PID and process details)
- If a process with the saved PID exists but is not actually a tunnel for the specific port, a new tunnel will be started
- If a stale PID file is found (process not running), a new tunnel will be started
- Only ports without active tunnels will have new tunnels created

This allows you to run the proxy script multiple times without creating duplicate tunnels, and ensures that only the necessary tunnels are started.

All tunnels run in the background, allowing you to continue using your terminal.

## Stopping the Proxy

To stop all running proxy tunnels:

```bash
./client/proxy-stop.sh
```

This will terminate all proxy tunnels that were started by the proxy.sh script.

## Proxy Logs

The proxy system creates several types of log files for easier troubleshooting:

1. **Main proxy script logs**:
   All output from the proxy.sh script (now in `client/proxy.sh`) is redirected to a log file:
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
   Output from the proxy-stop.sh script (now in `client/proxy-stop.sh`) is also logged:
   ```
   ~/.jb-gateway/logs/proxy-stop_YYYYMMDD_HHMMSS.log
   ```

In all cases, `YYYYMMDD_HHMMSS` is the timestamp when the respective script was started.

The main script output is also displayed in the terminal while the scripts run, but having logs saved to files makes it easier to debug issues that might occur while tunnels are running in the background. The individual tunnel logs are particularly useful for troubleshooting connection issues with specific ports.
