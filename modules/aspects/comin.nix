# comin: a GitOps agent that polls a git remote and rebuilds this host when the
# branch moves. https://github.com/nlewo/comin - upstream URL confirmed against
# the GitHub API (`nix-community/comin` is not the repo, and comin is not in
# nixpkgs, which is why the flake's `pkgs.comin or ...` default falls back to the
# package this input provides).
#
# Enabled per host via `enabledHosts` below: only the hosts listed there run the
# agent, every other host just imports the module with `enable = false` (no
# service, no package, no firewall port). Enabling another host is a one-line
# edit of that list.
#
# The remote is the nixos-config repository's `main` branch, applied with
# `switch`. The repo is PUBLIC, so it is cloned over HTTPS with no `auth` block:
# comin runs as root under systemd and cannot use the user's SSH key, and an
# anonymous HTTPS clone needs no deploy key or token (and so no secret to manage).
#
# Option names below are taken from comin's own module (nix/module-options.nix
# in the flake input), not from memory.
{ inputs, ... }:
{
  flake-file.inputs.comin = {
    url = "github:nlewo/comin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  blazar.comin.nixos =
    { config, ... }:
    let
      # Hosts that run comin. The single place to opt a machine in or out.
      enabledHosts = [ "andromeda" ];
    in
    {
      imports = [ inputs.comin.nixosModules.comin ];

      services.comin = {
        enable = builtins.elem config.networking.hostName enabledHosts;

        # `hostname` is left at its default (networking.hostName), which is also
        # the attribute comin evaluates from nixosConfigurations.
        remotes = [
          {
            name = "origin";
            url = "https://github.com/heraldofsolace/nixos-config.git";
            branches.main = {
              name = "main";
              operation = "switch"; # switch | test | boot
            };
            poller.period = 60; # seconds
          }
        ];
      };
    };
}
