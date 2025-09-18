#!/bin/bash
set -euo pipefail

# Nix Darwin Configuration Activator
# Simple script to activate the prepared configuration

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Nix Darwin Configuration Activator${NC}"
echo "======================================="
echo

# Check if configuration is built
if [[ ! -L ./result ]]; then
    echo -e "${YELLOW}⚠️  Configuration not built yet.${NC}"
    echo "Run: nix build .#darwinConfigurations.mqmbp.system"
    exit 1
fi

echo -e "${GREEN}✅ Configuration ready:${NC} $(readlink ./result)"
echo

# Add Nix to PATH
export PATH="/nix/var/nix/profiles/default/bin:$PATH"

echo "🔧 Activating Nix Darwin configuration..."
echo "You will be prompted for your password for system-level changes."
echo

# Activate the configuration




echo
echo -e "${GREEN}🎉 Activation completed!${NC}"
echo
echo "📚 Next steps:"
echo "1. Restart your terminal or run: source /etc/zshrc"
echo "2. Check installed packages: which eza bat ripgrep"
echo "3. Use management commands: rebuild, nix-update, nix-check"
echo "4. Access TUI manager: ./scripts/nix-darwin-manager.sh"
echo