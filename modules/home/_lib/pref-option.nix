{ lib, ... }:
pref: {
  inherit (pref) name;

  value =
    let
      prefType = import ./pref-type.nix { inherit lib; };
    in
    lib.mkOption {
      type = prefType pref;
      default = { };
      description = "${pref.name} preference.";
    };
}
