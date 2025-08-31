{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem.pre-commit = {
    check.enable = true;
    settings.hooks.treefmt.enable = true;
  };
}
