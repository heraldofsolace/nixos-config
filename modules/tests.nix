# Some CI checks to ensure this template always works.
# Feel free to adapt or remove when this repo is yours.
#
# The host checks assert that each host *evaluates to its own system
# derivation*. `builtins.pathExists <toplevel>` asserted the host was already
# built into this store: `pathExists` throws for an invalid store path, and a
# `--no-build` gate (`just gate-full`, `just ci`) never builds one, so the check
# went red on every tree that changed since the last switch. Forcing the drvPath
# still evaluates the whole host, so an unfree package keeps these red. (KAN-2)
{ inputs, ... }: {
  perSystem =
    { pkgs, lib, ... }:
    let
      checkCond = name: cond: pkgs.runCommandLocal name { } (if cond then "touch $out" else "");
      hostSystem = host: cfg: lib.hasInfix "nixos-system-${host}-" cfg.system.build.toplevel.drvPath;
      andromeda = inputs.self.nixosConfigurations.andromeda.config;
      andromedaBuilds = !pkgs.stdenvNoCC.isLinux || hostSystem "andromeda" andromeda;
      horologium = inputs.self.nixosConfigurations.horologium.config;
      horologiumBuilds = !pkgs.stdenvNoCC.isLinux || hostSystem "horologium" horologium;
      miranda = inputs.self.nixosConfigurations.miranda.config;
      mirandaBuilds = !pkgs.stdenvNoCC.isLinux || hostSystem "miranda" miranda;
    in
    {
      # checks."igloo builds" = checkCond "igloo-builds" iglooBuilds;
      # checks."apple builds" = checkCond "apple-builds" appleBuilds;
      # checks."vm builds" = checkCond "vm-builds" vmBuilds;
      checks."andromeda builds" = checkCond "andromeda-builds" andromedaBuilds;
      checks."horologium builds" = checkCond "horologium-builds" horologiumBuilds;
      checks."miranda builds" = checkCond "miranda-builds" mirandaBuilds;
    };
}
