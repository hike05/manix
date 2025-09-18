{
  config,
  pkgs,
  inputs,
  hostname ? "default",
  username ? "maxime",
  ...
}:

{
  imports = [
    # ./homebrew.nix  # Temporarily disabled
  ];

  # Minimal packages for cross-platform compatibility (servers + workstations)
  environment.systemPackages = with pkgs; [
    # Essential system utilities (lightweight, server-friendly)
    curl
    wget
    git
    vim
    tree
    htop
    gh

    # Basic Nix tools
    nixfmt-rfc-style
    nil
  ];

  # Disable nix-darwin's Nix management (using Determinate Nix)
  nix.enable = false;

  # Nix settings - using Determinate Nix, so we configure but don't manage
  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # Set Git commit hash for darwin-version
  system.configurationRevision = null;

  # Primary user for homebrew and system defaults (handled by flake.nix)
  # system.primaryUser is set dynamically in flake.nix based on username parameter

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

  # User configuration (handled by flake.nix)
  # users.users configuration is set dynamically in flake.nix based on username parameter
}
