{ lib, ... }:
name: section:
let
  subsections = builtins.removeAttrs section [ "meta" ];
in
lib.types.submodule (
  { config, ... }:
  {
    config.flatSettings = lib.optionalAttrs config.enable (
      builtins.foldl' (x: y: lib.recursiveUpdate x y) { } (
        lib.mapAttrsToList (name: _: config.${name}.flatSettings) subsections
      )
    );

    options =
      let
        subsectionOption = import ./_subsection-option.nix { inherit lib; };
      in
      {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable preferences for ${name}";
          example = false;
          type = lib.types.bool;
        };

        flatSettings = lib.mkOption {
          description = "All enabled preferences in ${name} section";
          readOnly = true;
          type = lib.types.attrsOf lib.types.anything;
        };
      }
      // builtins.mapAttrs subsectionOption subsections;
  }
)
