# Betterfox-nix

This repository provides a Nix Home Manager module that integrates the [Betterfox user.js](https://github.com/yokoffing/Betterfox) configurations into Firefox, enhancing privacy and performance.

## Table of contents

- [Features](#features)
- [Getting started](#getting-started)
- [Acknowledgments](#acknowledgments)
- [License](#license)

## Features

- **Automatic Integration:** Seamlessly apply Betterfox settings to your Firefox profiles using Nix.
- **Version Control:** Choose the Betterfox version that suits your needs, including the latest main branch or specific releases.
- **Cross-platform**: Works on any system supported by Nix and Home Manager.

## Getting started

To begin using Betterfox-nix, add the module to your Nix configuration and enable it for your preferred browser.

#### Example Configuration

Below is an example of how to integrate Betterfox with Firefox using this module:

```nix
{ inputs, ... }:
{
  # Choose one of the following import methods
  imports = [
    inputs.betterfox.flake.modules.homeManager.betterfox
    # Or
    # inputs.betterfox.homeModules.betterfox
  ];

  # In firefox
  programs.firefox = {
    enable = true;

    betterfox = {
      enable = true;

      profiles.example-profile = {
        # Set this to enable all sections by default
        enableAllSections = true;

        settings = {
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

      version = "142.0"; # Set version here, defaults to main branch
    };

    profiles.example-profile = {
      name = "Example";
    };
  };
}
```

## Acknowledgments

- [@e-tho](https://github.com/e-tho) for the foundational work on betterfox-extractor and betterfox-generator.
- [@dwarfmaster](https://github.com/dwarfmaster) for developing the arkenfox home-manager module that inspired this project.

## License

This project is licensed under the [MIT License](LICENSE).