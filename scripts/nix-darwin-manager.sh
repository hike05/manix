#!/bin/bash
set -euo pipefail

# Nix Darwin Configuration Manager
# Unified script for managing Nix Darwin installation, backup, and maintenance

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
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

title() {
    echo -e "${CYAN}$1${NC}"
}

# Show main menu
show_menu() {
    clear
    title "🚀 Nix Darwin Configuration Manager"
    title "===================================="
    echo
    echo "Choose an action:"
    echo
    echo "  📋 System & Preparation"
    echo "    1) Check system compatibility"
    echo "    2) View system information"
    echo
    echo "  🔧 Installation & Setup"
    echo "    3) Install Nix Darwin (full setup)"
    echo "    4) Update configuration"
    echo "    5) Rebuild system"
    echo
    echo "  💾 Backup & Restore"
    echo "    6) Create backup"
    echo "    7) List backups"
    echo "    8) Restore from backup"
    echo "    9) Clean old backups"
    echo
    echo "  🗑️  Maintenance & Removal"
    echo "   10) Optimize Nix store"
    echo "   11) Garbage collect"
    echo "   12) Uninstall Nix Darwin"
    echo
    echo "   13) Help & Documentation"
    echo "    0) Exit"
    echo
    read -p "Enter your choice [0-13]: " choice
    echo
}

# Check system compatibility
check_system() {
    title "🔍 System Compatibility Check"
    echo "=============================="
    echo
    "$SCRIPT_DIR/check-system.sh"
    echo
    read -p "Press Enter to continue..."
}

# Show system information
show_system_info() {
    title "💻 System Information"
    echo "======================"
    echo
    echo "🖥️  Hardware:"
    echo "   Architecture: $(uname -m)"
    echo "   Memory: $(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)"GB"}')"
    echo "   CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo
    echo "🍎 macOS:"
    echo "   Version: $(sw_vers -productVersion)"
    echo "   Build: $(sw_vers -buildVersion)"
    echo
    echo "💾 Storage:"
    df -h / | awk 'NR==2 {print "   Total: "$2", Used: "$3", Available: "$4", Usage: "$5}'
    echo
    echo "📦 Package Managers:"
    if command -v nix >/dev/null 2>&1; then
        echo "   Nix: $(nix --version | head -n1)"
    else
        echo "   Nix: Not installed"
    fi
    
    if command -v brew >/dev/null 2>&1; then
        echo "   Homebrew: $(brew --version | head -n1)"
    else
        echo "   Homebrew: Not installed"
    fi
    
    if command -v darwin-rebuild >/dev/null 2>&1; then
        echo "   nix-darwin: Installed"
    else
        echo "   nix-darwin: Not installed"
    fi
    echo
    read -p "Press Enter to continue..."
}

# Install Nix Darwin
install_nix_darwin() {
    title "🚀 Nix Darwin Installation"
    echo "==========================="
    echo
    warning "This will install Nix, nix-darwin, and configure your system."
    warning "Make sure you have backed up important data."
    echo
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        "$SCRIPT_DIR/install.sh"
    else
        log "Installation cancelled"
    fi
    echo
    read -p "Press Enter to continue..."
}

# Update configuration
update_config() {
    title "🔄 Update Configuration"
    echo "========================"
    echo
    if [[ ! -d "$HOME/.config/nix" ]]; then
        error "Nix configuration not found. Please install first."
        read -p "Press Enter to continue..."
        return
    fi
    
    cd "$HOME/.config/nix"
    
    echo "Current status:"
    git status --short
    echo
    
    read -p "Update flake inputs? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Updating flake inputs..."
        nix flake update
        success "Flake inputs updated"
    fi
    
    echo
    read -p "Rebuild system with changes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Rebuilding system..."
        # Detect hostname and build for it
        local hostname
        hostname=$(scutil --get LocalHostName 2>/dev/null || scutil --get ComputerName 2>/dev/null || echo "default")
        log "Using configuration for hostname: $hostname"
        
        if darwin-rebuild switch --flake .#${hostname} 2>/dev/null; then
            success "System rebuilt for hostname: $hostname"
        else
            warning "Failed to build for hostname '$hostname', trying default"
            darwin-rebuild switch --flake .#default
            success "System rebuilt using default configuration"
        fi
    fi
    
    echo
    read -p "Press Enter to continue..."
}

