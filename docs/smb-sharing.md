# SMB Sharing Details

JB Gateway includes SMB (Samba) file sharing capabilities, allowing you to access your projects directory over the network from other devices.

## Accessing Shared Folders

The container shares the projects directory via SMB with the following details:

- **Share Name**: projects
- **Server Address**: Your host machine's IP address
- **Ports**: 139, 445 (standard SMB ports)
- **Username**: jb-gateway
- **Password**: password

### From Windows

1. Open File Explorer
2. In the address bar, type `\\your-host-ip\projects` (replace `your-host-ip` with your host machine's IP address)
3. When prompted, enter the username `jb-gateway` and password `password`

### From macOS

1. In Finder, select "Go" > "Connect to Server..."
2. Enter `smb://your-host-ip/projects` (replace `your-host-ip` with your host machine's IP address)
3. When prompted, enter the username `jb-gateway` and password `password`

### From Linux

1. Open your file manager
2. Connect to server with the address `smb://your-host-ip/projects` (replace `your-host-ip` with your host machine's IP address)
3. When prompted, enter the username `jb-gateway` and password `password`

Alternatively, you can mount the share using the command line:

```bash
sudo mount -t cifs //your-host-ip/projects /mnt/projects -o username=jb-gateway,password=password
```

## Using the `client/smb-connect.sh` Script

JB Gateway includes a convenient script for viewing and mounting SMB shares from the command line:

```bash
./client/smb-connect.sh
```

### Viewing Available Shares

To view all available shares on the JB Gateway container:

```bash
./client/smb-connect.sh view
```

This will display a list of all available shares, including the default "projects" share.

You can also view shares on a specific host by providing the hostname or IP address:

```bash
./client/smb-connect.sh view 192.168.1.100
```

### Mounting Shares

To mount a share to a local directory:

```bash
./client/smb-connect.sh mount <share> <mountpoint>
```

For example, to mount the "projects" share to a directory called "smb-mount" in your home directory:

```bash
./client/smb-connect.sh mount projects ~/smb-mount
```

You can also mount a share from a specific host by providing the hostname or IP address:

```bash
./client/smb-connect.sh mount projects ~/smb-mount 192.168.1.100
```

The script will automatically create the mount point directory if it doesn't exist.

## SMB Configuration

The script reads configuration from `client/.env` or `server/host.env` files if they exist. You can customize the following parameters:

- `SMB_HOST`: The default hostname or IP address of the SMB server (default: localhost)
- `SMB_USER`: The username for authentication (default: jb-gateway)
- `SMB_PASSWORD`: The password for authentication (default: password)

You can override the default host by specifying a host directly in the command line.
