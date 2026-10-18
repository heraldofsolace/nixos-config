{
  fetchurl,
  writeShellApplication,
  wineWow64Packages,
  ...
}:
let
  version = "7.0.6.0";

  # Verified against the official winget manifest (microsoft/winget-pkgs,
  # manifests/v/vivo/OfficeKit/7.0.6.0) rather than guessing a download URL:
  # this is a silent-capable (NSIS/"nullsoft") x86 installer.
  installer = fetchurl {
    url = "https://pcsuite-api-static.vivo.com/upgrade-pre/pcsuite_upgrade_v${version}-cn_1792047724651.exe";
    sha256 = "E9E1D4F3E08A5E92279E8C9BFE7F24B5FB3B3261B4AA73921F32DEF9B9FB4181";
    # The CDN 403s plain curl's default User-Agent; a browser-like one works.
    curlOptsList = [
      "-A"
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    ];
  };

  wine = wineWow64Packages.stable;
in
writeShellApplication {
  name = "vivo-office-kit";
  runtimeInputs = [ wine ];
  text = ''
    export WINEPREFIX="''${WINEPREFIX:-$HOME/.local/share/wineprefixes/vivo-office-kit}"
    # No WINEARCH override: wineWow64Packages only supports win64 prefixes
    # (the x86 installer still runs fine under WOW64 translation).

    # Windows apps generally can't run straight from the read-only Nix
    # store, so the actual install happens here on first launch instead of
    # at build time - this derivation only ships the installer itself.
    if [ ! -d "$WINEPREFIX" ]; then
      echo "First run: creating Wine prefix and silently installing vivo Office Kit..."
      wineboot --init
      wine "${installer}" /S
      wineserver --wait
    fi

    # NSIS creates a Start Menu shortcut; let wine resolve its real target
    # rather than hardcoding an install path this package has no way to
    # verify without actually running the (Chinese, proprietary) installer.
    # || true: head closing the pipe early sends find/grep SIGPIPE, which
    # set -o pipefail would otherwise treat as a failure of this assignment.
    shortcut=$(
      find \
        "$WINEPREFIX/drive_c/users/"*"/Start Menu/Programs" \
        "$WINEPREFIX/drive_c/ProgramData/Microsoft/Windows/Start Menu/Programs" \
        -iname "*.lnk" 2>/dev/null |
        grep -viE "uninstall|卸载" |
        head -1 || true
    )
    if [ -z "$shortcut" ]; then
      echo "vivo-office-kit: couldn't find an installed shortcut in $WINEPREFIX - installation may have failed." >&2
      exit 1
    fi
    exec wine start /unix "$shortcut"
  '';
}
