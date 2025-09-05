{
  flake.modules.homeManager.betterfox =
    { config, lib, ... }:
    let
      cfg = config.programs.firefox.betterfox;
    in
    {
      options.programs.firefox.betterfox = {
        enable = lib.mkEnableOption "betterfox support in profiles";

        sources =
          let
            defaultSources = {
              firefox = import ../../data/firefox;
              smoothfox = import ../../data/smoothfox;
            };
          in
          lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.anything;
            default = defaultSources;
            defaultText = "{ ... }";
            example = lib.literalExpression ''
              {
                firefox."1337.0" = lib.importJSON ./1337.0.json;
                smoothfox."1337.1" = lib.importJSON ./1337.1.json;
              }
            '';
            description = "Betterfox and smoothfox data";
            apply = lib.recursiveUpdate defaultSources;
          };

        version = lib.mkOption {
          type = lib.types.str;
          default = "main";
          example = "142.0";
          description = "The version of betterfox user.js used";
        };

        profiles = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule (
              { config, ... }:
              let
                data = cfg.sources.firefox.${cfg.version};
                smoothfoxData = cfg.sources.smoothfox.${cfg.version};
              in
              {
                imports = lib.mapAttrsToList (
                  name: _:
                  { config, ... }:
                  {
                    settings.${name}.enable = lib.mkDefault config.enableAllSections;
                  }
                ) data;

                options = {
                  enable = lib.mkOption {
                    type = lib.types.bool;
                    default = builtins.any (x: x.enable) (builtins.attrValues config.settings);
                    defaultText = "`true` when `settings` has any section enabled";
                    example = false;
                    description = "Whether to enable betterfox for this profile";
                  };

                  enableAllSections = lib.mkEnableOption "all sections by default";

                  flatSettings = lib.mkOption {
                    type = lib.types.attrsOf lib.types.anything;
                    readOnly = true;
                    description = "All preferences";
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

                config.flatSettings = lib.optionalAttrs config.enable (
                  builtins.foldl' (x: y: lib.recursiveUpdate x y) { } (
                    lib.mapAttrsToList (name: _: config.settings.${name}.flatSettings) data
                  )
                  // builtins.foldl' (x: y: lib.recursiveUpdate x y) { } (
                    lib.mapAttrsToList (name: _: config.settings.smoothfox.${name}.flatSettings) smoothfoxData
                  )
                );
              }
            )
          );
          default = { };
          description = "Configurations for each profile";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = builtins.hasAttr cfg.version cfg.sources.firefox;
            message = "Version '${cfg.version}' not found in available firefox sources. Available versions: ${lib.concatStringsSep ", " (builtins.attrNames cfg.sources.firefox)}";
          }
          {
            assertion = builtins.hasAttr cfg.version cfg.sources.smoothfox;
            message = "Version '${cfg.version}' not found in available smoothfox sources. Available versions: ${lib.concatStringsSep ", " (builtins.attrNames cfg.sources.smoothfox)}";
          }
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
    };
}
