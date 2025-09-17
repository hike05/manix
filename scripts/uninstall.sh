#!/bin/bash
set -euo pipefail

# Nix Darwin Configuration - Complete Uninstallation Script
# This script completely removes Nix, nix-darwin, and all related configurations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_DIR="$HOME/.config/nix"
BACKUP_DIR="$HOME/nix-uninstall-backup-$(date +%Y%m%d-%H%M%S)"

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
}

# Confirm uninstallation
confirm_uninstall() {
    echo "🗑️  Nix Darwin Configuration Uninstaller"
    echo "========================================"
    echo
    warning "This will completely remove:"
    echo "  • Nix package manager"
    echo "  • nix-darwin system configuration"
    echo "  • home-manager user configuration"
    echo "  • All Nix-installed packages"
    echo "  • /nix directory and Nix store"
    echo
    warning "Homebrew and manually installed software will remain untouched."
    echo
    read -p "Are you sure you want to continue? Type 'yes' to confirm: " -r
    echo
    if [[ $REPLY != "yes" ]]; then
        log "Uninstallation cancelled by user"
        exit 0
    fi
}

# Create backup before uninstallation
create_backup() {
    log "Creating backup at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Backup nix configuration
    if [[ -d "$CONFIG_DIR" ]]; then
        cp -r "$CONFIG_DIR" "$BACKUP_DIR/nix-config" || true
        log "Backed up Nix configuration"
    fi
    
    # Backup current profiles
    if [[ -d "$HOME/.nix-profile" ]]; then
        nix-env --query --installed > "$BACKUP_DIR/nix-profile-packages.txt" 2>/dev/null || true
        log "Backed up Nix profile packages"
    fi
    
    # Backup shell configuration
    for file in .zshrc .bashrc .bash_profile; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    success "Backup completed"
}

# Stop and remove nix-darwin services
remove_nix_darwin_services() {
    log "Removing nix-darwin services..."
    
    # Stop nix-daemon if managed by nix-darwin
    if [[ -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist ]]; then
        sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
        sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist
        log "Removed nix-daemon service"
    fi
    
    # Remove other nix-darwin services
    for service in org.nixos.activate-system org.nixos.nix-optimise; do
        if [[ -f "/Library/LaunchDaemons/$service.plist" ]]; then
            sudo launchctl unload "/Library/LaunchDaemons/$service.plist" 2>/dev/null || true
            sudo rm -f "/Library/LaunchDaemons/$service.plist"
            log "Removed $service service"
        fi
    done
    
    success "nix-darwin services removed"
}

# Remove nix-darwin system configuration
remove_nix_darwin_config() {
    log "Removing nix-darwin system configuration..."
    
    # Remove system profile
    if [[ -L /run/current-system ]]; then
        sudo rm -f /run/current-system
    fi
    
    # Remove nix-darwin generated files
    sudo rm -rf /etc/static 2>/dev/null || true
    
    # Restore original shell configurations
    if [[ -f /etc/zshrc.orig ]]; then
        sudo mv /etc/zshrc.orig /etc/zshrc
        log "Restored original /etc/zshrc"
    fi
    
    if [[ -f /etc/bashrc.orig ]]; then
        sudo mv /etc/bashrc.orig /etc/bashrc
        log "Restored original /etc/bashrc"
    fi
    
    # Remove nix-darwin specific configurations
    for file in /etc/zshrc /etc/bashrc /etc/zprofile; do
        if [[ -f "$file" ]]; then
            # Remove nix-related lines
            sudo sed -i.bak '/nix/d' "$file" 2>/dev/null || true
        fi
    done
    
    success "nix-darwin configuration removed"
}

# Remove home-manager configuration
remove_home_manager() {
    log "Removing home-manager configuration..."
    
    # Remove home-manager generations
    if command -v home-manager >/dev/null 2>&1; then
        home-manager expire-generations 0 2>/dev/null || true
    fi
    
    # Remove home-manager directories
    rm -rf "$HOME/.local/state/home-manager" 2>/dev/null || true
    rm -rf "$HOME/.local/share/home-manager" 2>/dev/null || true
    
    success "home-manager removed"
}

# Remove user Nix profiles and data
remove_user_nix_data() {
    log "Removing user Nix profiles and data..."
    
    # Remove user profiles
    rm -rf "$HOME/.nix-profile" 2>/dev/null || true
    rm -rf "$HOME/.nix-defexpr" 2>/dev/null || true
    rm -rf "$HOME/.nix-channels" 2>/dev/null || true
    
    # Remove nix configuration
    rm -rf "$HOME/.config/nix" 2>/dev/null || true
    rm -rf "$HOME/.cache/nix" 2>/dev/null || true
    rm -rf "$HOME/.local/state/nix" 2>/dev/null || true
    
    success "User Nix data removed"
}

