#!/bin/bash
set -euo pipefail

# Nix Darwin Configuration - Full Installation Script
# This script sets up a complete macOS development environment using Nix

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="${REPO_URL:-https://github.com/hike05/manix.git}"
CONFIG_DIR="$HOME/.config/nix"
BACKUP_DIR="$HOME/nix-install-backup-$(date +%Y%m%d-%H%M%S)"

# Logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
    fi
}

# Check macOS version compatibility
check_macos_version() {
    local version
    version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$version" | cut -d. -f1)
    
    if [[ $major_version -lt 12 ]]; then
        error "macOS 12.0 or later is required. Found: $version"
    fi
    
    success "macOS version check passed: $version"
}

# Check available disk space
check_disk_space() {
    local available_gb
    # Используем df -k для получения значения в килобайтах, затем переводим в гигабайты
    available_gb=$(df -k / | awk 'NR==2 {print int($4/1024/1024)}')

    if [[ $available_gb -lt 15 ]]; then
        error "At least 15GB of free space is required. Available: ${available_gb}GB"
    fi

    success "Disk space check passed: ${available_gb}GB available"
}

# Check for existing Nix installation
check_existing_nix() {
    if command -v nix >/dev/null 2>&1; then
        warning "Nix is already installed"
        read -p "Do you want to continue? This may overwrite existing configuration (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Installation cancelled by user"
            exit 0
        fi
    fi
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    if ! xcode-select -p >/dev/null 2>&1; then
        log "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation to complete
        until xcode-select -p >/dev/null 2>&1; do
            log "Waiting for Xcode Command Line Tools installation..."
            sleep 30
        done
        
        success "Xcode Command Line Tools installed"
    else
        success "Xcode Command Line Tools already installed"
    fi
}

# Backup existing configurations
backup_existing_config() {
    log "Creating backup at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Backup dotfiles
    for file in .zshrc .bashrc .bash_profile .gitconfig .ssh/config; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$BACKUP_DIR/" 2>/dev/null || true
            log "Backed up $file"
        fi
    done
    
    # Backup package lists
    if command -v brew >/dev/null 2>&1; then
        brew list --formula > "$BACKUP_DIR/brew-formulae.txt" 2>/dev/null || true
        brew list --cask > "$BACKUP_DIR/brew-casks.txt" 2>/dev/null || true
        log "Backed up Homebrew packages"
    fi
    
    if command -v npm >/dev/null 2>&1; then
        npm list -g --depth=0 > "$BACKUP_DIR/npm-global.txt" 2>/dev/null || true
        log "Backed up npm global packages"
    fi
    
    if command -v pip3 >/dev/null 2>&1; then
        pip3 list > "$BACKUP_DIR/pip-packages.txt" 2>/dev/null || true
        log "Backed up pip packages"
    fi
    
    # Backup existing Nix configuration
    if [[ -d "$CONFIG_DIR" ]]; then
        cp -r "$CONFIG_DIR" "$BACKUP_DIR/nix-config-backup" || true
        log "Backed up existing Nix configuration"
    fi
    
    success "Backup completed at $BACKUP_DIR"
}

# Install Nix
install_nix() {
    if ! command -v nix >/dev/null 2>&1; then
        log "Installing Nix using Determinate Systems installer..."
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        
        # Source nix environment
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
        
        success "Nix installation completed"
    else
        success "Nix already installed"
    fi
}

# Configure Nix
configure_nix() {
    log "Configuring Nix..."
    
    mkdir -p "$HOME/.config/nix"
    
    cat > "$HOME/.config/nix/nix.conf" << 'EOF'
experimental-features = nix-command flakes
auto-optimise-store = true
max-jobs = auto
EOF
    
    success "Nix configuration completed"
}

# Clone or update configuration repository
setup_config_repo() {
    if [[ -d "$CONFIG_DIR/.git" ]]; then
        log "Updating existing configuration repository..."
        cd "$CONFIG_DIR"
        git fetch origin
        git reset --hard origin/main
    else
        log "Cloning configuration repository..."
        rm -rf "$CONFIG_DIR"
        git clone "$REPO_URL" "$CONFIG_DIR"
    fi
    
    cd "$CONFIG_DIR"
    success "Configuration repository ready"
}

# Install from local directory (if not using remote repo)
setup_local_config() {
    log "Setting up configuration from current directory..."
    
    # Copy current directory to config location
    rm -rf "$CONFIG_DIR"
    cp -r "$(pwd)" "$CONFIG_DIR"
    
    cd "$CONFIG_DIR"
    
    # Initialize git if not already a repository
    if [[ ! -d .git ]]; then
        git init
        git add .
        git commit -m "Initial configuration"
    fi
    
    success "Local configuration setup completed"
}

