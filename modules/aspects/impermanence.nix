{ inputs, ... }: {
  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
  };
  blazar.impermanence.nixos = { ... }: {
    imports = with inputs; [
      impermanence.nixosModules.impermanence
    ];
  };
}
