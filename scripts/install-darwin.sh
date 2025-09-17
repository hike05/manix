#!/bin/bash
set -euo pipefail

echo "🚀 Installing nix-darwin configuration..."

# Check if we're in the right directory
if [[ ! -f "flake.nix" ]]; then
    echo "❌ Error: flake.nix not found. Please run this script from ~/.config/nix"
    exit 1
fi

# Build the configuration first to catch any errors
echo "🔨 Building darwin configuration..."
nix build .#darwinConfigurations.mqmbp.system

# Run the actual installation
echo "🔧 Running darwin-rebuild..."
echo "You may be prompted for your password for system-level changes."

# Use the nix-generated darwin-rebuild
result/sw/bin/darwin-rebuild switch --flake .

echo "✅ nix-darwin installation complete!"
echo "🔄 Please restart your terminal or run: source /etc/zshrc"