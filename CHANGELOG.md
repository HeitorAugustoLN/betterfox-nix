# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0](https://github.com/HeitorAugustoLN/betterfox-nix/releases/tag/v3.0.0)

### Breaking Changes

- **BREAKING**: Removed LibreWolf support (#21) - LibreWolf support was removed as it was deprecated upstream.

### Features

- **Module renaming**: Renamed module file from `firefox.nix` to `betterfox.nix` (#27) for better clarity.
- **Improved project structure**:
  - Moved library files from `modules/home/lib` to `modules/home/_lib` to be ignored by `import-tree`.
  - Updated flake input organization with explicit type declarations (#26).
- **Enhanced documentation**:
  - Updated README.md with preferred import path for Home Manager module (#26).
  - Fixed typo in module import example (#20).
- **Dependency updates**:
  - Updated clap from 4.5.46 to 4.5.47 (#23).
  - Updated flake.lock files (#19, #24).

### Refactoring

- **Improved NixOS option definitions** (#25):
  - Replaced `lib.mkOption` with `lib.mkEnableOption` where appropriate.
  - Standardized option descriptions to end with periods.
  - Reordered code blocks for consistent structure.
- **Code cleanup**:
  - Removed unnecessary parentheses in partition definitions.
  - Renamed `dev-nixpkgs` input to `nixpkgs` for consistency.
  - Fixed CI workflow names and paths.

### Fixes

- **CI improvements**:
  - Fixed flake path in update-flake workflow.
  - Fixed workflow name in generate-preferences workflow.

## [2.0.1](https://github.com/HeitorAugustoLN/betterfox-nix/releases/tag/v2.0.1)

### Fixes

- Point to correct flake path in `default.nix` and `shell.nix`.

## [2.0.0](https://github.com/HeitorAugustoLN/betterfox-nix/releases/tag/v2.0.0) - PR #18 "rust"

### Breaking Changes

- **Complete rewrite**: Migrated from Python-based CLI to Rust-based CLI using `clap`.
- **Major project restructuring**: 122 files changed with significant architectural improvements.

### Features

- **New Rust-based CLI** with improved performance and reliability.
- **Enhanced flake.nix** for better development and building experience.
- **Automated dependency management** with `dependabot.yaml`.
- **Improved CI/CD pipeline**:
  - Added `check.yaml` to validate flake on every push and pull request.
  - Added `generate-prefs.yaml` for automatic preference generation.
- **Better project organization**:
  - Moved generated files to `data` directory.
  - Moved modules to `modules` directory.
  - CLI lives in its own dedicated directory.
- **CLI subcommands**:
  - `extract` - extracts preferences from files.
  - `generate` - generates preferences for Firefox, LibreWolf, and Smoothfox.

### Removed

- **Python-based CLI** completely replaced with Rust implementation.
- Removed old `regenerate.yaml` workflow.

## [1.0.0](https://github.com/HeitorAugustoLN/betterfox-nix/releases/tag/v1.0.0)

### Features

- Initial release of the Betterfox-nix module.
- Automatic generation of preferences for Firefox, LibreWolf, and Smoothfox.
- Home Manager modules for Firefox and LibreWolf.
- Support for multiple versions of Betterfox.
- Added a `flake.nix` for easy integration with other Nix projects.
- Added a Python-based CLI for extracting and generating preferences.
- Added CI to automatically update generated files.
- Added funding information.

### Fixes

- Fixed an issue where the wrong version of Betterfox was being used for LibreWolf.
- Fixed an issue where the regenerate action would fail if there were no changes.
- Fixed an issue where the `makeWrapper` was in `buildInputs` instead of `nativeBuildInputs`.

### Refactoring

- Refactored the extractor to be more modular and easier to maintain.
- Refactored the Nix code to be more idiomatic and easier to read.
