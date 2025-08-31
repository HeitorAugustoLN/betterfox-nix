{ lib, ... }:
pref: {
  inherit (pref) name;

  value =
    let
      prefType = import ./_pref-type.nix { inherit lib; };
    in
    lib.mkOption {
      default = { };
      description = "${pref.name} preference";
      type = prefType pref;
    };
}
