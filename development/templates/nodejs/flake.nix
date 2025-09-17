{
  description = "Node.js development environment";

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
      devShells.${system}.default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            devenv.root = toString ./.;
            packages = with pkgs; [
              nodejs_20
              nodePackages.npm
              nodePackages.pnpm
              nodePackages.yarn
            ];

            scripts.dev.exec = "npm run dev";
            scripts.build.exec = "npm run build";
            scripts.test.exec = "npm test";

            enterShell = ''
              echo "🚀 Node.js development environment ready!"
              if [ -f package.json ]; then
                echo "📦 Found package.json"
                if [ ! -d node_modules ]; then
                  echo "Installing dependencies..."
                  npm install
                fi
              fi
            '';
          }
        ];
      };
    };
}
