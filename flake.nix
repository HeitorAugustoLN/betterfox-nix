{
  description = "Home-manager module to integrate Betterfox user.js in Firefox and Librewolf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            nixfmt-rfc-style
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

      formatter = forAllSystems (pkgs: pkgs.treefmt);

      homeManagerModules.betterfox = import ./modules;

      packages = forAllSystems (
        pkgs:
        let
          betterfox-extractor = pkgs.callPackage ./extractor { };
        in
        {
          inherit betterfox-extractor;
          betterfox-generator = pkgs.callPackage ./generator { inherit betterfox-extractor; };
        }
      );
    };
}
