{
  flake.modules.homeManager.betterfox =
    { config, lib, ... }:
    let
      cfg = config.programs.librewolf.betterfox;
    in
    {
      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion =
              let
                smoothfoxEnabledSections = builtins.filter (
                  section: cfg.settings.settings.smoothfox.${section}.enable
                ) (builtins.attrNames cfg.settings.settings.smoothfox);
              in
              builtins.length smoothfoxEnabledSections <= 1;
            message = "Only one smoothfox section can be enabled at a time.";
          }
        ];

        programs.librewolf.settings = cfg.settings.flatSettings;
      };

      options.programs.librewolf.betterfox = {
        enable = lib.mkEnableOption "betterfox support";

        version = lib.mkOption {
          default = "128.0";
          description = "The version of betterfox user.js used";
          example = "126.0";
          type = lib.types.enum (builtins.attrNames (import ../../data/librewolf));
        };

        settings = lib.mkOption {
          default = { };
          description = "Configurations";
          type = lib.types.submodule (
            { config, ... }:
            let
              data = (import ../../data/librewolf).${cfg.version};
              smoothfoxData = (import ../../data/smoothfox).${cfg.version};
            in
            {
              config.flatSettings = lib.optionalAttrs config.enable (
                builtins.foldl' (x: y: lib.recursiveUpdate x y) { } (
                  lib.mapAttrsToList (name: _: config.settings.${name}.flatSettings) data
                )
                // builtins.foldl' (x: y: lib.recursiveUpdate x y) { } (
                  lib.mapAttrsToList (name: _: config.settings.smoothfox.${name}.flatSettings) smoothfoxData
                )
              );

              imports = lib.mapAttrsToList (
                name: _:
                { config, ... }:
                {
                  settings.${name}.enable = lib.mkDefault config.enableAllSections;
                }
              ) data;

              options = {
                enable = lib.mkOption {
                  default = builtins.any (x: x.enable) (builtins.attrValues config.settings);
                  defaultText = "`true` when `settings` has any section enabled";
                  description = "Whether to enable betterfox for this profile";
                  example = false;
                };

                enableAllSections = lib.mkEnableOption "all sections by default";

                flatSettings = lib.mkOption {
                  description = "All preferences";
                  readOnly = true;
                  type = lib.types.attrsOf lib.types.anything;
                };

                settings =
                  let
                    sectionOption = import ./lib/_section-option.nix { inherit lib; };
                  in
                  builtins.mapAttrs sectionOption data
                  // {
                    smoothfox = builtins.mapAttrs sectionOption smoothfoxData;
                  };
              };
            }
          );
        };
      };
    };
}
