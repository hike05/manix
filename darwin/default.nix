{ config, pkgs, ... }:

{
  imports = [
    ./homebrew.nix
  ];

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # Essential system utilities
    curl
    wget
    git
    vim
    tree
    htop
    
    # Development tools
    nixfmt-rfc-style
    nil
  ];

  # Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
  };
  
  # Use auto-optimise through nix.optimise instead of nix.settings
  nix.optimise.automatic = true;

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # Set Git commit hash for darwin-version
  system.configurationRevision = null;

  # Set primary user for homebrew and system defaults
  system.primaryUser = "maxime";

  # Used for backwards compatibility, please read the changelog before changing
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";

  # macOS system settings
  system.defaults = {
    dock.autohide = true;
    finder.FXPreferredViewStyle = "clmv";
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };

  # User configuration
  users.users.maxime = {
    name = "maxime";
    home = "/Users/maxime";
  };
}