{inputs, ...}: {
  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
  };
  blazar.impermanence.nixos = {
    lib,
    pkgs,
    config,
    ...
  }: {
    imports = with inputs; [
      impermanence.nixosModules.impermanence
    ];
  };
}