# Rebuild system
rebuild_system() {
    title "🔨 Rebuild System"
    echo "=================="
    echo
    if [[ ! -d "$HOME/.config/nix" ]]; then
        error "Nix configuration not found. Please install first."
        read -p "Press Enter to continue..."
        return
    fi
    
    log "Checking configuration..."
    cd "$HOME/.config/nix"
    if nix flake check; then
        success "Configuration is valid"
        echo
        log "Rebuilding system..."
        # Detect hostname and build for it
        local hostname
        hostname=$(scutil --get LocalHostName 2>/dev/null || scutil --get ComputerName 2>/dev/null || echo "default")
        log "Using configuration for hostname: $hostname"
        
        if darwin-rebuild switch --flake .#${hostname} 2>/dev/null; then
            success "System rebuild completed for hostname: $hostname"
        else
            warning "Failed to build for hostname '$hostname', trying default"
            darwin-rebuild switch --flake .#default
            success "System rebuild completed using default configuration"
        fi
    else
        error "Configuration check failed"
    fi
    
    echo
    read -p "Press Enter to continue..."
}

# Create backup
create_backup() {
    title "💾 Create Backup"
    echo "================="
    echo
    echo "Backup options:"
    echo "1) Quick backup (config + packages)"
    echo "2) Full backup (includes Nix store - very large)"
    echo "3) Custom backup"
    echo
    read -p "Choose backup type [1-3]: " backup_type
    
    case $backup_type in
        1)
            "$SCRIPT_DIR/backup-restore.sh" backup
            ;;
        2)
            "$SCRIPT_DIR/backup-restore.sh" backup --full
            ;;
        3)
            read -p "Enter backup name (optional): " backup_name
            if [[ -n "$backup_name" ]]; then
                "$SCRIPT_DIR/backup-restore.sh" backup --name "$backup_name"
            else
                "$SCRIPT_DIR/backup-restore.sh" backup
            fi
            ;;
        *)
            warning "Invalid choice"
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
}

# List backups
list_backups() {
    title "📦 Available Backups"
    echo "===================="
    echo
    "$SCRIPT_DIR/backup-restore.sh" list
    echo
    read -p "Press Enter to continue..."
}

# Restore from backup
restore_backup() {
    title "🔄 Restore from Backup"
    echo "======================="
    echo
    echo "Available backups:"
    "$SCRIPT_DIR/backup-restore.sh" list
    echo
    read -p "Enter backup name to restore: " backup_name
    
    if [[ -z "$backup_name" ]]; then
        warning "No backup name provided"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo
    echo "Restore options:"
    echo "1) Configuration only"
    echo "2) Full restore"
    echo "3) Dry run (preview)"
    echo
    read -p "Choose restore type [1-3]: " restore_type
    
    case $restore_type in
        1)
            "$SCRIPT_DIR/backup-restore.sh" restore --backup "$backup_name" --config-only
            ;;
        2)
            "$SCRIPT_DIR/backup-restore.sh" restore --backup "$backup_name"
            ;;
        3)
            "$SCRIPT_DIR/backup-restore.sh" restore --backup "$backup_name" --dry-run
            ;;
        *)
            warning "Invalid choice"
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
}

# Clean old backups
clean_backups() {
    title "🧹 Clean Old Backups"
    echo "===================="
    echo
    read -p "How many recent backups to keep? [10]: " keep_count
    keep_count=${keep_count:-10}
    
    "$SCRIPT_DIR/backup-restore.sh" clean --keep "$keep_count"
    
    echo
    read -p "Press Enter to continue..."
}

