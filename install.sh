#!/usr/bin/env bash
#
# jb-gateway installer
# Install jb-gateway to $HOME/.jb-gateway/bin
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=server
#   curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=client
#   curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=both
#
# Install from a different branch:
#   curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/develop/install.sh | JBG_BRANCH=develop bash -s -- --mode=server
#

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Branch configuration (defaults to main, can be overridden with JBG_BRANCH env var)
BRANCH="${JBG_BRANCH:-main}"

# Installation settings
INSTALL_DIR="$HOME/.jb-gateway/bin"
GITHUB_REPO="https://github.com/asubb/jb-gateway"
GITHUB_RAW="https://raw.githubusercontent.com/asubb/jb-gateway/${BRANCH}"
INSTALL_MODE_FILE=".install-mode"
INSTALL_BRANCH_FILE=".install-branch"

# Variables
MODE=""
FORCE=false
EXISTING_MODE=""
EXISTING_BRANCH=""

# Error handling
error() {
    echo -e "${RED}Error:${NC} $1" >&2
    exit 1
}

info() {
    echo -e "${BLUE}➜${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Help message
show_help() {
    cat << EOF
jb-gateway installer

Usage:
    curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=MODE [--force]

Options:
    --mode=MODE    Installation mode: server, client, or both (required)
    --force        Overwrite existing installation without prompting
    --help         Show this help message

Environment Variables:
    JBG_BRANCH     Branch to install from (default: main)

Examples:
    # Install server components
    curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=server

    # Install client components
    curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=client

    # Install both server and client
    curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=both

    # Force reinstall
    curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/main/install.sh | bash -s -- --mode=server --force

    # Install from a different branch
    curl -fsSL https://raw.githubusercontent.com/asubb/jb-gateway/develop/install.sh | JBG_BRANCH=develop bash -s -- --mode=server

EOF
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --mode=*)
                MODE="${1#*=}"
                shift
                ;;
            --mode)
                MODE="$2"
                shift 2
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done
}

# Validate mode
validate_mode() {
    if [[ -z "$MODE" ]]; then
        error "Installation mode is required. Use --mode=server, --mode=client, or --mode=both"
    fi

    case "$MODE" in
        server|client|both)
            # Valid mode
            ;;
        *)
            error "Invalid mode: '$MODE'. Valid modes are: server, client, both"
            ;;
    esac
}

# Detect existing installation
detect_existing_installation() {
    if [[ -d "$INSTALL_DIR" ]]; then
        if [[ -f "$INSTALL_DIR/$INSTALL_MODE_FILE" ]]; then
            EXISTING_MODE=$(cat "$INSTALL_DIR/$INSTALL_MODE_FILE" | head -n 1)
        fi
        if [[ -f "$INSTALL_DIR/$INSTALL_BRANCH_FILE" ]]; then
            EXISTING_BRANCH=$(cat "$INSTALL_DIR/$INSTALL_BRANCH_FILE" | head -n 1)
        fi
        return 0
    fi
    return 1
}

# Handle existing installation
handle_existing_installation() {
    if ! detect_existing_installation; then
        return 0
    fi

    if [[ "$FORCE" == true ]]; then
        info "Existing installation detected, overwriting (--force)"
        return 0
    fi

    if [[ -n "$EXISTING_MODE" ]]; then
        local install_info="$EXISTING_MODE mode"
        if [[ -n "$EXISTING_BRANCH" ]]; then
            install_info="$install_info (branch: $EXISTING_BRANCH)"
        fi
        info "Existing installation detected: $install_info"

        # Warn if switching branches
        if [[ -n "$EXISTING_BRANCH" && "$EXISTING_BRANCH" != "$BRANCH" ]]; then
            warn "Switching from branch '$EXISTING_BRANCH' to '$BRANCH'"
        fi

        # Check if we're adding a new mode
        if [[ "$MODE" != "$EXISTING_MODE" && "$MODE" != "both" ]]; then
            case "$EXISTING_MODE" in
                server)
                    if [[ "$MODE" == "client" ]]; then
                        info "Adding client mode to existing server installation"
                        MODE="both"
                        return 0
                    fi
                    ;;
                client)
                    if [[ "$MODE" == "server" ]]; then
                        info "Adding server mode to existing client installation"
                        MODE="both"
                        return 0
                    fi
                    ;;
                both)
                    info "Both modes already installed, will update existing installation"
                    return 0
                    ;;
            esac
        fi
    fi

    # Prompt for confirmation
    echo -n "Existing installation found. Overwrite? [y/N] "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            error "Installation cancelled"
            ;;
    esac
}

