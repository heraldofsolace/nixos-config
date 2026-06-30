{
  lib,
  inputs,
  ...
}:
let
  inherit (inputs) deploy-rs;
  lib' = {
    getExeName = pkg: lib.getExe pkg |> baseNameOf;
    getExeName' = pkg: name: lib.getExe' pkg name |> baseNameOf;
    mkDeploy =
      {
        self,
        overrides ? { },
      }:
      let
        hosts = self.nixosConfigurations or { };
        names = builtins.attrNames hosts;
        nodes = lib.foldl (
          result: name:
          let
            host = hosts.${name};
            user = host.config.user.name or null;
            inherit (host.pkgs.stdenv.hostPlatform) system;
          in
          result
          // {
            ${name} = (overrides.${name} or { }) // {
              hostname = overrides.${name}.hostname or "${name}";
              profiles = (overrides.${name}.profiles or { }) // {
                system =
                  (overrides.${name}.profiles.system or { })
                  // {
                    path = deploy-rs.lib.${system}.activate.nixos host;
                  }
                  // lib.optionalAttrs (user != null) {
                    user = "root";
                    sshUser = user;
                  };
              };
            };
          }
        ) { } names;
      in
      {
        inherit nodes;
      };
  };
  #   options = {
  #   lib = lib.mkOption {
  #   internal = true;
  #   visible = false;
  #   type = lib.types.attrsOf lib.types.raw;
  # };
in
{
  _module.args.lib' = lib';
  # FIXME: How to do this?
  # addax.lib = lib';
}
# {
#   addax.provides.lib' = den.lib.parametric.exactly {
#     description = ''
#       Provides the `flake-parts` `self'` (the flake's `self` with system pre-selected)
#       as a top-level module argument.
#       This allows modules to access per-system flake outputs without needing
#       `pkgs.stdenv.hostPlatform.system`.
#       ## Usage
#       **Global (Recommended):**
#       Apply to all hosts, users, and homes.
#           den.default.includes = [ den._.self' ];
#       **Specific:**
#       Apply only to a specific host, user, or home aspect.
#           den.aspects.my-laptop.includes = [ den._.self' ];
#           den.aspects.alice.includes = [ den._.self' ];
#       **Note:** This aspect is contextual. When included in a `host` aspect, it
#       configures `self'` for the host's OS. When included in a `user` or `home`
#       aspect, it configures `self'` for the corresponding Home Manager configuration.
#     '';
#     includes = [
#       (
#         { OS, host }:
#         let
#           unused = den.lib.take.unused OS;
#         in
#         withSystem host.system (
#           { lib', ... }:
#           {
#             ${host.class}._module.args.lib' = unused lib';
#           }
#         )
#       )
#       (
#         {
#           OS,
#           HM,
#           user,
#           host,
#         }:
#         let
#           unused = den.lib.take.unused [
#             OS
#             HM
#           ];
#         in
#         withSystem host.system (
#           { lib', ... }:
#           {
#             ${user.class}._module.args.lib' = unused lib';
#           }
#         )
#       )
#       (
#         { HM, home }:
#         let
#           unused = den.lib.take.unused HM;
#         in
#         withSystem home.system (
#           { lib', ... }:
#           {
#             ${home.class}._module.args.lib' = unused lib';
#           }
#         )
#       )
#     ];
#   };
# }
# forAllSystems =
#   fnWithPkgs:
#   # nixpkgs.lib.genAttrs (import inputs.systems) (
#   inputs.nixpkgs.lib.genAttrs inputs.nixpkgs.lib.systems.flakeExposed (
#     system:
#     fnWithPkgs (
#       import inputs.nixpkgs {
#         inherit system;
#         config.allowUnfree = true;
#       }
#     )
#   );
# forAllSystems =
#   function:
#   lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ]
#     (system: function nixpkgs.legacyPackages.${system});
#       installer
#       isInstall
#       isLima
# ++ (lib.optionals (installer != null) [ installer ])
# ++ lib.optionals isISO [ cd-dvd ]
# isISO = builtins.substring 0 4 hostname == "iso-";
# isInstall = !isISO;
# isLima = builtins.substring 0 5 hostname == "lima-";
# cd-dvd =
#   if (desktop == null) then
#     inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
#   else
#     inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
#       isISO
#       ;
#   };
