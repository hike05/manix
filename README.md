# 🚀 Nix Darwin Configuration

Modern, declarative macOS configuration using Nix, nix-darwin, and home-manager for developers and daily use.

## ✨ Features

- 🔧 **System Management**: Declarative macOS system configuration
- 🏠 **User Environment**: Home-manager for dotfiles and user packages  
- 🍺 **Homebrew Integration**: GUI apps managed declaratively
- 🔄 **Development Environments**: Per-project dev shells with devenv
- 🧪 **CI/CD**: Automated testing and updates
- 📦 **Modern Tools**: Latest CLI utilities and development tools
- 🌐 **Multi-host Support**: Configurations for different machines

## 🚀 Quick Start

### One-Command Installation

```bash
# Check system compatibility
make check

# Install on fresh macOS system
make install

# Or use script directly
./scripts/install.sh
```

### Interactive Management

```bash
# Launch interactive manager
make manager

# Or run directly
./scripts/nix-darwin-manager.sh
```

### Daily Usage

```bash
# Quick commands via Makefile
make update     # Update flake inputs and rebuild
make rebuild    # Rebuild system configuration  
make backup     # Create system backup
make check      # Check system compatibility
make status     # Show current status
make clean      # Clean old data

# Traditional commands (aliases)
rebuild         # Rebuild system
nix-update      # Update and rebuild
nix-check       # Check configuration
```

## 🌐 Multi-host Support

The project supports installation on different machines with automatic hostname detection:

### Pre-configured Hosts
- `mqmbp` - MacBook Pro (Apple Silicon) - user: maxime
- `macbook-air-m1` - MacBook Air M1 - user: maxime  
- `macbook-pro-m2` - MacBook Pro M2 - user: developer
- `imac-intel` - Intel iMac - user: maxime
- `default` - fallback configuration

### Building for Specific Host
```bash
# For specific host
darwin-rebuild switch --flake .#mqmbp

# Automatic host detection
darwin-rebuild switch --flake .

# Use fallback configuration
darwin-rebuild switch --flake .#default
```

### Adding New Host
Add entry to `flake.nix`:
```nix
"your-hostname" = mkDarwinSystem {
  hostname = "your-hostname";
  system = "aarch64-darwin"; # or "x86_64-darwin" for Intel
  username = "your-username";
  extraModules = [
    ./darwin/hosts/your-hostname.nix  # optional host-specific config
  ];
};
```

## 📁 Project Structure

```
/Users/maxime/Projects/manix/
├── flake.nix                     # Main configuration entry point
├── darwin/
│   ├── default.nix               # System configuration
│   ├── homebrew.nix              # GUI applications via Homebrew
│   └── hosts/                    # Host-specific configurations
│       ├── README.md             # Host documentation
│       ├── mqmbp.nix             # Main workstation configuration
│       └── macbook-air-m1.nix    # Lightweight MacBook Air configuration
├── home/
│   ├── default.nix               # Home-manager configuration
│   ├── packages.nix              # CLI tools and utilities  
│   └── programs.nix              # Program configurations (git, zsh, etc.)
├── development/
│   ├── default.nix               # Development environments
│   └── templates/                # Project templates
│       ├── nodejs/               # Node.js template
│       └── python/               # Python template
├── scripts/                      # Utilities and scripts
│   ├── install.sh                # Full installation script
│   ├── uninstall.sh              # Complete removal script
│   ├── backup-restore.sh         # Backup and restore utility
│   ├── check-system.sh           # System compatibility check
│   └── nix-darwin-manager.sh     # Interactive TUI manager
├── .github/workflows/            # CI/CD pipeline
└── Makefile                      # Convenient commands
```

## 🛠 Development Environments

### Using Templates

```bash
# Node.js project
mkdir my-project && cd my-project
nix flake init -t ~/.config/nix#nodejs
direnv allow

# Python project  
mkdir my-python-app && cd my-python-app
nix flake init -t ~/.config/nix#python
direnv allow
```

### Available Environments

- **Node.js**: Latest LTS with npm, pnpm, yarn, TypeScript
- **Python**: Python 3 with pip, poetry, virtualenv
- **Go**: Latest Go with tools and linters
- **Rust**: Stable Rust with cargo and tools
- **Full-stack**: Node.js + Python + PostgreSQL + Redis

## 🔧 Included Tools

### CLI Utilities
- `eza` - Modern ls replacement
- `bat` - Enhanced cat with syntax highlighting
- `ripgrep` - Ultra-fast text search
- `fzf` - Fuzzy finder
- `fd` - Enhanced find
- `jq`/`yq` - JSON/YAML processing
- `tree` - Directory structure display
- `htop`/`btop` - System monitoring

### Development Tools
- `git` with modern aliases and configuration
- `gh` - GitHub CLI
- `lazygit` - Git TUI
- `docker-compose` - Container orchestration
- `kubectl` - Kubernetes CLI
- `nixfmt-rfc-style` - Nix code formatting
- `nil` - Nix LSP server

### Languages & Runtimes
- Node.js 20 (LTS)
- Python 3.12
- Go latest version
- Rust stable version
- PostgreSQL, Redis

## 🎨 Shell Configuration

- **Zsh** with autocompletion and syntax highlighting
- **Starship** prompt with Git integration
- **Direnv** for automatic environment activation
- **Mise** for runtime version management
- Modern aliases and shortcuts

