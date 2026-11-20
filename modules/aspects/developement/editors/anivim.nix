{ inputs, ... }: {
  flake-file.inputs = {
    # nixCats-nvim: nix-driven lazy.nvim wrapper this anivim config builds on.
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  blazar.editors._.anivim.homeManager =
    {
      config,
      ...
    }:
    let
      # `ci` gates the neovim Ruby provider off during CI evaluation - see
      # hosts.ruby.enable in _anivim/anivim.nix.
      anivim = import ./_anivim/anivim.nix {
        inherit inputs;
        ci = config ? _module.args.CI;
      };
    in
    {
      imports = [
        anivim.homeModules.default
      ];
      anivim.enable = true;
      anivim.packageDefinitions.merge = {
        anivim = { pkgs, ... }: {
          extra = {
            base16colors = pkgs.lib.filterAttrs (
              k: _v: builtins.match "base0[0-9A-F]" k != null
            ) config.lib.stylix.colors.withHashtag;
          };
        };
      };
    };
}
