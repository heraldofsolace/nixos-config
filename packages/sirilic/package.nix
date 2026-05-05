{
  python3Packages,
  wrapGAppsHook3,
  fetchFromGitLab,
  ...
}:
with python3Packages; let
  name = "sirilic";
  version = "1.15.12";
  owner = "free-astro";
  repo = "sirilic";
in
  buildPythonApplication rec {
    pname = name;
    inherit version;

    propagatedBuildInputs = [python3Packages.wxpython requests];
    doCheck = false;
    nativeBuildInputs = [wrapGAppsHook3];
    pyproject = true;
    build-system = with python3Packages; [setuptools];

    src = fetchFromGitLab {
      inherit owner repo;
      rev = "V${version}";
      sha256 = "sha256-6wGoWRcTtz0DGC6YujXXuk4WVsqsN+e2mqPJwvx8RyI=";
    };

    # passthru.update = pkgs.writeShellScriptBin "update-${name}" ''
    #   set -euo pipefail

    #   latest="$(${pkgs.curl}/bin/curl -s "https://api.github.com/repos/${owner}/${repo}/relases?per_page=1" | ${pkgs.jq}/bin/jq -r ".[0].sha")"

    #   drift rewrite --auto-hash --new-version "$latest"
    # '';
  }
