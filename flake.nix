{
  description = "Home-manager module to integrate Betterfox user.js in Firefox and Librewolf";

  inputs = {
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      owner = "hercules-ci";
      repo = "flake-parts";
      type = "github";
    };

    import-tree = {
      owner = "vic";
      repo = "import-tree";
      type = "github";
    };

    nixpkgs = {
      owner = "NixOS";
      ref = "nixpkgs-unstable";
      repo = "nixpkgs";
      type = "github";
    };

    systems = {
      owner = "nix-systems";
      repo = "default";
      type = "github";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
