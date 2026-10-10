# nix-topology: renders this flake's hosts, services and network links as an SVG.
# https://github.com/oddlama/nix-topology - upstream URL confirmed against the
# GitHub API (the commonly-cited `tudelft/...` path does not exist).
#
# Input declaration and module wiring are split on purpose. `flake-file` regenerates
# flake.nix from an evaluation of this flake, and a module that references
# `inputs.nix-topology` cannot evaluate before the input exists in flake.nix and
# flake.lock. So this file lands the declaration first; the wiring follows once the
# input is locked and the upstream option names can be read off the fetched source.
{
  flake-file.inputs.nix-topology = {
    url = "github:oddlama/nix-topology";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
