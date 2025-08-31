{ lib, ... }:
pref:
lib.types.submodule (
  { config, ... }:
  {
    config.flat = lib.optionalAttrs config.enable { ${pref.name} = config.value; };

    options = {
      enable = lib.mkOption {
        default = pref.enabled;
        description = "Whether to enable ${pref.name} preference";
        type = lib.types.bool;
      };

      flat = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.anything;
      };

      value = lib.mkOption {
        default = pref.value;
        description = "Value of ${pref.name} preference";
        type = lib.types.anything;
      };
    };
  }
)
