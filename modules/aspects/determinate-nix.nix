{ inputs, ... }: {
  flake-file.inputs.determinate-nix = {
    url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };
  blazar.determinate-nix.nixos = { ... }: {
    imports = with inputs; [
      determinate-nix.nixosModules.default
    ];
  };
}
