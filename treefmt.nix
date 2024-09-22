{
  projectRootFile = "treefmt.nix";

  settings.globals.excludes = [ "./autogen/**" ];

  programs.nixfmt.enable = true;
  programs.ruff-check.enable = true;
  programs.ruff-format.enable = true;
}
