{pkgs, ...}: let
  name = "fish-ssh-agent";
  version = "f10d95775352931796fd17f54e6bf2f910163d1b";
  hash = "";
  owner = "danhper";
  repo = "fish-ssh-agent";
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
