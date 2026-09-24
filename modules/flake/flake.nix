{
  lib,
  den,
  inputs,
  ...
}:
{
  debug = true;
  flake-file.inputs = {
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        # gitignore.follows = "gitignore-nix";
      };
    };
    latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    systems.url = "github:nix-systems/x86_64-linux";
    flake-compat = {
      url = "github:nix-community/flake-compat";
      # flake = false;
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    inputs.flake-parts.flakeModules.modules

    # inputs.flake-file.flakeModules.dendritic
    # inputs.flake-file.flakeModules.nix-auto-follow
    # inputs.flake-file.flakeModules.allfollow
    # inputs.flake-file.flakeModules.default
    # inputs.dendrix.vic-vix.macos-keys # example <macos-keys> aspect.
    # inputs.dendrix.vic-vix
    # inputs.dendrix.vix # example layer, see https://github.com/vic/dendrix/tree/main/dev/layers
    # inputs.devshell.flakeModule

    inputs.home-manager.flakeModules.home-manager

    inputs.git-hooks-nix.flakeModule
  ];

  systems = import inputs.systems;

  flake-file.description = "My personal Nix configuration, built with Dendritic.";
  # flake-file.prune-lock.enable = true;

  # Reusable nixos modules you might want to export
  # These are usually stuff you would upstream into nixpkgs
  # nixosModules = import ./modules/nixos;
  # Reusable home-manager modules you might want to export
  # These are usually stuff you would upstream into home-manager
  # homeManagerModules = import ./modules/home-manager;

  # Allow all aspects to contribute to the top-level flake outputs.
  den.schema.flake-system.into.host =
    { system }: map (host: { inherit host; }) (lib.attrValues den.hosts.${system});
}