# Build and activate nix-darwin
install_nix_darwin() {
    log "Building nix-darwin configuration..."
    cd "$CONFIG_DIR"
    
    # Ensure flake.lock is tracked
    git add flake.lock 2>/dev/null || true
    
    # Get hostname and allow user to select config
    local detected_hostname
    detected_hostname=$(scutil --get LocalHostName 2>/dev/null || scutil --get ComputerName 2>/dev/null || echo "default")
    log "Detected hostname: $detected_hostname"

    # List available configs
    local configs
    configs=$(nix flake show --json 2>/dev/null | jq -r '.darwinConfigurations | keys[]' 2>/dev/null || nix eval --json .#darwinConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]' || echo "default")

    echo
    echo "Available configurations:"
    local i=1
    local config_array=()

    # Check if detected hostname has a configuration
    local has_detected_config=false
    for cfg in $configs; do
        echo "  $i) $cfg"
        config_array+=("$cfg")
        if [[ "$cfg" == "$detected_hostname" ]]; then
            has_detected_config=true
            echo "     └─ (matches detected hostname)"
        fi
        ((i++))
    done

    echo
    if [[ $has_detected_config == true ]]; then
        echo "🎯 Detected hostname '$detected_hostname' has a matching configuration."
        read -p "Use detected configuration '$detected_hostname'? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            hostname="$detected_hostname"
        else
            echo
            read -p "Select configuration number [1-$((i-1))]: " choice
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#config_array[@]} )); then
                hostname="${config_array[$((choice-1))]}"
            else
                warning "Invalid selection, using default"
                hostname="default"
            fi
        fi
    else
        warning "No configuration found for detected hostname '$detected_hostname'"
        echo
        read -p "Select configuration number [1-$((i-1))] or press Enter for 'default': " choice

        if [[ -z "$choice" ]]; then
            hostname="default"
        elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#config_array[@]} )); then
            hostname="${config_array[$((choice-1))]}"
        else
            warning "Invalid selection, using default"
            hostname="default"
        fi
    fi

    echo
    log "Selected configuration: $hostname"

    # Try to build for selected hostname
    if nix build .#darwinConfigurations.${hostname}.system; then
        log "✅ Configuration '$hostname' built successfully"
    else
        error "❌ Failed to build configuration '$hostname'"
        if [[ "$hostname" != "default" ]]; then
            warning "Trying fallback to 'default' configuration..."
            if nix build .#darwinConfigurations.default.system; then
                hostname="default"
                log "✅ Fallback to 'default' configuration successful"
            else
                error "❌ Failed to build any configuration"
                exit 1
            fi
        else
            exit 1
        fi
    fi

    log "Activating nix-darwin configuration..."
    log "You may be prompted for your password for system-level changes."

    sudo ./result/sw/bin/darwin-rebuild switch --flake .#${hostname}

    success "nix-darwin installation and activation completed"
}

# Post-installation setup
post_install_setup() {
    log "Performing post-installation setup..."
    
    # Reload shell environment
    if [[ -f /etc/zshrc ]]; then
        source /etc/zshrc
    fi
    
    # Create convenient aliases
    cat >> "$HOME/.zshrc" << 'EOF'

# Nix Darwin Configuration aliases
alias rebuild="darwin-rebuild switch --flake ~/.config/nix"
alias nix-update="cd ~/.config/nix && nix flake update && rebuild"
alias nix-check="cd ~/.config/nix && nix flake check"
EOF
    
    success "Post-installation setup completed"
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Check if commands are available
    local commands=("darwin-rebuild" "home-manager" "git" "eza" "bat" "ripgrep")
    local missing_commands=()
    
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -eq 0 ]]; then
        success "All commands are available"
    else
        warning "Some commands are missing: ${missing_commands[*]}"
        warning "You may need to restart your terminal"
    fi
    
    # Check if nix-darwin is properly configured
    local check_hostname
    check_hostname=$(scutil --get LocalHostName 2>/dev/null || scutil --get ComputerName 2>/dev/null || echo "default")
    
    # Try the detected hostname first, then fallback to default
    if sudo darwin-rebuild check --flake "$CONFIG_DIR#$check_hostname" >/dev/null 2>&1; then
        success "nix-darwin configuration is valid for hostname: $check_hostname"
    elif sudo darwin-rebuild check --flake "$CONFIG_DIR#default" >/dev/null 2>&1; then
        success "nix-darwin configuration is valid (using default)"
    else
        warning "nix-darwin configuration check failed"
    fi
}

# Main installation function
main() {
    echo "🚀 Nix Darwin Configuration Installer"
    echo "======================================"
    echo
    
    # Determine installation source
    local use_remote_repo=true
    if [[ -f "$(pwd)/flake.nix" ]]; then
        read -p "Found flake.nix in current directory. Use local configuration? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            use_remote_repo=true
        else
            use_remote_repo=false
        fi
    fi
    
    # Pre-installation checks
    log "Running pre-installation checks..."
    check_not_root
    check_macos_version
    check_disk_space
    check_existing_nix
    
    # Installation steps
    install_xcode_tools
    backup_existing_config
    install_nix
    configure_nix
    
    if [[ $use_remote_repo == true ]]; then
        setup_config_repo
    else
        setup_local_config
    fi
    
    install_nix_darwin
    post_install_setup
    verify_installation
    
    echo
    success "🎉 Installation completed successfully!"
    echo
    echo "📋 Next steps:"
    echo "1. Restart your terminal or run: source /etc/zshrc"
    echo "2. Customize your configuration in: $CONFIG_DIR"
    echo "3. Apply changes with: rebuild"
    echo "4. Your backup is available at: $BACKUP_DIR"
    echo
    echo "📚 Documentation: $CONFIG_DIR/README.md"
    echo "🆘 Troubleshooting: $CONFIG_DIR/INSTALL.md"
    echo
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h          Show this help message"
        echo "  --repo-url URL      Use custom repository URL"
        echo "  --config-dir DIR    Use custom configuration directory"
        echo
        echo "Environment variables:"
        echo "  REPO_URL           Repository URL (default: detect from current directory)"
        echo
        exit 0
        ;;
    --repo-url)
        REPO_URL="$2"
        shift 2
        ;;
    --config-dir)
        CONFIG_DIR="$2"
        shift 2
        ;;
esac

# Run main installation
main "$@"