# Host-specific configuration for macbook-air-m1 (Generic MacBook Air M1)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Lightweight packages for MacBook Air
  environment.systemPackages = with pkgs; [
    # Essential tools only for lighter machine
    # heavier development tools should be in project-specific devenvs
  ];

  # Host-specific macOS defaults optimized for battery life
  system.defaults = {
    # Power-efficient dock settings
    dock = {
      autohide = true;
      minimize-to-application = true;
    };

    # Battery-friendly finder settings
    finder = {
      AppleShowAllExtensions = true;
    };

    # Energy saving settings
    NSGlobalDomain = {
      NSAutomaticWindowAnimationsEnabled = false;
      NSScrollAnimationEnabled = false;
    };
  };

  # Conservative Nix settings for MacBook Air
  nix.settings = {
    # Limit resource usage on lighter machine
    max-jobs = 4;
    cores = 4;
  };

  # Lightweight Homebrew configuration for MacBook Air
  homebrew = {
    # Override default homebrew settings for battery optimization
    onActivation = {
      autoUpdate = lib.mkForce false;
      upgrade = lib.mkForce false;
      cleanup = lib.mkForce "uninstall";
    };

    # Minimal essential applications
    casks = [
      # Essential productivity only
      "visual-studio-code" # Lightweight editor
      "1password" # Password manager essential

      # Basic utilities
      "the-unarchiver" # Archive utility
    ];

    # Essential CLI tools
    brews = [
      "direnv" # Environment management
    ];

    # No heavy applications or Mac App Store apps
    masApps = { };
    taps = [ ];
  };
}
