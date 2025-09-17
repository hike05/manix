{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI Essentials
    ripgrep         # Better grep
    fzf             # Fuzzy finder
    eza             # Better ls
    bat             # Better cat
    fd              # Better find
    tree            # Directory tree
    htop            # Process monitor
    jq              # JSON processor
    yq              # YAML processor
    
    # Network tools
    nmap            # Network scanner
    dig             # DNS lookup
    curl            # HTTP client
    wget            # Download utility
    
    # Development tools
    git             # Version control
    gh              # GitHub CLI
    lazygit         # Git TUI
    tig             # Git log viewer
    
    # Archive tools
    unzip           # ZIP extraction
    p7zip           # 7-Zip
    
    # Text processing
    gnused          # GNU sed
    gawk            # GNU awk
    
    # Monitoring
    neofetch        # System info
    speedtest-cli   # Internet speed test
    
    # Security
    age             # Encryption tool
    gnupg           # GPG encryption
    
    # Programming languages and tools
    nodejs_20       # Node.js LTS
    python3         # Python
    go              # Go language
    rustc           # Rust compiler
    cargo           # Rust package manager
    
    # Database clients
    postgresql      # PostgreSQL client
    redis           # Redis client
    
    # Container tools
    docker-compose  # Docker compose
    kubectl         # Kubernetes CLI
    
    # System utilities
    btop            # System monitor
    iftop           # Network monitor
    lsof            # List open files
    
    # Nix tools
    nixfmt-rfc-style # Nix formatter
    nil             # Nix LSP
    nix-tree        # Nix dependency tree
  ];
}