{
  inputs = {
    betterfox-nix = {
      type = "path";
      path = "../.";
    };

    nixpkgs.follows = "betterfox-nix/nixpkgs";

    flake-compat = {
      type = "github";
      owner = "edolstra";
      repo = "flake-compat";
    };

    git-hooks = {
      type = "github";
      owner = "cachix";
      repo = "git-hooks.nix";

      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };

    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = _: { };
}
