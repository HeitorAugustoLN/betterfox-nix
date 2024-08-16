{
  config,
  lib,
  ...
}: let
  cfg = config.programs.firefox;
  cfg' = config.programs.librewolf;
  ext = (import ../../autogen/smoothfox).${cfg.betterfox.version};
  ext' = (import ../../autogen/smoothfox).${cfg'.betterfox.version};
in {
  options.programs.firefox = {
    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
        options.betterfox.smoothfox = lib.mkOption {
          description = "Setup betterfox (Smoothfox) user.js in profile";
          type = import ./type.nix {
            extracted = ext;
            inherit lib;
          };
          default = {};
        };
        config = lib.mkIf cfg.betterfox.enable {
          settings = config.betterfox.smoothfox.flatSettings;
        };
      }));
    };
  };

  options.programs.librewolf.betterfox.settings = {
    smoothfox = lib.mkOption {
      description = "Setup betterfox (Smoothfox) user.js in profile";
      type = import ./type.nix {
        extracted = ext';
        inherit lib;
      };
      default = {};
    };
  };

  config = lib.mkIf (cfg'.betterfox.enable) {
    # TODO: Add assertions for smoothfox
    programs.librewolf.settings = cfg'.betterfox.settings.smoothfox.flatSettings;
  };
}
