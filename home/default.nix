{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./programs.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "maxime";
  home.homeDirectory = "/Users/maxime";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}