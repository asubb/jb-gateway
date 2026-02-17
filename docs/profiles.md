# Profile Support

Client commands support optional profiles for managing multiple isolated development environments. Each profile maintains its own configuration, SSH keys, state files, and logs.

## Using Profiles

Add `--profile <name>` to any client command:

```bash
# Start proxy tunnels using "dev" profile
./client/proxy.sh --profile dev -p 8080,8081

# Check status of "staging" profile
./client/status.sh --profile staging

# Stop tunnels for "dev" profile
./client/proxy-stop.sh --profile dev

# Display configuration for "production" profile
./client/config.sh --profile production
```

## Profile Directory Structure

**Without profile** (default):
- Configuration: `~/.jb-gateway/` and `client/.env`
- PID files: `~/.jb-gateway/proxy/`
- Logs: `~/.jb-gateway/logs/`

**With profile** (`--profile <name>`):
- Configuration: `~/.jb-gateway/profiles/<name>/.env`
- SSH keys: `~/.jb-gateway/profiles/<name>/ssh/`
- PID files: `~/.jb-gateway/profiles/<name>/state/`
- Logs: `~/.jb-gateway/profiles/<name>/logs/`
- Secrets: `~/.jb-gateway/profiles/<name>/secrets/`

Profiles are created automatically on first use with proper permissions (0700).

## Profile Management

### Create a Profile

Just use `--profile <name>` - the directory structure is created automatically:

```bash
./client/proxy.sh --profile myproject -p 3000,8080
```

### List Profiles

```bash
ls ~/.jb-gateway/profiles/
```

### Delete a Profile

```bash
rm -rf ~/.jb-gateway/profiles/<name>
```

### Switch Between Profiles

Simply use the `--profile` flag with the desired profile name. No "active profile" state is maintained - each command operates independently.

## Configuration

Each profile needs its own configuration file. Create a `.env` file in the profile directory:

```bash
# Create configuration for "dev" profile
cat > ~/.jb-gateway/profiles/dev/.env << 'EOF'
SSH_HOST=localhost
SSH_PORT=1022
SSH_USER=jb-gateway
SSH_PASSWORD=password
PROXY_PORTS=3000,8080,9000
PROXY_DESTINATIONS=3000:CONTAINER_LOCALHOST,8080:HOST_NETWORK
EOF
```

## Important Notes

### Port Configuration

**Each profile needs its own port assignments.** Profiles can technically use the same port numbers since they run on different SSH tunnel connections, but this can be confusing. It's recommended to use different ports for different profiles.

Example configuration strategy:
- **dev profile**: Ports 3000-3099
- **staging profile**: Ports 4000-4099
- **production profile**: Ports 5000-5099

### SSH Keys

Place profile-specific SSH keys in `~/.jb-gateway/profiles/<name>/ssh/`:

```bash
# Generate profile-specific SSH key
ssh-keygen -t rsa -b 4096 -f ~/.jb-gateway/profiles/dev/ssh/id_rsa -N ""

# Copy to server
ssh-copy-id -i ~/.jb-gateway/profiles/dev/ssh/id_rsa.pub jb-gateway@localhost -p 1022
```

If no profile-specific keys exist, SSH will use default system key locations.

### Concurrent Operation

Multiple profiles can run simultaneously with independent tunnels:

```bash
# Terminal 1: Start dev profile
./client/proxy.sh --profile dev -p 3000,3001

# Terminal 2: Start staging profile
./client/proxy.sh --profile staging -p 4000,4001

# Terminal 3: Check status of both
./client/status.sh --profile dev
./client/status.sh --profile staging
```

### Backward Compatibility

Commands without `--profile` use the default configuration (no breaking changes):

```bash
# Uses ~/.jb-gateway/ and client/.env (existing behavior)
./client/proxy.sh -p 8080

# Uses profile (new behavior)
./client/proxy.sh --profile dev -p 8080
```

## Use Cases

### Multiple Projects

Isolate development environments for different projects:

```bash
# Frontend project
./client/proxy.sh --profile frontend -p 3000,3001

# Backend project
./client/proxy.sh --profile backend -p 8080,8081,5432
```

### Different Environments

Maintain separate configurations for different deployment environments:

```bash
# Development environment
./client/proxy.sh --profile dev -p 3000

# Staging environment
./client/proxy.sh --profile staging -p 4000

# Production environment (monitoring only)
./client/proxy.sh --profile prod -p 5000
```

### Team Collaboration

Different team members can have isolated configurations:

```bash
# Alice's profile
./client/proxy.sh --profile alice -p 3000,8080

# Bob's profile
./client/proxy.sh --profile bob -p 3100,8180
```

## Supported Commands

All client commands support the `--profile` flag:

- `client/proxy.sh --profile <name>` - Start proxy tunnels with profile
- `client/proxy-stop.sh --profile <name>` - Stop proxy tunnels for profile
- `client/status.sh --profile <name>` - Show status for profile
- `client/config.sh --profile <name>` - Display profile configuration
- `client/smb-connect.sh --profile <name>` - Connect to SMB shares using profile config

## Troubleshooting

### Profile directory not created

The profile directory is created automatically when you first use a profile. If it doesn't exist, check that you have write permissions to `~/.jb-gateway/`.

### Tunnels not starting with profile

1. Verify profile configuration exists: `cat ~/.jb-gateway/profiles/<name>/.env`
2. Check status: `./client/status.sh --profile <name>`
3. Review logs: `ls -la ~/.jb-gateway/profiles/<name>/logs/`

### Port conflicts between profiles

While profiles are isolated, they can't bind to the same port on your local machine simultaneously. Use different port numbers for concurrent profiles.

### Wrong profile being used

The `--profile` flag must be specified on every command. There is no "active profile" state. Use `status.sh` to verify which profile you're working with:

```bash
./client/status.sh --profile myproject
```