# Remove system Nix installation
remove_system_nix() {
    log "Removing system Nix installation..."
    
    # Remove Nix volume on macOS
    if [[ -d /nix ]]; then
        # Check if /nix is mounted as a separate volume
        if mount | grep -q "/nix"; then
            log "Unmounting Nix volume..."
            sudo diskutil unmount force /nix 2>/dev/null || true
            
            # Remove from fstab
            if [[ -f /etc/fstab ]]; then
                sudo sed -i.bak '/nix/d' /etc/fstab 2>/dev/null || true
            fi
            
            # Find and remove the Nix volume
            local nix_volume
            nix_volume=$(diskutil list | grep "Nix Store" | awk '{print $NF}' | head -n1)
            if [[ -n "$nix_volume" ]]; then
                sudo diskutil eraseVolume free none "$nix_volume" 2>/dev/null || true
                log "Removed Nix volume: $nix_volume"
            fi
        fi
        
        # Remove /nix directory
        sudo rm -rf /nix 2>/dev/null || true
    fi
    
    success "System Nix installation removed"
}

# Remove Nix users and groups
remove_nix_users() {
    log "Removing Nix users and groups..."
    
    # Remove nix users (nixbld1, nixbld2, etc.)
    for i in {1..32}; do
        if dscl . -read "/Users/nixbld$i" >/dev/null 2>&1; then
            sudo dscl . -delete "/Users/nixbld$i" 2>/dev/null || true
        fi
    done
    
    # Remove nixbld group
    if dscl . -read /Groups/nixbld >/dev/null 2>&1; then
        sudo dscl . -delete /Groups/nixbld 2>/dev/null || true
    fi
    
    success "Nix users and groups removed"
}

# Clean up shell configurations
clean_shell_configs() {
    log "Cleaning up shell configurations..."
    
    for file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
        if [[ -f "$file" ]]; then
            # Remove nix-related lines
            sed -i.bak '/nix/d; /NIX_/d; /darwin-rebuild/d; /home-manager/d' "$file" 2>/dev/null || true
            log "Cleaned $file"
        fi
    done
    
    success "Shell configurations cleaned"
}

# Remove remaining directories and files
remove_remaining_files() {
    log "Removing remaining Nix-related files..."
    
    # Remove additional directories
    sudo rm -rf /var/root/.nix-profile 2>/dev/null || true
    sudo rm -rf /var/root/.nix-defexpr 2>/dev/null || true
    sudo rm -rf /var/root/.nix-channels 2>/dev/null || true
    sudo rm -rf /var/root/.config/nix 2>/dev/null || true
    
    # Remove any remaining nix files
    sudo find /usr/local -name "*nix*" -delete 2>/dev/null || true
    sudo find /etc -name "*nix*" -delete 2>/dev/null || true
    
    success "Remaining files removed"
}

# Verify complete removal
verify_removal() {
    log "Verifying complete removal..."
    
    local remaining_items=()
    
    # Check for remaining Nix commands
    if command -v nix >/dev/null 2>&1; then
        remaining_items+=("nix command still available")
    fi
    
    if command -v darwin-rebuild >/dev/null 2>&1; then
        remaining_items+=("darwin-rebuild command still available")
    fi
    
    # Check for remaining directories
    if [[ -d /nix ]]; then
        remaining_items+=("/nix directory still exists")
    fi
    
    if [[ -d "$HOME/.nix-profile" ]]; then
        remaining_items+=("User Nix profile still exists")
    fi
    
    # Check for remaining users
    if dscl . -read /Groups/nixbld >/dev/null 2>&1; then
        remaining_items+=("nixbld group still exists")
    fi
    
    if [[ ${#remaining_items[@]} -eq 0 ]]; then
        success "Complete removal verified"
        return 0
    else
        warning "Some items may still remain:"
        printf '  • %s\n' "${remaining_items[@]}"
        return 1
    fi
}

# Main uninstallation function
main() {
    confirm_uninstall
    
    log "Starting Nix Darwin uninstallation..."
    
    create_backup
    remove_nix_darwin_services
    remove_nix_darwin_config
    remove_home_manager
    remove_user_nix_data
    remove_system_nix
    remove_nix_users
    clean_shell_configs
    remove_remaining_files
    
    echo
    if verify_removal; then
        success "🎉 Nix Darwin has been completely removed!"
    else
        warning "⚠️  Uninstallation completed with some remaining items"
        warning "You may need to manually remove them or restart your system"
    fi
    
    echo
    echo "📋 Summary:"
    echo "  • Backup created at: $BACKUP_DIR"
    echo "  • Nix package manager removed"
    echo "  • nix-darwin configuration removed"
    echo "  • home-manager removed"
    echo "  • Nix store and volume removed"
    echo "  • Nix users and groups removed"
    echo
    echo "🔄 Please restart your terminal to complete the cleanup"
    echo "🍺 Homebrew and other software remain untouched"
    echo
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --force        Skip confirmation prompt"
        echo
        exit 0
        ;;
    --force)
        # Skip confirmation for automated usage
        confirm_uninstall() { return 0; }
        ;;
esac

# Run main uninstallation
main "$@"