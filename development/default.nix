# Development environments using devenv
#
# Usage:
#   cd project-directory
#   echo "use flake path/to/this/config" > .envrc
#   direnv allow

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      ...
    }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Node.js development environment
      devShells."${system}".nodejs = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            packages = with pkgs; [
              nodejs_20
              nodePackages.npm
              nodePackages.pnpm
              nodePackages.yarn
              nodePackages.typescript
              nodePackages."@types/node"
            ];

            scripts.dev.exec = "npm run dev";
            scripts.build.exec = "npm run build";
            scripts.test.exec = "npm test";

            enterShell = ''
              echo "🚀 Node.js development environment"
              echo "Node: $(node --version)"
              echo "NPM: $(npm --version)"
            '';
          }
        ];
      };

      # Python development environment
      devShells."${system}".python = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            packages = with pkgs; [
              python3
              python3Packages.pip
              python3Packages.virtualenv
              python3Packages.poetry
            ];

            scripts.venv.exec = "python -m venv .venv && source .venv/bin/activate";
            scripts.install.exec = "pip install -r requirements.txt";
            scripts.test.exec = "python -m pytest";

            enterShell = ''
              echo "🐍 Python development environment"
              echo "Python: $(python --version)"
              echo "Pip: $(pip --version)"
            '';
          }
        ];
      };

      # Go development environment
      devShells."${system}".go = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            packages = with pkgs; [
              go
              gopls
              gotools
              golangci-lint
            ];

            scripts.run.exec = "go run .";
            scripts.build.exec = "go build -o bin/";
            scripts.test.exec = "go test ./...";

            enterShell = ''
              echo "🐹 Go development environment"
              echo "Go: $(go version)"
            '';
          }
        ];
      };

      # Rust development environment
      devShells."${system}".rust = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            packages = with pkgs; [
              rustc
              cargo
              rust-analyzer
              rustfmt
              clippy
            ];

            scripts.run.exec = "cargo run";
            scripts.build.exec = "cargo build --release";
            scripts.test.exec = "cargo test";

            enterShell = ''
              echo "🦀 Rust development environment"
              echo "Rust: $(rustc --version)"
              echo "Cargo: $(cargo --version)"
            '';
          }
        ];
      };

      # Full-stack development environment
      devShells."${system}".fullstack = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            packages = with pkgs; [
              # Frontend
              nodejs_20
              nodePackages.npm
              nodePackages.pnpm

              # Backend
              python3
              python3Packages.pip

              # Database
              postgresql
              redis

              # Tools
              docker-compose
              curl
              jq
            ];

            services.postgres = {
              enable = true;
              initialDatabases = [ { name = "dev"; } ];
            };

            services.redis.enable = true;

            scripts.setup.exec = ''
              npm install
              pip install -r requirements.txt
            '';

            enterShell = ''
              echo "🌐 Full-stack development environment"
              echo "Node: $(node --version)"
              echo "Python: $(python --version)"
              echo "PostgreSQL and Redis services available"
            '';
          }
        ];
      };
    };
}
