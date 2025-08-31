{
  perSystem =
    { pkgs, self', ... }:
    {
      packages = {
        betterfox-nix = pkgs.callPackage ../../betterfox-nix { };
        default = self'.packages.betterfox-nix;
      };
    };
}
