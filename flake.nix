{
  description = "Home-manager module to integrate Betterfox user.js in Firefox and Librewolf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems =
        function:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system: function inputs.nixpkgs.legacyPackages.${system}
        );

      treefmtEval = forAllSystems (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            ruff
            (python3.withPackages (
              pyPkgs: with pyPkgs; [
                python-lsp-ruff
                python-lsp-server
                requests
              ]
            ))
          ];
        };
      });

      formatter = forAllSystems (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      homeManagerModules.betterfox = import ./modules;

      packages = forAllSystems (pkgs: rec {
        betterfox-extractor = pkgs.callPackage ./extractor { };
        betterfox-generator = pkgs.callPackage ./generator { inherit betterfox-extractor; };
      });
    };
}
