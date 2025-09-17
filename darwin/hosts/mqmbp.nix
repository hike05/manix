# Host-specific configuration for mqmbp (Maxime's MacBook Pro)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Host-specific system packages
  environment.systemPackages = with pkgs; [
    # Development-focused packages for main workstation
    docker
    kubectl
    terraform
    awscli2
  ];

  # Host-specific macOS defaults
  system.defaults = {
    # More aggressive dock settings for development machine
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      minimize-to-application = true;
      show-recents = false;
    };

    # Developer-friendly finder settings
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };

  # Host-specific Nix settings for development workstation
  nix.settings = {
    # More aggressive builds for powerful machine
    max-jobs = 8;
    cores = 8;
  };

  # Homebrew configuration for development workstation
  homebrew = {
    # Override default homebrew settings for development workstation
    onActivation = {
      autoUpdate = lib.mkForce true;
      upgrade = lib.mkForce true;
      cleanup = lib.mkForce "zap";
    };

    # Formulae (CLI tools)
    brews = [
      # Development tools
      "mise" # Runtime version management
      "direnv" # Environment management

      # Networking & Security
      "wireshark" # Network analysis
      "nmap" # Network mapping

      # Database tools
      "postgresql@14" # PostgreSQL
      "redis" # Redis server

      # System utilities
      "mas" # Mac App Store CLI
      "btop" # System monitor
    ];

    # Casks (GUI applications)
    casks = [
      # Development
      "visual-studio-code"
      "docker"
      "tableplus" # Database client
      "postman" # API testing

      # Productivity
      "1password" # Password manager
      "notion"
      "obsidian"

      # Communication
      "telegram"
      "discord"
      "zoom"

      # Utilities
      "raycast" # Spotlight replacement
      "cleanmymac" # System cleaner
      "the-unarchiver" # Archive utility

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
