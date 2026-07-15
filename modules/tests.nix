# Some CI checks to ensure this template always works.
# Feel free to adapt or remove when this repo is yours.
{ inputs, ... }: {
  perSystem =
    { pkgs, ... }:
    let
      checkCond = name: cond: pkgs.runCommandLocal name { } (if cond then "touch $out" else "");
      andromeda = inputs.self.nixosConfigurations.andromeda.config;
      andromedaBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists andromeda.system.build.toplevel;
      horologium = inputs.self.nixosConfigurations.horologium.config;
      horologiumBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists horologium.system.build.toplevel;
      miranda = inputs.self.nixosConfigurations.miranda.config;
      mirandaBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists miranda.system.build.toplevel;
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