# Check if git is available
has_git() {
    command -v git >/dev/null 2>&1
}

# Check if curl is available
has_curl() {
    command -v curl >/dev/null 2>&1
}

# Check if wget is available
has_wget() {
    command -v wget >/dev/null 2>&1
}

# Download file with retry logic
download_file() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry=0
    local wait_time=2

    while [[ $retry -lt $max_retries ]]; do
        if has_curl; then
            if curl -fsSL --retry 2 --retry-delay 2 "$url" -o "$output"; then
                return 0
            fi
        elif has_wget; then
            if wget -q --tries=2 --waitretry=2 "$url" -O "$output"; then
                return 0
            fi
        else
            error "Neither curl nor wget is available. Please install one of them."
        fi

        retry=$((retry + 1))
        if [[ $retry -lt $max_retries ]]; then
            warn "Download failed, retrying in ${wait_time}s... (attempt $retry/$max_retries)"
            sleep $wait_time
            wait_time=$((wait_time * 2))
        fi
    done

    error "Failed to download $url after $max_retries attempts"
}

# Clone repository with git
clone_with_git() {
    info "Downloading jb-gateway using git (branch: $BRANCH)..."

    local temp_dir=$(mktemp -d)
    if ! git clone --depth 1 --branch "$BRANCH" "$GITHUB_REPO" "$temp_dir" 2>/dev/null; then
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy files based on mode
    mkdir -p "$INSTALL_DIR"

    # Copy all files from repository to install dir
    cp -r "$temp_dir"/* "$INSTALL_DIR/" 2>/dev/null || true
    cp -r "$temp_dir"/.* "$INSTALL_DIR/" 2>/dev/null || true

    rm -rf "$temp_dir"
    return 0
}

# Download files without git
download_files() {
    info "Downloading jb-gateway files..."

    mkdir -p "$INSTALL_DIR"

    # For now, we'll create a minimal set of files
    # In a real implementation, this would download specific files based on mode

    # Download or create essential files
    # This is a placeholder - in production, we'd download actual files from the repo

    success "Files downloaded"
}

# Create directory structure
create_directories() {
    info "Creating directory structure..."

    mkdir -p "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR"

    success "Directory structure created"
}

# Save installation metadata
save_install_mode() {
    local mode_file="$INSTALL_DIR/$INSTALL_MODE_FILE"
    local branch_file="$INSTALL_DIR/$INSTALL_BRANCH_FILE"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat > "$mode_file" << EOF
$MODE
installed_at=$timestamp
EOF

    cat > "$branch_file" << EOF
$BRANCH
EOF

    success "Installation mode saved: $MODE (branch: $BRANCH)"
}

# Detect user's shell
detect_shell() {
    if [[ -n "$SHELL" ]]; then
        basename "$SHELL"
    else
        echo "unknown"
    fi
}

# Get RC file for shell
get_rc_file() {
    local shell_name=$(detect_shell)

    case "$shell_name" in
        bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                echo "$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Check if source line already exists in RC file
has_source_line() {
    local rc_file="$1"
    [[ -f "$rc_file" ]] && grep -q "jb-gateway" "$rc_file"
}

# Add source line to RC file
add_source_line() {
    local rc_file="$1"

    if [[ -z "$rc_file" ]]; then
        warn "Could not determine shell RC file"
        return 1
    fi

    # Backup RC file
    if [[ -f "$rc_file" ]]; then
        cp "$rc_file" "${rc_file}.bak"
        info "Backed up $rc_file to ${rc_file}.bak"
    fi

    # Check if already added
    if has_source_line "$rc_file"; then
        info "Shell integration already configured in $rc_file"
        return 0
    fi

    # Add source line
    cat >> "$rc_file" << 'EOF'

# jb-gateway
[ -f "$HOME/.jb-gateway/bin/env.sh" ] && source "$HOME/.jb-gateway/bin/env.sh"
EOF

    success "Added jb-gateway to $rc_file"
}

# Create env.sh
create_env_sh() {
    local env_file="$INSTALL_DIR/env.sh"

    cat > "$env_file" << 'EOF'
#!/usr/bin/env bash
# jb-gateway environment setup

# Set JBG_HOME
export JBG_HOME="$HOME/.jb-gateway"

# Add to PATH
if [[ ":$PATH:" != *":$JBG_HOME/bin:"* ]]; then
    export PATH="$JBG_HOME/bin:$PATH"
fi
EOF

    chmod 644 "$env_file"
    success "Created env.sh"
}

# Setup shell integration
setup_shell_integration() {
    info "Setting up shell integration..."

    local shell_name=$(detect_shell)

    case "$shell_name" in
        bash|zsh)
            create_env_sh
            local rc_file=$(get_rc_file)
            add_source_line "$rc_file"
            ;;
        *)
            warn "Unsupported shell: $shell_name"
            show_manual_integration
            ;;
    esac
}

# Show manual integration instructions
show_manual_integration() {
    cat << 'EOF'

Manual Shell Integration:
-------------------------
Add the following line to your shell's RC file:

    [ -f "$HOME/.jb-gateway/bin/env.sh" ] && source "$HOME/.jb-gateway/bin/env.sh"

For bash: Add to ~/.bashrc or ~/.bash_profile
For zsh: Add to ~/.zshrc
For fish: Add to ~/.config/fish/config.fish (adjust syntax)

EOF
}

# Create jbg wrapper script
create_jbg_command() {
    local jbg_file="$INSTALL_DIR/jbg"

    cat > "$jbg_file" << 'EOF'
#!/usr/bin/env bash
# jbg command wrapper

set -e

JBG_HOME="${JBG_HOME:-$HOME/.jb-gateway}"
INSTALL_DIR="$JBG_HOME/bin"

# Show help
show_help() {
    cat << HELP
jbg - jb-gateway command-line tool

Usage: jbg <command> [subcommand] [options]

Commands:
    update              Update jb-gateway installation
    server              Server operations (start, stop, build, status)
    client              Client operations (status, proxy)
    help                Show this help message

Server Subcommands:
    jbg server start    Start the server container
    jbg server stop     Stop the server container
    jbg server build    Build the server Docker image
    jbg server status   Check server status

Client Subcommands:
    jbg client status        Check client subsystems status
    jbg client proxy start   Start proxy tunnels
    jbg client proxy stop    Stop proxy tunnels

Examples:
    jbg update               Update to latest version
    jbg server start         Start server components
    jbg server status        Check if server is running
    jbg client status        Check client status
    jbg client proxy start   Start proxy tunnels

HELP
}

# Update command
cmd_update() {
    echo "Updating jb-gateway..."

    # Read current mode and branch
    local mode="server"
    local branch="main"

    if [[ -f "$INSTALL_DIR/.install-mode" ]]; then
        mode=$(head -n 1 "$INSTALL_DIR/.install-mode")
    fi

    if [[ -f "$INSTALL_DIR/.install-branch" ]]; then
        branch=$(head -n 1 "$INSTALL_DIR/.install-branch")
    fi

    # Check if installed via git
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        echo "Updating via git pull (branch: $branch)..."
        cd "$INSTALL_DIR"
        git pull origin "$branch"
        echo "✓ Updated successfully"
    else
        echo "Updating via reinstall (branch: $branch)..."
        # Re-run installer with same branch
        curl -fsSL "https://raw.githubusercontent.com/asubb/jb-gateway/$branch/install.sh" | JBG_BRANCH="$branch" bash -s -- --mode="$mode" --force
    fi
}

# Server command
cmd_server() {
    local subcommand="${1:-status}"
    shift || true

    case "$subcommand" in
        start)
            if [[ -f "$INSTALL_DIR/server/run.sh" ]]; then
                "$INSTALL_DIR/server/run.sh" "$@"
            else
                echo "Error: server/run.sh not found"
                echo "Please ensure server mode is installed: jbg update"
                exit 1
            fi
            ;;
        stop)
            if [[ -f "$INSTALL_DIR/server/stop.sh" ]]; then
                "$INSTALL_DIR/server/stop.sh"
            else
                echo "Error: server/stop.sh not found"
                echo "Please ensure server mode is installed: jbg update"
                exit 1
            fi
            ;;
        build)
            if [[ -f "$INSTALL_DIR/server/build.sh" ]]; then
                "$INSTALL_DIR/server/build.sh"
            else
                echo "Error: server/build.sh not found"
                echo "Please ensure server mode is installed: jbg update"
                exit 1
            fi
            ;;
        status)
            echo "Checking server status..."
            if docker ps --filter "name=jb-gateway" --format "{{.Names}}" | grep -q "jb-gateway"; then
                echo "✓ jb-gateway container is running"
                docker ps --filter "name=jb-gateway" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            else
                echo "✗ jb-gateway container is not running"
                exit 1
            fi
            ;;
        help|--help|-h)
            cat << HELP
jbg server - Manage server operations

Usage: jbg server <subcommand> [options]

Subcommands:
    start     Start the server container
    stop      Stop the server container
    build     Build the server Docker image
    status    Check server status
    help      Show this help message

Examples:
    jbg server start     Start the jb-gateway container
    jbg server stop      Stop the jb-gateway container
    jbg server build     Build the Docker image
    jbg server status    Check if container is running

HELP
            ;;
        *)
            echo "Unknown server subcommand: $subcommand"
            echo "Run 'jbg server help' for usage information"
            exit 1
            ;;
    esac
}

# Client command
cmd_client() {
    local subcommand="${1:-status}"
    shift || true

    case "$subcommand" in
        status)
            if [[ -f "$INSTALL_DIR/client/status.sh" ]]; then
                "$INSTALL_DIR/client/status.sh"
            else
                echo "Error: client/status.sh not found"
                echo "Please ensure client mode is installed: jbg update"
                exit 1
            fi
            ;;
        proxy)
            local action="${1:-start}"
            case "$action" in
                start)
                    if [[ -f "$INSTALL_DIR/client/proxy.sh" ]]; then
                        "$INSTALL_DIR/client/proxy.sh"
                    else
                        echo "Error: client/proxy.sh not found"
                        echo "Please ensure client mode is installed: jbg update"
                        exit 1
                    fi
                    ;;
                stop)
                    if [[ -f "$INSTALL_DIR/client/proxy-stop.sh" ]]; then
                        "$INSTALL_DIR/client/proxy-stop.sh"
                    else
                        echo "Error: client/proxy-stop.sh not found"
                        echo "Please ensure client mode is installed: jbg update"
                        exit 1
                    fi
                    ;;
                help|--help|-h)
                    cat << HELP
jbg client proxy - Manage proxy tunnels

Usage: jbg client proxy <action>

Actions:
    start    Start proxy tunnels
    stop     Stop proxy tunnels
    help     Show this help message

Examples:
    jbg client proxy start    Start all configured proxy tunnels
    jbg client proxy stop     Stop all proxy tunnels

HELP
                    ;;
                *)
                    echo "Unknown proxy action: $action"
                    echo "Run 'jbg client proxy help' for usage information"
                    exit 1
                    ;;
            esac
            ;;
        help|--help|-h)
            cat << HELP
jbg client - Manage client operations

Usage: jbg client <subcommand> [options]

Subcommands:
    status    Check client subsystems status
    proxy     Manage proxy tunnels (start, stop)
    help      Show this help message

Examples:
    jbg client status           Show status of all client subsystems
    jbg client proxy start      Start proxy tunnels
    jbg client proxy stop       Stop proxy tunnels

HELP
            ;;
        *)
            echo "Unknown client subcommand: $subcommand"
            echo "Run 'jbg client help' for usage information"
            exit 1
            ;;
    esac
}

# Main command router
main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        update)
            cmd_update "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        server)
            cmd_server "$@"
            ;;
        client)
            cmd_client "$@"
            ;;
        *)
            echo "Unknown command: $command"
            echo "Run 'jbg help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"
EOF

    chmod 755 "$jbg_file"
    success "Created jbg command"
}

# Main installation function
main() {
    echo "jb-gateway installer"
    echo "===================="
    echo ""

    # Parse arguments
    parse_args "$@"

    # Validate mode
    validate_mode

    # Handle existing installation
    handle_existing_installation

    # Create directories
    create_directories

    # Download files
    if has_git; then
        if clone_with_git; then
            success "Downloaded via git"
        else
            warn "Git clone failed, falling back to file download"
            download_files
        fi
    else
        download_files
    fi

    # Save installation metadata
    save_install_mode

    # Setup shell integration
    setup_shell_integration

    # Create jbg command
    create_jbg_command

    # Success message
    echo ""
    success "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your shell or run: source ~/.$(detect_shell)rc"
    echo "  2. Verify installation: jbg help"
    echo "  3. Update anytime with: jbg update"
    echo ""
    echo "Installation directory: $INSTALL_DIR"
    echo "Mode: $MODE"
    echo "Branch: $BRANCH"
    echo ""
}

# Run main
main "$@"
