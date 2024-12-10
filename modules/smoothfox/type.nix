{ lib, extracted, ... }:
let
  mapListToAttrs = f: lst: builtins.listToAttrs (map f lst);

  settingType =
    setting:
    lib.types.submodule (
      { config, ... }:
      {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = setting.enabled;
            description = "Enable the ${setting.name} setting";
          };
          value = lib.mkOption {
            type = lib.types.anything;
            default = setting.value;
            description = "The value of the ${setting.name} setting";
          };
          flat = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            description = "Empty attrset in enable=false, the setting and its value otherwise";
            readOnly = true;
          };
        };
        config = {
          flat = if config.enable then { "${setting.name}" = config.value; } else { };
        };
      }
    );

  settingOption =
    setting:
    lib.nameValuePair setting.name (
      lib.mkOption {
        description = "Control the ${setting.name} setting";
        type = settingType setting;
        default = { };
      }
    );

  subsectionType =
    name: sub:
    lib.types.submodule (
      { config, ... }:
      {
        options = {
          enable = lib.mkEnableOption "settings for ${name}";
          flatSettings = lib.mkOption {
            description = "Flat attrset of all settings in subsection ${name} enabled";
            type = lib.types.attrsOf lib.types.anything;
            readOnly = true;
          };
        } // mapListToAttrs settingOption sub.settings;
        config = {
          enable = lib.mkDefault true;
          flatSettings =
            if config.enable then
              builtins.foldl' (x: y: x // y) { } (map (setting: config.${setting.name}.flat) sub.settings)
            else
              { };
        };
      }
    );
  subsectionOption =
    name: sub:
    lib.mkOption {
      description = "${name}: ${sub.meta.title}";
      type = subsectionType name sub;
      default = { };
    };

  sectionType =
    name: section:
    let
      subsections = builtins.removeAttrs section [ "meta" ];
    in
    lib.types.submodule (
      { config, ... }:
      {
        options = {
          enable = lib.mkOption {
            description = "setting for ${name}";
            type = lib.types.bool;
          };
          flatSettings = lib.mkOption {
            description = "Flat attrset of all settings in section ${name} enabled";
            type = lib.types.attrsOf lib.types.anything;
            readOnly = true;
          };
        } // lib.mapAttrs subsectionOption subsections;
        config = {
          flatSettings =
            if config.enable then
              builtins.foldl' (x: y: x // y) { } (
                lib.mapAttrsToList (name: _: config.${name}.flatSettings) subsections
              )
            else
              { };
        };
      }
    );
  sectionOption =
    name: section:
    lib.mkOption {
      description = "${name}: ${section.meta.title}";
      type = sectionType name section;
      default = { };
    };
  enableSection =
    name: _:
    { ... }:
    {
      "${name}".enable = lib.mkDefault false;
    };

  type = lib.types.submodule (
    { config, ... }:
    let
      sections = builtins.removeAttrs config [
        "enable"
        "flatSettings"
      ];
      enabledSections = builtins.length (
        builtins.filter (section: section.enable or false) (builtins.attrValues sections)
      );
    in
    {
      options = {
        enable = lib.mkEnableOption "Smoothfox settings";
        flatSettings = lib.mkOption {
          description = "Flat attrset of all settings enabled";
          type = lib.types.attrsOf lib.types.anything;
          readOnly = true;
        };
      } // lib.mapAttrs sectionOption extracted;
      config = {
        _module.check = lib.mkIf (enabledSections > 1) (
          throw "Only one section can be enabled at a time, in smoothfox."
        );
        flatSettings =
          if config.enable then
            builtins.foldl' (x: y: x // y) { } (
              lib.mapAttrsToList (name: _: config.${name}.flatSettings) extracted
            )
          else
            { };
      };
      imports = lib.mapAttrsToList enableSection extracted;
    }
  );
in
type
