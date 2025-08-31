{ config, inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  flake = {
    homeModules = config.flake.modules.homeManager;
    modules.homeManager.default = config.flake.modules.homeManager.betterfox;
  };
}
