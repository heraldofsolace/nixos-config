# Some CI checks to ensure this template always works.
# Feel free to adapt or remove when this repo is yours.
{inputs, ...}: {
  perSystem = {
    pkgs,
    self',
    lib,
    ...
  }: let
    checkCond = name: cond:
      pkgs.runCommandLocal name {} (
        if cond
        then "touch $out"
        else ""
      );
    andromeda = inputs.self.nixosConfigurations.andromeda.config;
    andromedaBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists andromeda.system.build.toplevel;
    aniket-at-andromeda = andromeda.home-manager.users.aniket;
  in {
    # checks."igloo builds" = checkCond "igloo-builds" iglooBuilds;
    # checks."apple builds" = checkCond "apple-builds" appleBuilds;
    # checks."vm builds" = checkCond "vm-builds" vmBuilds;
    checks."andromeda builds" = checkCond "andromeda-builds" andromedaBuilds;
  };
}
