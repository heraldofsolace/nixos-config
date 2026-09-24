{
  inputs,
  lib,
  ...
}:
{
  # flake-file.inputs.flake-file.url = lib.mkDefault "github:denful/flake-file";
  # flake-file.inputs.allfollow.follows = "allfollow";
  flake-file.inputs.den.url = lib.mkDefault "github:denful/den";
  # flake-file.ipnuts.flake-parts.url = "github:hercules-ci/flake-parts";

  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];
}
