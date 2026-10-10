# comin: a GitOps agent that polls a git remote and rebuilds this host when the
# branch moves. https://github.com/nlewo/comin - upstream URL confirmed against
# the GitHub API (`nix-community/comin` is not the repo, and comin is not in
# nixpkgs, which is why the flake's `pkgs.comin or ...` default falls back to the
# package this input provides).
#
# Wired but deliberately NOT activated. `services.comin.enable` stays false, so
# nothing but option definitions reaches any host: no service, no package, no
# firewall port. Flipping `enable` and filling in `remotes` is what makes a machine
# rebuild itself unattended, and that is the user's call - do one host first.
#
# Option names below are taken from comin's own generated option reference
# (docs/generated-module-options.md), not from memory.
{ inputs, ... }:
{
  flake-file.inputs.comin = {
    url = "github:nlewo/comin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  blazar.comin.nixos =
    { ... }:
    {
      imports = [ inputs.comin.nixosModules.comin ];

      services.comin = {
        # Deliberate: importing the module is what keeps the option paths below
        # real and checkable, while changing nothing about a running host.
        enable = false;

        # `hostname` is left at its default (networking.hostName), which is also
        # the attribute comin evaluates from nixosConfigurations.
        #
        # A remote is required before enabling. The shape, with option names
        # verified against the module:
        #
        #   name = "origin";
        #   url = "git@github.com:<owner>/my-nix.git";
        #   branches.main.name = "main";
        #   branches.main.operation = "switch";   # switch | test | boot
        #   branches.testing.name = "testing-<hostname>";
        #   poller.period = 60;                     # seconds
        #   auth.ssh_deploy_key_path = "<path>";     # XOR auth.access_token_path
        #   auth.ssh_known_hosts_path = "<path>";
        remotes = [ ]; 
      };
    };
}
