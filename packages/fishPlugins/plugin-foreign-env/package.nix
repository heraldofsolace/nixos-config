{ pkgs, ... }:
let
  name = "plugin-foreign-env";
  version = "7f0cf099ae1e1e4ab38f46350ed6757d54471de7";
  hash = "sha256-4+k5rSoxkTtYFh/lEjhRkVYa2S4KEzJ/IJbyJl+rJjQ";
  owner = "oh-my-fish";
  repo = "plugin-foreign-env";
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
    hash="$(${pkgs.nurl}/bin/nurl -H "https://github.com/${owner}/${repo}" "$latest")"

    ${pkgs.gnused}/bin/sed -i \
      -e "s|version = \".*\";|version = \"$latest\";|" \
      -e "s|hash = \".*\";|hash = \"$hash\";|" \
      "/home/aniket/my-nix/packages/fishPlugins/plugin-foreign-env/package.nix"
  '';
}
