# 🚀 Manix - Nix Darwin Configuration

Modern, declarative macOS development environment using Nix, nix-darwin, and home-manager.

## ⚡ Quick Start

### One-line install:
```bash
curl -fsSL https://raw.githubusercontent.com/hike05/manix/main/scripts/install.sh | bash
```

### Or clone and install:
```bash
git clone https://github.com/hike05/manix.git ~/.config/nix
cd ~/.config/nix && ./scripts/install.sh
```

## ✨ What you get

- **🔧 System Configuration**: Declarative macOS settings and preferences
- **🏠 User Environment**: Dotfiles, shell config, and user packages via home-manager
- **🍺 GUI Apps**: Visual Studio Code, Docker, 1Password, etc. via Homebrew
- **🛠️ Dev Tools**: Modern CLI tools, languages, and development environments
- **🌐 Multi-host**: Different configs for different machines (work, personal, etc.)

## 🔧 Included Tools

**CLI Utilities**: `eza`, `bat`, `ripgrep`, `fzf`, `fd`, `jq`, `htop`, `btop`
**Development**: `git`, `gh`, `lazygit`, `docker-compose`, `kubectl`
**Languages**: Node.js, Python, Go, Rust with dev environments
**Shell**: Zsh + Starship prompt + useful aliases

## 🏗️ Usage

```bash
# Daily commands
rebuild        # Apply configuration changes
nix-update     # Update packages and rebuild
nix-check      # Validate configuration

# Package management
nix search nixpkgs <package>    # Search for packages
nix shell nixpkgs#<package>     # Temporary shell with package

# Development environments
cd my-project && echo "use flake ~/.config/nix#nodejs" > .envrc && direnv allow
```

## 🌐 Multi-host Support

Automatically detects your hostname and applies the right configuration:
- `mqmbp` - MacBook Pro with full dev setup
- `macbook-air-m1` - Lightweight MacBook Air config
- `default` - Minimal cross-platform config

## 📁 Structure

```
~/.config/nix/
├── flake.nix                 # Main entry point
├── darwin/                   # System configuration
│   ├── default.nix           # Base system config
│   ├── homebrew.nix          # GUI apps
│   └── hosts/                # Host-specific configs
├── home/                     # User environment
│   ├── packages.nix          # CLI tools
│   └── programs.nix          # App configurations
├── development/              # Dev environments
└── scripts/                  # Management utilities
```

## 🔄 Management

```bash
# Backup before changes
./scripts/backup-restore.sh backup

# Interactive management TUI
./scripts/nix-darwin-manager.sh

# Complete removal
./scripts/uninstall.sh
```

## 🆘 Troubleshooting

**Command not found?** Restart terminal or run `source /etc/zshrc`
**Build issues?** Run `nix store gc && nix flake check && rebuild`
**Need to rollback?** Run `sudo darwin-rebuild rollback`

## 📚 Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://nix-community.github.io/home-manager/)

---

🎯 **Goal**: Zero-config macOS setup for developers with reproducible, declarative system management.