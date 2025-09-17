#!/bin/bash
set -euo pipefail

# Nix Darwin Configuration - Backup and Restore Utility
# This script handles backup and restoration of Nix configurations and data

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_DIR="$HOME/.config/nix"
DEFAULT_BACKUP_DIR="$HOME/nix-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

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

# Show help
show_help() {
    cat << EOF
Nix Darwin Backup and Restore Utility

Usage: $0 <command> [options]

Commands:
  backup      Create a backup of current configuration and data
  restore     Restore from a backup
  list        List available backups
  clean       Clean old backups

Backup Options:
  --output DIR    Backup directory (default: $DEFAULT_BACKUP_DIR)
  --name NAME     Backup name (default: timestamp)
  --full          Include Nix store (warning: very large)

Restore Options:
  --backup NAME   Backup name to restore from
  --config-only   Restore only configuration files
  --dry-run       Show what would be restored without doing it

Examples:
  $0 backup                           # Create timestamped backup
  $0 backup --name "before-update"    # Create named backup
  $0 restore --backup "before-update" # Restore from named backup
  $0 list                             # List all backups
  $0 clean --keep 5                   # Keep only 5 most recent backups

EOF
}

# Create comprehensive backup
create_backup() {
    local backup_dir="$DEFAULT_BACKUP_DIR"
    local backup_name="$TIMESTAMP"
    local include_store=false
    
    # Parse backup options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --output)
                backup_dir="$2"
                shift 2
                ;;
            --name)
                backup_name="$2"
                shift 2
                ;;
            --full)
                include_store=true
                shift
                ;;
            *)
                error "Unknown backup option: $1"
                ;;
        esac
    done
    
    local target_dir="$backup_dir/$backup_name"
    
    log "Creating backup: $backup_name"
    log "Target directory: $target_dir"
    
    mkdir -p "$target_dir"
    
    # Create backup metadata
    cat > "$target_dir/backup-info.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "name": "$backup_name",
  "hostname": "$(hostname)",
  "username": "$(whoami)",
  "macos_version": "$(sw_vers -productVersion)",
  "architecture": "$(uname -m)",
  "nix_version": "$(nix --version 2>/dev/null || echo 'not installed')",
  "include_store": $include_store
}
EOF
    
    # Backup Nix configuration
    if [[ -d "$CONFIG_DIR" ]]; then
        log "Backing up Nix configuration..."
        cp -r "$CONFIG_DIR" "$target_dir/nix-config"
        success "Nix configuration backed up"
    else
        warning "No Nix configuration found"
    fi
    
    # Backup user profiles
    log "Backing up user profiles..."
    mkdir -p "$target_dir/profiles"
    
    if [[ -d "$HOME/.nix-profile" ]]; then
        cp -rL "$HOME/.nix-profile" "$target_dir/profiles/nix-profile" 2>/dev/null || true
    fi
    
    if [[ -f "$HOME/.nix-channels" ]]; then
        cp "$HOME/.nix-channels" "$target_dir/profiles/"
    fi
    
    # Backup package lists
    log "Backing up package information..."
    mkdir -p "$target_dir/packages"
    
    # Nix packages
    if command -v nix-env >/dev/null 2>&1; then
        nix-env --query --installed > "$target_dir/packages/nix-installed.txt" 2>/dev/null || true
    fi
    
    # Homebrew packages
    if command -v brew >/dev/null 2>&1; then
        brew list --formula > "$target_dir/packages/brew-formulae.txt" 2>/dev/null || true
        brew list --cask > "$target_dir/packages/brew-casks.txt" 2>/dev/null || true
        brew services list > "$target_dir/packages/brew-services.txt" 2>/dev/null || true
    fi
    
    # npm global packages
    if command -v npm >/dev/null 2>&1; then
        npm list -g --depth=0 > "$target_dir/packages/npm-global.txt" 2>/dev/null || true
    fi
    
    # pip packages
    if command -v pip3 >/dev/null 2>&1; then
        pip3 list > "$target_dir/packages/pip-packages.txt" 2>/dev/null || true
    fi
    
    # Backup shell configurations
    log "Backing up shell configurations..."
    mkdir -p "$target_dir/dotfiles"
    
    for file in .zshrc .bashrc .bash_profile .profile .zprofile .gitconfig; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$target_dir/dotfiles/" 2>/dev/null || true
        fi
    done
    
    # Backup SSH configuration
    if [[ -d "$HOME/.ssh" ]]; then
        mkdir -p "$target_dir/ssh"
        cp "$HOME/.ssh/config" "$target_dir/ssh/" 2>/dev/null || true
        # Don't backup private keys for security
        cp "$HOME/.ssh"/*.pub "$target_dir/ssh/" 2>/dev/null || true
    fi
    
    # Backup system information
    log "Backing up system information..."
    mkdir -p "$target_dir/system"
    
    sw_vers > "$target_dir/system/macos-version.txt"
    uname -a > "$target_dir/system/kernel-info.txt"
    system_profiler SPHardwareDataType > "$target_dir/system/hardware-info.txt" 2>/dev/null || true
    
    # Backup launchd services (if any nix-darwin services exist)
    if [[ -d /Library/LaunchDaemons ]]; then
        find /Library/LaunchDaemons -name "*nix*" -exec cp {} "$target_dir/system/" \\; 2>/dev/null || true
    fi
    
    # Backup Nix store (if requested)
    if [[ $include_store == true ]]; then
        warning "Backing up Nix store (this may take a very long time and use significant space)..."
        if [[ -d /nix/store ]]; then
            mkdir -p "$target_dir/nix-store"
            # Create a tar archive instead of copying to save space
            tar -czf "$target_dir/nix-store.tar.gz" -C /nix store 2>/dev/null || {
                warning "Failed to backup Nix store completely"
                rm -f "$target_dir/nix-store.tar.gz"
            }
        fi
    fi
    
    # Create backup manifest
    log "Creating backup manifest..."
    find "$target_dir" -type f -exec ls -la {} \\; > "$target_dir/file-manifest.txt"
    
    # Calculate backup size
    local backup_size
    backup_size=$(du -sh "$target_dir" | cut -f1)
    
    success "Backup created successfully!"
    echo "  Name: $backup_name"
    echo "  Location: $target_dir"
    echo "  Size: $backup_size"
    echo "  Files: $(find "$target_dir" -type f | wc -l | tr -d ' ')"
}

# List available backups
list_backups() {
    local backup_dir="$DEFAULT_BACKUP_DIR"
    
    if [[ ! -d "$backup_dir" ]]; then
        warning "No backups directory found: $backup_dir"
        return 1
    fi
    
    echo "📦 Available Backups"
    echo "==================="
    echo
    
    local backup_count=0
    
    for backup in "$backup_dir"/*; do
        if [[ -d "$backup" && -f "$backup/backup-info.json" ]]; then
            local name
            name=$(basename "$backup")
            local size
            size=$(du -sh "$backup" 2>/dev/null | cut -f1 || echo "unknown")
            local timestamp
            timestamp=$(jq -r '.timestamp // "unknown"' "$backup/backup-info.json" 2>/dev/null || echo "unknown")
            
            echo "  📁 $name"
            echo "     Size: $size"
            echo "     Created: $timestamp"
            echo
            
            ((backup_count++))
        fi
    done
    
    if [[ $backup_count -eq 0 ]]; then
        warning "No valid backups found"
        return 1
    fi
    
    success "Found $backup_count backup(s)"
}

# Restore from backup
restore_backup() {
    local backup_name=""
    local config_only=false
    local dry_run=false
    local backup_dir="$DEFAULT_BACKUP_DIR"
    
    # Parse restore options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --backup)
                backup_name="$2"
                shift 2
                ;;
            --config-only)
                config_only=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                error "Unknown restore option: $1"
                ;;
        esac
    done
    
    if [[ -z "$backup_name" ]]; then
        error "Backup name is required. Use --backup NAME"
    fi
    
    local source_dir="$backup_dir/$backup_name"
    
    if [[ ! -d "$source_dir" ]]; then
        error "Backup not found: $source_dir"
    fi
    
    if [[ ! -f "$source_dir/backup-info.json" ]]; then
        error "Invalid backup: missing backup-info.json"
    fi
    
    log "Restoring from backup: $backup_name"
    
    # Show backup information
    if [[ -f "$source_dir/backup-info.json" ]]; then
        echo "📋 Backup Information:"
        jq . "$source_dir/backup-info.json" 2>/dev/null || cat "$source_dir/backup-info.json"
        echo
    fi
    
    if [[ $dry_run == true ]]; then
        log "DRY RUN - showing what would be restored:"
        echo
    fi
    
    # Restore Nix configuration
    if [[ -d "$source_dir/nix-config" ]]; then
        if [[ $dry_run == true ]]; then
            echo "Would restore Nix configuration to $CONFIG_DIR"
        else
            log "Restoring Nix configuration..."
            rm -rf "$CONFIG_DIR"
            cp -r "$source_dir/nix-config" "$CONFIG_DIR"
            success "Nix configuration restored"
        fi
    fi
    
    if [[ $config_only == true ]]; then
        success "Configuration-only restore completed"
        return 0
    fi
    
    # Restore dotfiles
    if [[ -d "$source_dir/dotfiles" ]]; then
        if [[ $dry_run == true ]]; then
            echo "Would restore dotfiles:"
            ls "$source_dir/dotfiles/"
        else
            log "Restoring dotfiles..."
            for file in "$source_dir/dotfiles"/*; do
                if [[ -f "$file" ]]; then
                    local filename
                    filename=$(basename "$file")
                    cp "$file" "$HOME/$filename"
                    log "Restored $filename"
                fi
            done
            success "Dotfiles restored"
        fi
    fi
    
    # Restore SSH configuration
    if [[ -d "$source_dir/ssh" ]]; then
        if [[ $dry_run == true ]]; then
            echo "Would restore SSH configuration"
        else
            log "Restoring SSH configuration..."
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"
            if [[ -f "$source_dir/ssh/config" ]]; then
                cp "$source_dir/ssh/config" "$HOME/.ssh/"
                chmod 600 "$HOME/.ssh/config"
            fi
            cp "$source_dir/ssh"/*.pub "$HOME/.ssh/" 2>/dev/null || true
            success "SSH configuration restored"
        fi
    fi
    
    if [[ $dry_run == true ]]; then
        echo
        warning "This was a dry run. No changes were made."
        echo "Run without --dry-run to perform the actual restore."
        return 0
    fi
    
    success "Restore completed successfully!"
    echo
    echo "🔄 Post-restore steps:"
    echo "1. Restart your terminal"
    echo "2. If you restored Nix config, run: darwin-rebuild switch --flake ~/.config/nix"
    echo "3. Check that your environment is working correctly"
}

# Clean old backups
clean_backups() {
    local backup_dir="$DEFAULT_BACKUP_DIR"
    local keep_count=10
    
    # Parse clean options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --keep)
                keep_count="$2"
                shift 2
                ;;
            *)
                error "Unknown clean option: $1"
                ;;
        esac
    done
    
    if [[ ! -d "$backup_dir" ]]; then
        warning "No backups directory found"
        return 0
    fi
    
    log "Cleaning old backups (keeping $keep_count most recent)..."
    
    # Get list of backups sorted by modification time
    local backups=()
    while IFS= read -r -d '' backup; do
        backups+=("$backup")
    done < <(find "$backup_dir" -maxdepth 1 -type d -name "*" ! -name "$(basename "$backup_dir")" -print0 | sort -z)
    
    local total_backups=${#backups[@]}
    
    if [[ $total_backups -le $keep_count ]]; then
        success "No cleanup needed ($total_backups backups, keeping $keep_count)"
        return 0
    fi
    
    local to_remove=$((total_backups - keep_count))
    
    log "Removing $to_remove old backup(s)..."
    
    for ((i=0; i<to_remove; i++)); do
        local backup_path="${backups[i]}"
        local backup_name
        backup_name=$(basename "$backup_path")
        log "Removing backup: $backup_name"
        rm -rf "$backup_path"
    done
    
    success "Cleanup completed. Removed $to_remove backup(s)"
}

# Main function
main() {
    local command="${1:-}"
    
    if [[ -z "$command" ]]; then
        show_help
        exit 1
    fi
    
    shift
    
    case "$command" in
        backup)
            create_backup "$@"
            ;;
        restore)
            restore_backup "$@"
            ;;
        list)
            list_backups "$@"
            ;;
        clean)
            clean_backups "$@"
            ;;
        --help|-h|help)
            show_help
            ;;
        *)
            error "Unknown command: $command"
            ;;
    esac
}

# Check for required tools
if ! command -v jq >/dev/null 2>&1; then
    warning "jq is not installed. Some features may not work correctly."
    warning "Install with: brew install jq"
fi

# Run main function
main "$@"