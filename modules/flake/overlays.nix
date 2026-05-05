{
  # imports = [
  #   inputs.flake-parts.flakeModules.easyOverlay
  # ];
  # flake.nixpkgs.overlays =
  # perSystem = { config, pkgs, ... }:
  # {
  # nixpkgs.config.allowUnfree = true;
  # _module.args.overlays =
  # import inputs.nixpkgs {
  # {
  # [
  # =
  # default =
  # (final: prev: {
  # This is where you can add your custom overlays
  # You can use 'final' to access the final set of packages
  # and 'prev' to access the previous set of packages
  # from the flake inputs.
  # my-package = prev.callPackage ./my-package.nix { };
  # perSystem =
  #   {
  #     config,
  #     pkgs,
  #     final,
  #     prev,
  #     system,
  #     ...
  #   }:
  #   {
  #       inherit system;
  #       overlays = [
  #         (final: prev: {
  # overlayAttrs = {
  #   inherit (config.packages) rimsort nix-direnv fishPlugins;
  # };
  #     # packages.my-package = /* ... */;
  # packages = {
  #       # };

  #       # config..args.pkgs = import inputs.nixpkgs {
  #       # inherit (pkgs) system;
  #       # overlays = [
  #       # inputs.foo.overlays.default
  #       # (final: prev:
  #       {
  #         # ... things you need to patch ...

  # example = prev.example.overrideAttrs (oldAttrs: rec {
  # ...
  # });
  #
  # nix-direnv = inputs'.nix-direnv.packages.default;

  #atuin = prev.atuin.overrideAttrs (_old: rec {
  #  src = prev.fetchFromGitHub {
  #    owner = "atuinsh";
  #    repo = "atuin";
  #    rev = "318bdd895590c97dd53f8d3661d76fa1c0cd67a0";
  #    hash = "sha256-OAmGG84YMniq1M6XEJKuPLiBp1fX1LGUJts1g9sEPYU=";
  #  };
  #  cargoHash = "sha256-BbpfstFn41c3/MDj1XA2kG3LIspTma02dEPyXfj9xUQ=";
  #});

  # rimsort = prev.rimsort.overrideAttrs (_old: {
  #   src = inputs.rimsort;
  #   # src = prev.fetchFromGitHub {
  #   #   owner = "RimSort";
  #   #   repo = "RimSort";
  #   #   rev = "master";
  #   #   hash = "sha256-MZfAZz5D3FKZzlfXm1eUCpJ4DodAzGYUkEzIrkN9uqE=";
  #   # };
  # });

  # fishPlugins = prev.fishPlugins.overrideScope (
  #   _fishPluginsFinal: fishPluginsPrev: {
  #     fifc = fishPluginsPrev.fifc.overrideAttrs (_old: {
  #       src = prev.fetchFromGitHub {
  #         owner = "Adda0";
  #         repo = "fifc";
  #         rev = "main";
  #         hash = "sha256-8U9vc/WB1Sos95Vn3rEjwazFKCDTtmXmM4LtCS+20Rw=";
  #       };
  #     });
  #   }
  # );
  # )
  #     # ];
  #   };
  # # Your custom packages and modifications, exported as overlays
  # # overlayAttrs = {
  # # inherit (config.packages) my-package;
  # # packages.my-package = /* ... */;
  # # This one brings our custom packages from the 'pkgs' directory
  # # additions =
  # #   final: _prev:
  # #   import ../pkgs {
  # #     inherit inputs;
  # #     pkgs = final;
  # #   };

  # # This one contains whatever you want to overlay
  # # You can change versions, add patches, set compilation flags, anything really.
  # # https://nixos.wiki/wiki/Overlays
  # # modifications = final: prev: {
  # # };

  # # };
  # config = { };
  # };
  # })
  # ];
  # };
  # };
  # };
  #
  perSystem = {
    # Override the src of hello
    packages = {
      # rimsort = pkgs.rimsort.overrideAttrs (prevAttrs: {
      #   src = inputs.rimsort;
      # });
      # hello = pkgs.hello.overrideAttrs (oldAttrs: {
      #   src = pkgs.fetchurl {
      #     url = "https://ftp.gnu.org/gnu/hello/hello-2.10.tar.gz";
      #     sha256 = "sha256-9d8a1f3b4c5e6f7b8c9d0e1f2a3b4c5e6f7b8c9d0e1f2a3b4c5e6f7b8c9d0e1f2";
      #   };
      # });
    };
  };
}
