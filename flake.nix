{
  description = "Maxime's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager, ... }: {
    # Build configuration for specific host
    darwinConfigurations."mqmbp" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./darwin/default.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.maxime = import ./home/default.nix;
        }
      ];
    };

    # Development shell for managing this flake
    devShells.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
      buildInputs = with nixpkgs.legacyPackages.aarch64-darwin; [
        nixfmt-rfc-style
        nil
      ];
    };
  };
}