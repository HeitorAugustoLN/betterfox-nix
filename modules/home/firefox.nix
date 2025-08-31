{
  flake.modules.homeManager.betterfox =
    { config, lib, ... }:
    let
      cfg = config.programs.firefox.betterfox;
    in
    {
      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = builtins.all (
              profile:
              let
                smoothfoxEnabledSections = builtins.filter (section: profile.settings.smoothfox.${section}.enable) (
                  builtins.attrNames profile.settings.smoothfox
                );
              in
              builtins.length smoothfoxEnabledSections <= 1
            ) (builtins.attrValues cfg.profiles);
            message = "Only one smoothfox section can be enabled at a time across all profiles.";
          }
        ];

        programs.firefox.profiles = builtins.mapAttrs (_name: profile: {
          settings = profile.flatSettings;
        }) cfg.profiles;
      };

      options.programs.firefox.betterfox = {
        enable = lib.mkEnableOption "betterfox support in profiles";

        version = lib.mkOption {
          default = "main";
          description = "The version of betterfox user.js used";
          example = "142.0";
          type = lib.types.enum (builtins.attrNames (import ../../data/firefox));
        };

        profiles = lib.mkOption {
          default = { };
          description = "Configurations for each profile";
          type = lib.types.attrsOf (
            lib.types.submodule (
              { config, ... }:
              let
                data = (import ../../data/firefox).${cfg.version};
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
            )
          );
        };
      };
    };
}