# Optimize Nix store
optimize_store() {
    title "⚡ Optimize Nix Store"
    echo "====================="
    echo
    log "Current store size:"
    du -sh /nix/store 2>/dev/null || echo "Store not accessible"
    echo
    
    log "Optimizing Nix store (deduplication)..."
    nix store optimise
    success "Store optimization completed"
    
    echo
    log "New store size:"
    du -sh /nix/store 2>/dev/null || echo "Store not accessible"
    
    echo
    read -p "Press Enter to continue..."
}

# Garbage collect
garbage_collect() {
    title "🗑️  Garbage Collection"
    echo "======================"
    echo
    log "Current store size:"
    du -sh /nix/store 2>/dev/null || echo "Store not accessible"
    echo
    
    echo "Garbage collection options:"
    echo "1) Remove all unused packages"
    echo "2) Remove packages older than 7 days"
    echo "3) Remove packages older than 30 days"
    echo
    read -p "Choose option [1-3]: " gc_option
    
    case $gc_option in
        1)
            log "Removing all unused packages..."
            nix-collect-garbage -d
            ;;
        2)
            log "Removing packages older than 7 days..."
            nix-collect-garbage --delete-older-than 7d
            ;;
        3)
            log "Removing packages older than 30 days..."
            nix-collect-garbage --delete-older-than 30d
            ;;
        *)
            warning "Invalid choice"
            read -p "Press Enter to continue..."
            return
            ;;
    esac
    
    success "Garbage collection completed"
    
    echo
    log "New store size:"
    du -sh /nix/store 2>/dev/null || echo "Store not accessible"
    
    echo
    read -p "Press Enter to continue..."
}

# Uninstall Nix Darwin
uninstall_nix_darwin() {
    title "🗑️  Uninstall Nix Darwin"
    echo "========================"
    echo
    warning "This will completely remove Nix Darwin from your system!"
    warning "All Nix packages and configuration will be deleted."
    echo
    read -p "Are you absolutely sure? Type 'yes' to confirm: " confirm
    
    if [[ "$confirm" == "yes" ]]; then
        "$SCRIPT_DIR/uninstall.sh"
    else
        log "Uninstallation cancelled"
    fi
    
    echo
    read -p "Press Enter to continue..."
}

# Show help and documentation
show_help() {
    title "📚 Help & Documentation"
    echo "========================"
    echo
    echo "📖 Documentation files:"
    echo "   README.md         - Complete user guide"
    echo "   INSTALL.md        - Installation instructions"
    echo "   UPDATE_CONFIG.md  - Configuration update guide"
    echo
    echo "🔧 Script files:"
    echo "   install.sh        - Full installation script"
    echo "   uninstall.sh      - Complete removal script"
    echo "   check-system.sh   - System compatibility check"
    echo "   backup-restore.sh - Backup and restore utility"
    echo
    echo "🌐 Online resources:"
    echo "   Nix Manual:       https://nixos.org/manual/nix/stable/"
    echo "   nix-darwin:       https://github.com/LnL7/nix-darwin"
    echo "   Home Manager:     https://nix-community.github.io/home-manager/"
    echo
    echo "🆘 Common commands:"
    echo "   rebuild           - Rebuild system configuration"
    echo "   nix-update        - Update flake inputs and rebuild"
    echo "   nix-check         - Check configuration validity"
    echo
    read -p "Press Enter to continue..."
}

# Main loop
main() {
    while true; do
        show_menu
        
        case $choice in
            1) check_system ;;
            2) show_system_info ;;
            3) install_nix_darwin ;;
            4) update_config ;;
            5) rebuild_system ;;
            6) create_backup ;;
            7) list_backups ;;
            8) restore_backup ;;
            9) clean_backups ;;
            10) optimize_store ;;
            11) garbage_collect ;;
            12) uninstall_nix_darwin ;;
            13) show_help ;;
            0) 
                echo "Goodbye! 👋"
                exit 0
                ;;
            *)
                warning "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi