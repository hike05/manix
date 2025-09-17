{ ... }:

{
  homebrew = {
    enable = true;
    
    # Auto-update and cleanup
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    # Formulae (CLI tools)
    brews = [
      # Development tools
      "mise"              # Runtime version management
      "direnv"            # Environment management
      
      # Networking & Security
      "wireshark"         # Network analysis
      "nmap"              # Network mapping
      
      # Database tools
      "postgresql@14"     # PostgreSQL
      "redis"             # Redis server
      
      # System utilities
      "mas"               # Mac App Store CLI
      "btop"              # System monitor
    ];

    # Casks (GUI applications)
    casks = [
      # Development
      "visual-studio-code"
      "docker"
      "tableplus"         # Database client
      "postman"           # API testing
      
      # Productivity
      "1password"
      "notion"
      "obsidian"
      
      # Communication
      "telegram"
      "discord"
      "zoom"
      
      # Utilities
      "raycast"           # Spotlight replacement
      "cleanmymac"        # System cleaner
      "the-unarchiver"    # Archive utility
      
      # Media
      "vlc"
      "spotify"
    ];

    # Mac App Store apps
    masApps = {
      "Xcode" = 497799835;
      "TestFlight" = 899247664;
    };

    # Taps (third-party repositories)
    taps = [
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
    ];
  };
}