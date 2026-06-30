{ inputs, ... }: {
  flake-file.inputs = {
    # Neovim NvChad.
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  blazar.editors._.anivim.homeManager =
    _:
    let
      anivim = import ./_anivim/anivim.nix { inherit inputs; };
    in
    {
      imports = [
        anivim.homeModules.default
      ];
      anivim.enable = true;
    };
}