### Useful Aliases
```bash
# Navigation
..    # cd ..
...   # cd ../..
....  # cd ../../..

# Git
gs    # git status
ga    # git add
gc    # git commit
gp    # git push
gl    # git pull

# Nix
nix-search    # nix search nixpkgs
rebuild       # darwin-rebuild switch --flake ~/.config/nix
nix-update    # nix flake update && rebuild
nix-check     # nix flake check
```

## 🍺 GUI Applications (via Homebrew)

### Development
- Visual Studio Code
- Docker Desktop
- TablePlus (database client)
- Postman (API testing)

### Productivity  
- 1Password
- Raycast (Spotlight replacement)
- Notion, Obsidian
- CleanMyMac

### Communication
- Telegram, Discord, Zoom

### Utilities
- The Unarchiver
- VLC Media Player
- Spotify

### Mac App Store
- TestFlight
- Xcode

## 💾 Backup & Restore

### Creating Backups
```bash
# Quick backup
./scripts/backup-restore.sh backup

# Named backup
./scripts/backup-restore.sh backup --name "before-big-change"

# Full backup (includes Nix store - very large)
./scripts/backup-restore.sh backup --full
```

### Restoration
```bash
# View available backups
./scripts/backup-restore.sh list

# Restore
./scripts/backup-restore.sh restore --backup "backup-name"

# Configuration only
./scripts/backup-restore.sh restore --backup "backup-name" --config-only

# Preview
./scripts/backup-restore.sh restore --backup "backup-name" --dry-run
```

## 🔄 CI/CD Pipeline

Automated testing ensures configuration quality:

- ✅ **Syntax validation** of all Nix files
- ✅ **Multi-architecture testing** (Intel + Apple Silicon)  
- ✅ **Security scanning** for leaked secrets
- ✅ **Automatic updates** via scheduled PRs
- ✅ **Release automation** with attestations

## 📋 Management Commands

```bash
# System rebuild
rebuild                    # Alias for darwin-rebuild switch

# Package management
nix search nixpkgs <pkg>   # Search packages
nix shell nixpkgs#<pkg>    # Temporary shell with package
nix profile install nixpkgs#<pkg>  # Install package to profile

# Development
nix develop                # Enter development shell
direnv allow               # Activate .envrc

# Maintenance  
nix store gc               # Garbage collection
nix store optimise         # Store deduplication
nix-collect-garbage -d     # Remove all unused packages
nix-collect-garbage --delete-older-than 30d  # Remove packages older than 30 days
```

## 🔐 Security

- 🚫 No secrets stored in configuration
- ✅ Automated secret scanning in CI
- 🔒 SSH keys managed via macOS Keychain
- 🛡️ Build attestations for releases
- 🔍 Integrity verification with GitHub Attestations

## 🆘 Troubleshooting

### Common Issues

**Command not found after installation:**
```bash
# Restart terminal or load new environment
source /etc/zshrc
```

**Build failures:**
```bash
# Clean and rebuild
nix store gc
nix flake check
rebuild
```

**System rollback:**
```bash
sudo darwin-rebuild rollback
```

**Permission issues:**
```bash
# Check directory permissions
ls -la ~/.config/nix
ls -la /nix

# Fix permissions (if needed)
sudo chown -R $(whoami) ~/.config/nix
```

**Restore from backup:**
```bash
./scripts/backup-restore.sh restore --backup "last-known-good"
```

## 🗑️ Complete Removal

To completely remove Nix Darwin:

```bash
# Interactive removal
./scripts/uninstall.sh

# Automatic removal (careful!)
./scripts/uninstall.sh --force
```

The uninstall script:
- Stops and removes nix-darwin services
- Removes system configuration
- Removes home-manager
- Removes user Nix profiles
- Removes system Nix installation
- Removes Nix users and groups
- Cleans shell configurations
- Creates backup before removal

## 📦 Migration & Backup

During installation, automatic backup is created:
- **Original configurations**: in timestamped backup directory
- **Package lists**: Homebrew, npm, pip packages exported
- **Dotfiles**: zshrc, gitconfig backed up
- **SSH configuration**: config and public keys

## 🚀 Development Installation

For development and testing:

```bash
# Install from current directory (for development)
make install-local

# Check configuration
make dev-check

# Format Nix files
make dev-format
```

## 🤝 Contributing

1. Fork and create feature branch
2. Test with `nix flake check`  
3. Ensure CI passes
4. Submit pull request

## 📚 Resources & Documentation

### Official Documentation
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [nix-darwin Documentation](https://github.com/LnL7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [DevEnv Documentation](https://devenv.sh/)

### Additional Guides
- [darwin/hosts/README.md](darwin/hosts/README.md) - Host-specific configuration documentation

### Community
- [NixOS Community](https://nixos.org/community) - Official community
- [NixOS Discourse](https://discourse.nixos.org/) - Community forum
- [r/NixOS](https://reddit.com/r/NixOS) - Reddit community

## ⚡ Hotkeys & Useful Commands

```bash
# Search packages
nix search nixpkgs python

# Package information
nix show-config

# List installed packages
nix profile list

# Update single package
nix profile upgrade nixpkgs#package-name

# View dependencies
nix-tree ~/.nix-profile

# Storage size
du -sh /nix/store

# System status
make status
```

---

💡 **Tip**: Start with `make check`, then `make install`, and use `make manager` for daily management!

🎯 **Project Goal**: Provide a modern, scalable, and reliable macOS management system for developers, with multi-host deployment support and full automation.