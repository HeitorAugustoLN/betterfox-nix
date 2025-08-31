{
  perSystem =
    {
      config,
      pkgs,
      self',
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [ self'.packages.betterfox-nix ];

        packages = [
          pkgs.cargo
          pkgs.clippy
          pkgs.rustc
        ];

        shellHook = config.pre-commit.installationScript;
      };
    };
}
