{
  lib,
  python3Packages,
  wrapGAppsHook3,
  fetchFromGitLab,
  ...
}:
with python3Packages; let
  wxpython = let
    waf_2_0_25 = pkgs.fetchurl {
      url = "https://waf.io/waf-2.0.25";
      hash = "sha256-IRmc0iDM9gQ0Ez4f0quMjlIXw3mRmcgnIlQ5cNyOONU=";
    };
  in
    python3Packages.wxpython.overrideAttrs {
      disabled = null;
      postPatch = ''
        cp ${waf_2_0_25} bin/waf-2.0.25
        chmod +x bin/waf-2.0.25
        substituteInPlace build.py \
          --replace-fail "wafCurrentVersion = '2.0.24'" "wafCurrentVersion = '2.0.25'" \
          --replace-fail "wafMD5 = '698f382cca34a08323670f34830325c4'" "wafMD5 = 'a4b1c34a03d594e5744f9e42f80d969d'" \
          --replace-fail "distutils.dep_util" "setuptools.modified"
      '';
    };
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
