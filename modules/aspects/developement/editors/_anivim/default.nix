{
  lib,
  config,
  namespace,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.editors.anivim;
  anivim = import ./anivim.nix {inherit inputs;};
in {
  imports = [
    anivim.homeModules.default
  ];

  options.${namespace}.editors.anivim = {
    enable = mkEnableOption "anivim";
  };

  config =
    mkIf cfg.enable
    {
      anivim.enable = true;
    };
}
