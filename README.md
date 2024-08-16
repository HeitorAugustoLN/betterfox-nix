# Betterfox-nix

This repository provides a Nix Home Manager module that integrates the [Betterfox user.js](https://github.com/yokoffing/Betterfox) configurations into Firefox and LibreWolf, enhancing privacy and performance.

## Table of contents

- [Features](#features)
- [Getting started](#getting-started)
- [Acknowledgments](#acknowledgments)
- [License](#license)

## Features

- **Automatic Integration:** Seamlessly apply Betterfox settings to your Firefox and LibreWolf profiles using Nix.
- **Version Control:** Choose the Betterfox version that suits your needs, including the latest main branch or specific releases.
- **Cross-platform**: Works on any system supported by Nix and Home Manager.

## Getting started

To begin using Betterfox-nix, add the module to your Nix configuration and enable it for your preferred browser(s).

#### Example Configuration

Below is an example of how to integrate Betterfox with both Firefox and LibreWolf using this module:

```nix
{inputs, ...}: {
  imports = [inputs.betterfox.homeManagerModules.betterfox];

  # In firefox
  programs.firefox = {
    enable = true;
    betterfox = {
      enable = true;
      version = "128.0"; # Set version here, defaults to main branch
    };
    profiles.example-profile = {
      betterfox = {
        enable = true;
        # Set this to enable all sections by default
        enableAllSections = true;

        # To enable/disable specific sections
        fastfox.enable = true;

        # To enable/disable specific subsections
        peskyfox = {
          enable = true;
          mozilla-ui.enable = false;
        };

        # To enable/disable specific options
        securefox = {
          enable = true;
          tracking-protection."browser.download.start_downloads_in_tmp_dir".value = false;
        };
      };
    };
  };

  # In librewolf
  programs.librewolf = {
    enable = true;
    betterfox = {
      enable = true;
      version = "128.0";
      settings = {
        enable = true;
        enableAllSections = true;
      };
    };
  };
}
```

## Acknowledgments

- [@e-tho](https://github.com/e-tho) for the foundational work on betterfox-extractor and betterfox-generator.
- [@dwarfmaster](https://github.com/dwarfmaster) for developing the arkenfox home-manager module that inspired this project.

## License

This project is licensed under the [MIT License](LICENSE).
