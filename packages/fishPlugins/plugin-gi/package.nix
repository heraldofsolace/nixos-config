# packages/my-package/default.nix
{ pkgs, ... }:
let
  name = "plugin-gi";
  version = "48bc41a86c5dcf14ffe3745a7f61cba728a4de0c";
  hash = "sha256-njrOCUaWVj+CIZTUzRGrG4yxcEONEl2fpYuXZrAd4qg=";
  owner = "oh-my-fish";
  repo = "plugin-gi";
in
pkgs.stdenv.mkDerivation {
  inherit name version;

  src = pkgs.fetchFromGitHub {
    inherit owner repo;
    rev = version;
    sha256 = hash;
  };

  passthru.update = pkgs.writeShellScriptBin "update-plugin-gi" ''
    set -euo pipefail

    latest="$(${pkgs.curl}/bin/curl -s "https://api.github.com/repos/${owner}/${repo}/commits?per_page=1" | ${pkgs.jq}/bin/jq -r ".[0].sha")"

    drift rewrite --auto-hash --new-version "$latest"
  '';
}
