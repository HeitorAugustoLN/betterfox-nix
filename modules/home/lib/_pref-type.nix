{ lib, ... }:
pref:
lib.types.submodule (
  { config, ... }:
  {
    options = {
      enable = lib.mkEnableOption "${pref.name} preference" // {
        default = pref.enabled;
      };

      flat = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        readOnly = true;
      };

      value = lib.mkOption {
        type = lib.types.anything;
        default = pref.value;
        description = "Value of ${pref.name} preference.";
      };
    };

    config.flat = lib.optionalAttrs config.enable { ${pref.name} = config.value; };
  }
)
