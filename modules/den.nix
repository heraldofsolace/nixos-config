{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";
  # flake-file.inputs.allfollow.follows = "allfollow";
  flake-file.inputs.den.url = lib.mkDefault "github:vic/den";
  flake-file.inputs.flake-aspects.url = "github:vic/flake-aspects";

  flake-file.inputs.dendrix = {
    url = "github:vic/dendrix";
    # inputs = {
    #   import-tree.follows = "import-tree";
    #   nixpkgs-lib.follows = "nixpkgs-lib";
    # };
  };
  # flake-file.ipnuts.flake-parts.url = "github:hercules-ci/flake-parts";

  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];
}
