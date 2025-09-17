{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      system = "aarch64-darwin";
    in
    {
      devShells.${system}.default = devenv.lib.mkShell {
        inherit inputs;
        modules = [
          {
            packages = with nixpkgs.legacyPackages.${system}; [
              python3
              python3Packages.pip
              python3Packages.virtualenv
              python3Packages.poetry
            ];

            scripts.venv.exec = ''
              if [ ! -d .venv ]; then
                python -m venv .venv
              fi
              source .venv/bin/activate
            '';

            scripts.install.exec = ''
              if [ -f requirements.txt ]; then
                pip install -r requirements.txt
              elif [ -f pyproject.toml ]; then
                poetry install
              fi
            '';

            enterShell = ''
              echo "🐍 Python development environment ready!"
              if [ -f requirements.txt ]; then
                echo "📋 Found requirements.txt"
              elif [ -f pyproject.toml ]; then
                echo "📋 Found pyproject.toml"
              fi
            '';
          }
        ];
      };
    };
}