{ inputs, ... }:
{
  flake-file.inputs.nixpkgs-multiverse = {
    url = "github:fzakaria/nixpkgs-multiverse";
    # Deliberately has no inputs of its own (see its flake.nix) - nothing to
    # follow here.
  };

  blazar.utils._.cryfs.homeManager = {
    imports = [ inputs.nixpkgs-multiverse.homeManagerModules.default ];

    # cryfs was removed from nixpkgs; pin the last version it ever shipped
    # (present through 2026-07-14, per `mvs query versions cryfs`) via
    # nixpkgs-multiverse instead of vendoring the package ourselves.
    multiverse.enable = true;
    multiverse.pins.cryfs = "1.0.3";
  };
}
