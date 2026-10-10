# nix-topology: renders this flake's hosts, services and network links as an SVG.
#
# Input declaration and module wiring are split on purpose. `flake-file` regenerates
# flake.nix from an evaluation of this flake, and a module that references
# `inputs.nix-topology` cannot evaluate before the input exists in flake.nix and
# flake.lock. So this file lands the declaration, `nix run .#generate-files` +
# `nix flake lock` make it real, and only then does the wiring below get added.
{
  flake-file.inputs.nix-topology = {
    url = "github:tudelft/nix-topology";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
