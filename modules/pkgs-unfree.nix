# Unfree allowance at *flake-package* scope, separate from the NixOS-scope one.
#
# `packages.<system>.<name>` is built from the perSystem `pkgs`
# (`modules/pkgs-by-name.nix` sets `pkgsDirectory = ../packages`), and
# `make-shells.default` takes its packages from that same `pkgs`
# (`modules/devshells/default.nix`). The blanket in `modules/defaults.nix` is
# `den.default.nixos.nixpkgs.config` — NixOS scope — so it never reaches either,
# and forcing a flake package aborts evaluation even though the hosts allow
# unfree: `homeManager@blazar/keyboard/polymath` forces
# `self'.packages.polymath`, and `checks.x86_64-linux.default-shell` forces
# nixpkgs' `claude-code`.
#
# The allowance is a predicate naming exactly those two packages. Any third
# unfree flake package still fails `nix flake check` (KAN-2 criterion 2).
{
  inputs,
  ...
}:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (inputs.nixpkgs.lib.getName pkg) [
            "polymath"
            "claude-code"
          ];
      };
    };
}
