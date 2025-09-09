{ lib, ... }:
name: section:
let
  subsections = builtins.removeAttrs section [ "meta" ];
in
lib.types.submodule (
  { config, ... }:
  {
    options =
      let
        subsectionOption = import ./_subsection-option.nix { inherit lib; };
      in
      {
        enable = lib.mkEnableOption "preferences for ${name}";

        flatSettings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          description = "All enabled preferences in ${name} section.";
          readOnly = true;
        };
      }
      // builtins.mapAttrs subsectionOption subsections;

    config.flatSettings = lib.optionalAttrs config.enable (
      builtins.foldl' (x: y: lib.recursiveUpdate x y) { } (
        lib.mapAttrsToList (name: _: config.${name}.flatSettings) subsections
      )
    );
  }
)
