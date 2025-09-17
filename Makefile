# Nix Darwin Configuration Makefile
# Convenient commands for managing the Nix Darwin setup

.PHONY: help install uninstall check backup restore clean manager update rebuild

# Default target
help:
	@echo "🚀 Nix Darwin Configuration Management"
	@echo "======================================"
	@echo
	@echo "Available commands:"
	@echo "  install     - Install Nix Darwin on a clean system"
	@echo "  check       - Check system compatibility"
	@echo "  update      - Update flake inputs and rebuild"
	@echo "  rebuild     - Rebuild system configuration"
	@echo "  backup      - Create a backup of current setup"
	@echo "  restore     - Restore from backup (interactive)"
	@echo "  clean       - Clean old backups and optimize store"
	@echo "  uninstall   - Completely remove Nix Darwin"
	@echo "  manager     - Launch interactive management interface"
	@echo "  help        - Show this help message"
	@echo
	@echo "Quick start:"
	@echo "  make check    # Check if your system is compatible"
	@echo "  make install  # Install on a fresh macOS system"
	@echo "  make manager  # Launch interactive manager"

# Check system compatibility
check:
	@echo "🔍 Checking system compatibility..."
	@./scripts/check-system.sh

# Install Nix Darwin
install:
	@echo "🚀 Installing Nix Darwin..."
	@./scripts/install.sh

# Update system
update:
	@echo "🔄 Updating Nix Darwin configuration..."
	@if [ -d ~/.config/nix ]; then \
		cd ~/.config/nix && \
		nix flake update && \
		darwin-rebuild switch --flake .; \
	else \
		echo "❌ Nix configuration not found. Please install first."; \
		exit 1; \
	fi

# Rebuild system
rebuild:
	@echo "🔨 Rebuilding system..."
	@if [ -d ~/.config/nix ]; then \
		cd ~/.config/nix && \
		darwin-rebuild switch --flake .; \
	else \
		echo "❌ Nix configuration not found. Please install first."; \
		exit 1; \
	fi

# Create backup
backup:
	@echo "💾 Creating backup..."
	@./scripts/backup-restore.sh backup

# Restore from backup
restore:
	@echo "🔄 Available backups:"
	@./scripts/backup-restore.sh list
	@echo
	@read -p "Enter backup name to restore: " backup_name; \
	if [ -n "$$backup_name" ]; then \
		./scripts/backup-restore.sh restore --backup "$$backup_name"; \
	else \
		echo "❌ No backup name provided"; \
	fi

# Clean and optimize
clean:
	@echo "🧹 Cleaning up..."
	@./scripts/backup-restore.sh clean --keep 5
	@if command -v nix >/dev/null 2>&1; then \
		echo "🗑️  Running garbage collection..."; \
		nix-collect-garbage --delete-older-than 7d; \
		echo "⚡ Optimizing store..."; \
		nix store optimise; \
	fi

# Uninstall
uninstall:
	@echo "🗑️  Uninstalling Nix Darwin..."
	@./scripts/uninstall.sh

# Launch interactive manager
manager:
	@./scripts/nix-darwin-manager.sh

# Development targets
dev-check:
	@echo "🧪 Running development checks..."
	@if [ -f flake.nix ]; then \
		nix flake check; \
	else \
		echo "❌ No flake.nix found in current directory"; \
		exit 1; \
	fi

dev-format:
	@echo "🎨 Formatting Nix files..."
	@if command -v nixfmt >/dev/null 2>&1; then \
		find . -name "*.nix" -exec nixfmt {} \;; \
	else \
		echo "❌ nixfmt not found. Install with: nix shell nixpkgs#nixfmt"; \
	fi

# Install from current directory (for development)
install-local:
	@echo "🚀 Installing from current directory..."
	@REPO_URL="" ./scripts/install.sh

# Quick status check
status:
	@echo "📊 Nix Darwin Status"
	@echo "===================="
	@echo
	@if command -v nix >/dev/null 2>&1; then \
		echo "✅ Nix: $$(nix --version | head -n1)"; \
	else \
		echo "❌ Nix: Not installed"; \
	fi
	@if command -v darwin-rebuild >/dev/null 2>&1; then \
		echo "✅ nix-darwin: Installed"; \
	else \
		echo "❌ nix-darwin: Not installed"; \
	fi
	@if command -v home-manager >/dev/null 2>&1; then \
		echo "✅ home-manager: Installed"; \
	else \
		echo "❌ home-manager: Not installed"; \
	fi
	@if [ -d ~/.config/nix ]; then \
		echo "✅ Configuration: ~/.config/nix"; \
	else \
		echo "❌ Configuration: Not found"; \
	fi
	@echo
	@echo "💾 Storage usage:"
	@if [ -d /nix/store ]; then \
		du -sh /nix/store 2>/dev/null || echo "  Nix store: Not accessible"; \
	else \
		echo "  Nix store: Not found"; \
	fi