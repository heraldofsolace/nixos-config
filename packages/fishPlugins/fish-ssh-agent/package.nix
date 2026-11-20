{ pkgs, ... }:
let
  name = "fish-ssh-agent";
  version = "f10d95775352931796fd17f54e6bf2f910163d1b";
  hash = "sha256-cFroQ7PSBZ5BhXzZEKTKHnEAuEu8W9rFrGZAb8vTgIE=";
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

  installPhase = ''
    runHook preInstall

    if [[ -d functions ]]; then
      install -Dm644 -t $out/share/fish/vendor_functions.d functions/*.fish
    fi
    if [[ -d completions ]]; then
      install -Dm644 -t $out/share/fish/vendor_completions.d completions/*.fish
    fi
    if [[ -d conf.d ]]; then
      install -Dm644 -t $out/share/fish/vendor_conf.d conf.d/*.fish
    fi
    if [[ -f init.fish ]]; then
      install -Dm644 init.fish $out/share/fish/vendor_conf.d/${name}-init.fish
    fi

    runHook postInstall
  '';

  passthru.update = pkgs.writeShellScriptBin "update-${name}" ''
    set -euo pipefail

    latest="$(${pkgs.curl}/bin/curl -s "https://api.github.com/repos/${owner}/${repo}/commits?per_page=1" | ${pkgs.jq}/bin/jq -r ".[0].sha")"
    hash="$(${pkgs.nurl}/bin/nurl -H "https://github.com/${owner}/${repo}" "$latest")"

    ${pkgs.gnused}/bin/sed -i \
      -e "s|version = \".*\";|version = \"$latest\";|" \
      -e "s|hash = \".*\";|hash = \"$hash\";|" \
      "/home/aniket/my-nix/packages/fishPlugins/fish-ssh-agent/package.nix"
  '';
}
