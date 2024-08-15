{
  config,
  lib,
  ...
}: let
  cfg = config.programs.firefox;
  ext = (import ../autogen/smoothfox).${cfg.betterfox.version};
in {
  options.programs.firefox = {
    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
        options.betterfox.smoothfox = lib.mkOption {
          description = "Setup betterfox (Smoothfox) user.js in profile";
          type = import ./types.nix {
            extracted = ext;
            inherit lib;
          };
          default = {};
        };
        config = lib.mkIf cfg.betterfox.enable {
          settings = config.betterfox.flatSettings;
        };
      }));
    };
  };

  options.programs.librewolf = {
    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
        options.betterfox.smoothfox = lib.mkOption {
          description = "Setup betterfox (Smoothfox) user.js in profile";
          type = import ./types.nix {
            extracted = ext;
            inherit lib;
          };
          default = {};
        };
        config = lib.mkIf cfg.betterfox.enable {
          settings = config.betterfox.flatSettings;
        };
      }));
    };
  };
}
