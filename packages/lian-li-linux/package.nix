{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  rustPlatform,
  pkg-config,
  clang,
  llvmPackages,
  cmake,
  nasm,
  libusb1,
  udev,
  ffmpeg,
  linuxPackages,
  fontconfig,
  mesa,
  libxkbcommon,
  wayland,
  libX11,
  libinput,
  libdrm,
  glib,
  gtk3,
  webkitgtk_4_1,
  libsoup_3,
  libayatana-appindicator,
  librsvg,
  coreutils,
  patchelf,
  autoPatchelfHook,
  wrapGAppsHook3,
  shared-mime-info,
  gsettings-desktop-schemas,
}:
let
  src = fetchFromGitHub {
    owner = "sgtaziz";
    repo = "lian-li-linux";
    rev = "v0.8.7";
    hash = "sha256-OnpXvStAN9YrRzPMgGD7wDyjis7LgPmUnBAy+MOSL3M=";
    fetchSubmodules = true;
  };

  frontend = buildNpmPackage {
    pname = "lianli-linux-frontend";
    version = "0.8.7";

    inherit src;

    sourceRoot = "${src.name}/crates/lianli-gui";

    npmDepsHash = "sha256-p1x1c6NwrpleYXVLUn9ec16Mah+pODLUvLfPEZ36eio=";
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist $out/

      runHook postInstall
    '';
  };
in
rustPlatform.buildRustPackage rec {
  pname = "lianli-linux";
  version = "0.8.7";

  inherit src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    pkg-config
    clang
    llvmPackages.libclang
    cmake
    nasm
    patchelf
    ffmpeg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    libusb1
    udev
    ffmpeg
    linuxPackages.evdi
    fontconfig
    mesa
    libxkbcommon
    wayland
    libX11
    libinput
    libdrm
    glib
    gtk3
    webkitgtk_4_1
    libsoup_3
    libayatana-appindicator
    librsvg
    shared-mime-info
    gsettings-desktop-schemas
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  postPatch = ''
    substituteInPlace packaging/udev/60-lianli.rules \
    --replace-fail "/bin/chmod" "${coreutils}/bin/chmod"
  '';

  preBuild = ''
    mkdir -p "$TMPDIR/evdi-compat"

    ln -s ${linuxPackages.evdi}/lib/libevdi.so \
      "$TMPDIR/evdi-compat/libevdi.so.1"

    export LIBRARY_PATH="$TMPDIR/evdi-compat:${linuxPackages.evdi}/lib:$LIBRARY_PATH"
    export LD_LIBRARY_PATH="$TMPDIR/evdi-compat:${linuxPackages.evdi}/lib:$LD_LIBRARY_PATH"

    # The Tauri build.rs deliberately falls back to an existing dist/
    # when npm isn't available. Pre-build the Vue frontend with Nix.
    rm -rf crates/lianli-gui/dist
    cp -r ${frontend}/dist crates/lianli-gui/dist

    chmod -R u+w crates/lianli-gui/dist
  '';

  buildPhase = ''
    runHook preBuild

    cargo build --release \
      --package lianli-daemon \
      --package lianli-gui

    runHook postBuild
  '';

  installPhase = ''
          install -Dm755 target/release/lianli-daemon \
            $out/bin/lianli-daemon

          install -Dm755 target/release/lianli-gui \
            $out/bin/lianli-gui

            install -Dm644 crates/lianli-gui/src-tauri/icons/32x32.png \
      $out/share/icons/hicolor/32x32/apps/com.sgtaziz.lianlilinux.png

    install -Dm644 crates/lianli-gui/src-tauri/icons/128x128.png \
      $out/share/icons/hicolor/128x128/apps/com.sgtaziz.lianlilinux.png

    install -Dm644 crates/lianli-gui/src-tauri/icons/128x128@2x.png \
      $out/share/icons/hicolor/256x256/apps/com.sgtaziz.lianlilinux.png

    install -Dm644 crates/lianli-gui/src-tauri/icons/icon.png \
      $out/share/icons/hicolor/512x512/apps/com.sgtaziz.lianlilinux.png

    install -Dm644 crates/lianli-gui/src-tauri/icons/icon.svg \
      $out/share/icons/hicolor/scalable/apps/com.sgtaziz.lianlilinux.svg

            # Nixpkgs provides libevdi.so, while lianli-linux expects
        # libevdi.so.1. Provide the expected SONAME inside our package.
        mkdir -p $out/lib

        ln -s ${linuxPackages.evdi}/lib/libevdi.so \
          $out/lib/libevdi.so.1

          install -Dm644 packaging/udev/60-lianli.rules \
            $out/lib/udev/rules.d/60-lianli.rules

          install -Dm644 packaging/systemd/lianli-daemon.service \
            $out/lib/systemd/user/lianli-daemon.service

            install -Dm644 packaging/desktop/com.sgtaziz.lianlilinux.desktop \
      $out/share/applications/com.sgtaziz.lianlilinux.desktop
  '';

  meta = {
    description = "Linux replacement for L-Connect 3";
    homepage = "https://github.com/sgtaziz/lian-li-linux";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
