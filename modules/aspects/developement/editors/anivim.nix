{ inputs, config, ... }:
let
  # Read at FILE level: the homeManager block's own `config` argument is the
  # Home-Manager config and would shadow this one.
  ci = config ? _module.args.CI;
in
{
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
      # `ci` (from the file-level flake config, not this block's Home-Manager
      # `config`) gates the neovim Ruby provider off during CI evaluation -
      # see hosts.ruby.enable in _anivim/anivim.nix.
      anivim = import ./_anivim/anivim.nix {
        inherit inputs ci;
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
