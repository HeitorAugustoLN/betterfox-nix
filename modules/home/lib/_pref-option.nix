{ lib, ... }:
pref: {
  inherit (pref) name;

  value =
    let
      prefType = import ./_pref-type.nix { inherit lib; };
    in
    lib.mkOption {
      type = prefType pref;
      default = { };
      description = "${pref.name} preference.";
    };
}
