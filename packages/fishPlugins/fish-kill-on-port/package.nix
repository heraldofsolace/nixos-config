{ pkgs, ... }:
let
  name = "fish-kill-on-port";
  version = "eb91062e5f5356ef63c6fff77f54fd10c027378e";
  hash = "sha256-rJ/HJsMhQYcRwcbSOacFjJsZOGfP3A2p3sAOx0zIAXY=";
  owner = "vincentjames501";
  repo = "fish-kill-on-port";
in
pkgs.stdenv.mkDerivation {
  inherit name version;

  src = pkgs.fetchFromGitHub {
    inherit owner repo;
    rev = version;
    sha256 = hash;
  };

  passthru.update = pkgs.writeShellScriptBin "update-${name}" ''
    set -euo pipefail

    latest="$(${pkgs.curl}/bin/curl -s "https://api.github.com/repos/${owner}/${repo}/commits?per_page=1" | ${pkgs.jq}/bin/jq -r ".[0].sha")"

    drift rewrite --auto-hash --new-version "$latest"
  '';
}
