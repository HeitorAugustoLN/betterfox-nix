{
  inputs = {
    dev-nixpkgs = {
      owner = "NixOS";
      ref = "nixpkgs-unstable";
      repo = "nixpkgs";
      type = "github";
    };

    flake-compat = {
      owner = "edolstra";
      repo = "flake-compat";
      type = "github";
    };

    git-hooks = {
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "dev-nixpkgs";
      };

      owner = "cachix";
      repo = "git-hooks.nix";
      type = "github";
    };

    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
      inputs.nixpkgs.follows = "dev-nixpkgs";
    };
  };

  outputs = _: { };
}
