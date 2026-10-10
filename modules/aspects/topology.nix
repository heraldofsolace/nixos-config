# The per-host half of nix-topology: importing this NixOS module is what makes a
# host appear in the generated diagram.
#
# It is inert by design - it only adds the `topology.*` options, the extractors
# and a `lib.topology` helper, with no services, packages or firewall rules - so it
# is safe to include on every host, including ones that should stay unchanged.
#
# The flake-level half (input, flake-parts module, global diagram definitions) is
# modules/flake/topology.nix; build with:
#
#   nix build .#topology.x86_64-linux.config.output
{ inputs, ... }:
{
  blazar.topology.nixos =
    { ... }:
    {
      imports = [ inputs.nix-topology.nixosModules.default ];

      # The node id defaults to networking.hostName, so no configuration is needed
      # for a host to show up: the extractors fill in the services and interfaces
      # they can read from this configuration.
      #
      # Hosts can add their own topology facts here, e.g.:
      #
      #   topology.networks.home = { name = "Home Network"; cidrv4 = "<cidr>"; };
      #   topology.self.interfaces.<iface>.network = "home";
      #
      # (`topology.self` is an alias for `topology.nodes.<this host>`.)
    };
}
