{
  inputs = {
    betterfox-nix = {
      type = "path";
      path = "../.";
    };

    dev-nixpkgs.follows = "betterfox-nix/nixpkgs";

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
        nixpkgs.follows = "dev-nixpkgs";
      };
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
