{ lib, ... }:
name: subsection:
lib.types.submodule (
  { config, ... }:
  {
    config.flatSettings = lib.optionalAttrs config.enable (
      builtins.foldl' (x: y: lib.recursiveUpdate x y) { } (
        map (pref: config.${pref.name}.flat) subsection.settings
      )
    );

    options =
      let
        prefOption = import ./_pref-option.nix { inherit lib; };
      in
      {
        enable = lib.mkOption {
          default = true;
          description = "Whether to enable preferences for ${name}";
          example = false;
          type = lib.types.bool;
        };

        flatSettings = lib.mkOption {
          description = "All enabled preferences in ${name} subsection";
          readOnly = true;
          type = lib.types.attrsOf lib.types.anything;
        };
      }
      // builtins.listToAttrs (map prefOption subsection.settings);
  }
)
