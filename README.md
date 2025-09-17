# 🚀 Nix Darwin Configuration

A modern, declarative macOS configuration using Nix, nix-darwin, and home-manager.

## ✨ Features

- 🔧 **System Management**: Declarative macOS system configuration
- 🏠 **User Environment**: Home-manager for dotfiles and user packages  
- 🍺 **Homebrew Integration**: GUI apps managed declaratively
- 🔄 **Development Environments**: Per-project dev shells with devenv
- 🧪 **CI/CD**: Automated testing and updates
- 📦 **Modern Tools**: Latest CLI utilities and development tools

## 🚀 Quick Start

### Initial Installation

```bash
# 1. Complete the nix-darwin activation (if not done):
cd ~/.config/nix
sudo ./result/sw/bin/darwin-rebuild switch --flake .

# 2. Restart terminal and apply configuration:
darwin-rebuild switch --flake ~/.config/nix
```

### Daily Usage

```bash
# Update system and home configuration
rebuild

# Update all flake inputs
nix flake update && rebuild

# Check configuration health
nix flake check
```

## 📁 Structure

```
~/.config/nix/
├── flake.nix              # Main configuration entry point
├── darwin/
│   ├── default.nix        # System configuration
│   └── homebrew.nix       # GUI applications via Homebrew
├── home/
│   ├── default.nix        # Home-manager configuration
│   ├── packages.nix       # CLI tools and utilities  
│   └── programs.nix       # Program configurations (git, zsh, etc.)
├── development/
│   ├── default.nix        # Development environments
│   └── templates/         # Project templates
├── .github/workflows/     # CI/CD pipeline
└── scripts/               # Utility scripts
```

## 🛠 Development Environments

### Using Templates

```bash
# Node.js project
nix flake init -t ~/.config/nix#nodejs
direnv allow

# Python project  
nix flake init -t ~/.config/nix#python
direnv allow
```

### Available Environments

- **Node.js**: Latest LTS with npm, pnpm, yarn
- **Python**: Python 3 with pip, poetry, virtualenv
- **Go**: Latest Go with tools and linters
- **Rust**: Stable Rust with cargo and tools
- **Full-stack**: Node.js + Python + PostgreSQL + Redis

## 🔧 Included Tools

### CLI Utilities
- `eza` - Modern ls replacement
- `bat` - Better cat with syntax highlighting
- `ripgrep` - Ultra-fast text search
- `fzf` - Fuzzy finder
- `fd` - Better find
- `jq`/`yq` - JSON/YAML processing

### Development Tools
- `git` with modern aliases and configuration
- `gh` - GitHub CLI
- `lazygit` - Git TUI
- `docker-compose` - Container orchestration
- `kubectl` - Kubernetes CLI

### Languages & Runtimes
- Node.js 20 (LTS)
- Python 3.12
- Go latest
- Rust stable

## 🎨 Shell Configuration

- **Zsh** with autocompletion and syntax highlighting
- **Starship** prompt with Git integration
- **Direnv** for automatic environment activation
- **Mise** for runtime version management
- Modern aliases and shortcuts

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

### Communication
- Telegram, Discord, Zoom

## 🔄 CI/CD Pipeline

Automated testing ensures configuration quality:

- ✅ **Syntax validation** on all Nix files
- ✅ **Multi-architecture testing** (Intel + Apple Silicon)  
- ✅ **Security scanning** for leaked secrets
- ✅ **Automatic updates** via scheduled PRs
- ✅ **Release automation** with attestations

## 📋 Management Commands

```bash
# System rebuild
rebuild                    # Alias for darwin-rebuild switch

# Package management
nix search nixpkgs <pkg>   # Search for packages
nix shell nixpkgs#<pkg>    # Temporary shell with package

# Development
nix develop                # Enter development shell
direnv allow               # Activate .envrc

# Maintenance  
nix store gc               # Garbage collection
nix store optimise         # Deduplicate store
```

## 🔐 Security

- 🚫 No secrets stored in configuration
- ✅ Automated secret scanning in CI
- 🔒 SSH keys managed via macOS Keychain
- 🛡️ Build attestations for releases

## 🆘 Troubleshooting

### Common Issues

**Command not found after installation:**
```bash
# Restart terminal or source new environment
source /etc/zshrc
```

**Build failures:**
```bash
# Clean and rebuild
nix store gc
nix flake check
rebuild
```

**Rollback system changes:**
```bash
sudo darwin-rebuild rollback
```

## 📦 Backup & Migration

- **Original configurations**: `~/nix-migration-backup/`
- **Package lists**: Homebrew, npm, pip packages exported
- **Dotfiles**: zshrc, gitconfig backed up

## 🤝 Contributing

1. Fork and create feature branch
2. Test with `nix flake check`  
3. Ensure CI passes
4. Submit pull request

## 📚 Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [nix-darwin Documentation](https://github.com/LnL7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [DevEnv Documentation](https://devenv.sh/)

---

💡 **Tip**: Join the [Nix community](https://nixos.org/community) for support and best practices!