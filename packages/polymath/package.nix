{
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  wmctrl,
  gtk3,
  libayatana-appindicator,
  libdbusmenu,
  libsecret,
  openssl,
  libva,
  libvdpau,
  wayland,
  libwebp,
  libxkbcommon,
  libxml2_13,
  zlib,
  alsa-lib,
  libusb1,
  libpulseaudio,
  librsvg,
  fontconfig,
  freetype,
  fribidi,
  libpng,
  mesa,
  libdrm,
  libGL,
  krb5,
  gnutls,
  runtimeShell,
  libgcrypt,
  libgpg-error,
  nettle,
  libbsd,
  xz,
  systemd,
  libx11,
  libxcb,
  libxext,
  libxinerama,
  libxrandr,
  libxscrnsaver,
  libxv,
  libxpresent,
  fetchurl,
  dbus,
  curl,
  xprop,
  gnugrep,
  coreutils,
}:
stdenv.mkDerivation rec {
  pname = "polymath";
  version = "1.4.5.8";

  src = fetchurl {
    url = "https://fluxkeyboard.com/updates/polymath/linux/deb/polymath_${version}_amd64.deb";
    sha256 = "sha256-gp4wxzNUIl5pnY8LcJp2Tl3ZXoQk7PfVXk1Ctu3G2wg=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libayatana-appindicator
    libdbusmenu
    libsecret
    openssl
    libva
    libvdpau
    wayland
    libwebp
    libxkbcommon
    libxml2_13
    zlib
    alsa-lib
    libusb1
    libpulseaudio
    librsvg
    fontconfig
    freetype
    fribidi
    libpng
    mesa
    libdrm
    libGL
    krb5
    gnutls
    libgcrypt
    libgpg-error
    nettle
    libbsd
    xz
    systemd
    stdenv.cc.cc.lib
    libx11
    libxcb
    libxext
    libxinerama
    libxrandr
    libxscrnsaver
    libxv
    libxpresent
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  # Keep the Flutter app's bundle (polymath binary, data/, lib/, bin/,
  # waylandMonitors/) together exactly as shipped: the executable locates
  # its assets and helper tools via paths relative to itself, so the
  # directory layout must be preserved verbatim.
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt"
    cp -r opt/polymath "$out/opt/polymath"

    for script in $out/opt/polymath/waylandMonitors/*/*.sh; do
      substituteInPlace "$script" \
        --replace-fail "#!/bin/bash" "#!${runtimeShell}"
    done

    install -Dm644 usr/share/applications/com.fluxkeyboard.polymath.desktop \
      "$out/share/applications/com.fluxkeyboard.polymath.desktop"
    install -Dm644 usr/share/pixmaps/polymath.png \
      "$out/share/pixmaps/polymath.png"
    install -Dm644 etc/udev/rules.d/99-flux-keyboard.rules \
      "$out/lib/udev/rules.d/99-flux-keyboard.rules"
    install -Dm644 etc/polkit-1/rules.d/10-rpi-rp2-mount.rules \
      "$out/share/polkit-1/rules.d/10-rpi-rp2-mount.rules"

    substituteInPlace "$out/share/applications/com.fluxkeyboard.polymath.desktop" \
      --replace-fail "Exec=/opt/polymath/polymath" "Exec=$out/bin/polymath" \
      --replace-fail "Icon=/usr/share/pixmaps/polymath.png" "Icon=$out/share/pixmaps/polymath.png"

    mkdir -p "$out/bin"
    # Dart's UsbManager dlopen()s linux.x64.libusb-1.0.so by bare filename at
    # runtime (not a build-time DT_NEEDED entry autoPatchelfHook would catch),
    # so it never resolves unless the plugin dir is on LD_LIBRARY_PATH -
    # normally set by the vendor's own launcher script, which makeWrapper replaces.
    # ProcessEnumerationLinux shells out to wmctrl for window/process
    # enumeration (app-based profile switching); not a declared dependency
    # of the .deb, so it's silently absent unless provided explicitly here.
    makeWrapper "$out/opt/polymath/polymath" "$out/bin/polymath" \
      --prefix LD_LIBRARY_PATH : "$out/opt/polymath/lib" \
      --prefix PATH : "${
        lib.makeBinPath [
          coreutils
          gnugrep
          xprop
          curl
          dbus
          libsecret
          wmctrl
        ]
      }"

    runHook postInstall
  '';

  autoPatchelfIgnoreMissing = [
    "libmfx.so.1"
    "libOpenCL.so.1"
  ];

  meta = {
    description = "Advanced keyboard layout customization tool for Flux keyboards";
    homepage = "https://fluxkeyboard.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "polymath";
  };
}
