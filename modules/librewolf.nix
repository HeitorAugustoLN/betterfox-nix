{
  config,
  lib,
  ...
}: let
  cfg = config.programs.librewolf;
  version =
    if (config.programs.librewolf.package != null)
    then "${config.programs.librewolf.package.version}"
    else "unknown";
  ext = (import ../autogen/librewolf).${cfg.betterfox.version};
in {
  options.programs.librewolf = {
    betterfox = {
      enable = lib.mkEnableOption "betterfox support in profiles";
      version = lib.mkOption {
        description = "The version of betterfox user.js used";
        type = lib.types.enum (builtins.attrNames (import ../autogen/librewolf));
        default = "main";
      };
    };
    settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
        options.betterfox = lib.mkOption {
          description = "Setup betterfox user.js in settings";
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

  config = lib.mkIf (cfg.enable && cfg.betterfox.enable && !(lib.hasPrefix cfg.betterfox.version version)) {
    warnings = [
      "Betterfox version ${cfg.betterfox.version} does not match Librewolf's (${version})"
    ];
  };
}
