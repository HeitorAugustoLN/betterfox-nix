{ lib, ... }:
name: subsection:
lib.types.submodule (
  { config, ... }:
  {
    options =
      let
        prefOption = import ./pref-option.nix { inherit lib; };
      in
      {
        enable = lib.mkEnableOption "preferences for ${name}" // {
          default = true;
        };

        flatSettings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          description = "All enabled preferences in ${name} subsection.";
          readOnly = true;
        };
      }
      // builtins.listToAttrs (map prefOption subsection.settings);

    config.flatSettings = lib.optionalAttrs config.enable (
      builtins.foldl' (x: y: lib.recursiveUpdate x y) { } (
        map (pref: config.${pref.name}.flat) subsection.settings
      )
    );
  }
)
