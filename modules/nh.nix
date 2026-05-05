# Exposes flake apps under the name of each host / home for building with nh.
{
  den,
  lib,
  ...
}: {
  flake.den = den;
  perSystem = {pkgs, ...}: {
    packages = den.lib.nh.denPackages {fromFlake = true;} pkgs;
  };
}
