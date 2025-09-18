{
  description = "Maxime's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      # Helper function to create host configuration
      mkDarwinSystem =
        {
          hostname,
          system ? "aarch64-darwin",
          username ? "maxime",
          extraModules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs hostname username; };
          modules = [
            # Allow unfree packages
            { nixpkgs.config.allowUnfree = true; }
            ./darwin/default.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/default.nix;
              home-manager.backupFileExtension = "backup";
            }
            # Pass hostname and username to modules
            {
              networking.hostName = hostname;
              system.primaryUser = username;
              users.users.${username} = {
                name = username;
                home = "/Users/${username}";
              };
            }
          ]
          ++ extraModules;
        };
    in
    {
      # Multi-host configurations
      darwinConfigurations = {
        # Maxime's MacBook Pro (Apple Silicon)
        "mqmbp" = mkDarwinSystem {
          hostname = "mqmbp";
          system = "aarch64-darwin";
          username = "maxime";
          extraModules = [ ./darwin/hosts/mqmbp.nix ];
        };

        # Generic Apple Silicon configuration
        "macbook-air-m1" = mkDarwinSystem {
          hostname = "macbook-air-m1";
          system = "aarch64-darwin";
          username = "maxime";
          extraModules = [ ./darwin/hosts/macbook-air-m1.nix ];
        };

        # Generic Apple Silicon configuration for different user
        "macbook-pro-m2" = mkDarwinSystem {
          hostname = "macbook-pro-m2";
          system = "aarch64-darwin";
          username = "developer";
        };

        # Intel Mac configuration
        "imac-intel" = mkDarwinSystem {
          hostname = "imac-intel";
          system = "x86_64-darwin";
          username = "maxime";
        };

        # Generic configuration that uses hostname detection
        "default" = mkDarwinSystem {
          hostname = "default";
          system = "aarch64-darwin";
          username = "maxime";
        };
      };

      # Development shells for both architectures
      devShells = {
        aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
          buildInputs = with nixpkgs.legacyPackages.aarch64-darwin; [
            nixfmt-rfc-style
            nil
          ];
        };

        x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.mkShell {
          buildInputs = with nixpkgs.legacyPackages.x86_64-darwin; [
            nixfmt-rfc-style
            nil
          ];
        };

        x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
          buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
            nixfmt-rfc-style
            nil
          ];
        };
      };

      # Formatters for different architectures
      formatter = {
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
        x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-rfc-style;
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      };
    };
}
