{ config, lib, ... }:
let
  cfg = config.programs.firefox;
  version =
    if (config.programs.firefox.package != null) then
      "${config.programs.firefox.package.version}"
    else
      "unknown";
  ext = (import ../../autogen/firefox).${cfg.betterfox.version};
in
{
  options.programs.firefox = {
    betterfox = {
      enable = lib.mkEnableOption "betterfox support in profiles";
      version = lib.mkOption {
        description = "The version of betterfox user.js used";
        type = lib.types.enum (builtins.attrNames (import ../../autogen/firefox));
        default = "main";
      };
    };
    profiles = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, ... }:
          {
            options.betterfox = lib.mkOption {
              description = "Setup betterfox user.js in profile";
              type = import ./type.nix {
                extracted = ext;
                inherit lib;
              };
              default = { };
            };
            config = lib.mkIf cfg.betterfox.enable { settings = config.betterfox.flatSettings; };
          }
        )
      );
    };
  };

  config =
    lib.mkIf
      (
        cfg.enable
        && cfg.betterfox.enable
        && cfg.betterfox.version != "main"
        && !(lib.hasPrefix cfg.betterfox.version version)
      )
      {
        warnings = [ "Betterfox version ${cfg.betterfox.version} does not match Firefox's (${version})" ];
      };
}
