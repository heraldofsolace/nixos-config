# nix-topology: renders this flake's hosts, their services and network links as
# SVGs directly from the NixOS configurations.
# https://github.com/oddlama/nix-topology - upstream URL confirmed against the
# GitHub API (the commonly-cited `tudelft/...` path does not exist).
#
# This is the flake-level half; modules/aspects/topology.nix is the per-host half
# that makes each host participate. Build the diagrams with:
#
#   nix build .#topology.x86_64-linux.config.output
#
# Input declaration and module wiring are split from the earlier passes on
# purpose: `flake-file` regenerates flake.nix from an evaluation of this flake, and
# a module referencing `inputs.nix-topology` cannot evaluate before the input
# exists in flake.nix and flake.lock.
{ inputs, ... }:
{
  flake-file.inputs.nix-topology = {
    url = "github:oddlama/nix-topology";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.nix-topology.flakeModule ];

  perSystem =
    { ... }:
    {
      # No overlay wiring needed here: the flake module defaults
      # `topology.pkgs` to `pkgs.extend`d with nix-topology's own overlay.
      #
      # Global diagram definitions belong in `topology.modules`: the physical
      # world that cannot be read off a NixOS configuration, i.e. networks, the
      # switch/router/APs, and which interface of which host plugs into what.
      # Verified option shapes from the upstream documentation:
      #
      #   networks.home = { name = "Home Network"; cidrv4 = "192.168.1.1/24"; };
      #   nodes.<node>.interfaces.<iface>.network = "home";
      #   nodes.<node>.interfaces.<iface>.physicalConnections = [
      #     { node = "<other-node>"; interface = "<iface>"; }
      #   ];
      #
      # Per-host additions can instead go under `topology = { ... }` in a host
      # configuration (see modules/aspects/topology.nix).
      #
      # Left empty: every entry above needs real LAN facts (CIDRs, interface
      # names, switch ports) that are not derivable from this repository.
      topology.modules = [ ];
    };
}
