# Minimal Homebrew configuration for cross-platform compatibility
# This configuration includes only essential CLI tools that are useful
# across different environments including servers and minimal setups
{ ... }:

{
  homebrew = {
    enable = true;

    # Conservative auto-update for cross-platform compatibility
    onActivation = {
      autoUpdate = false; # Manual control for servers
      upgrade = false; # Manual control for servers
      cleanup = "uninstall"; # Less aggressive cleanup
    };

    # Auto-install Homebrew if not present
    brewPrefix = "/opt/homebrew";
    caskArgs.require_sha = true;

    # Essential CLI tools only - no GUI applications
    brews = [
      # Essential development tools
      "mise" # Runtime version management (cross-platform)
      "direnv" # Environment management (essential for dev)
    ];

    # No GUI applications in default configuration
    casks = [ ];

    # No Mac App Store apps in default configuration
    masApps = { };

    # Minimal taps - only what's needed for the essential tools
    taps = [ ];
  };
}
