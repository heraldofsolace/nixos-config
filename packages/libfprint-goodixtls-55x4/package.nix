{
  lib,
  git,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  meson,
  ninja,
  gtk-doc,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  gobject-introspection,
  cmake,
  openssl,
  doctest,
  opencv,
  gusb,
  pixman,
  glib,
  nss,
  cairo,
  libgudev,
}:
stdenv.mkDerivation {
  pname = "libfprint-goodixtls-55x4";
  version = "1.1";
  # branch: 55b4-experimental
  outputs = [
    "out"
  ];
  src = fetchFromGitHub {
    owner = "TheWeirdDev";
    repo = "libfprint";
    rev = "d1ca62a801aa565e67d1a2a47aaa7a33232b7990";
    sha256 = "sha256-EbFvsfl3ry6jrwFNhXVFCoqWz4TDj1UX0GcuVRVmd2M=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    gobject-introspection
    cmake # for finding doctest
  ];

  buildInputs = [
    git
    gusb
    pixman
    glib
    nss
    cairo
    libgudev
    doctest
    opencv
    openssl
  ];
  enableParallelBuilding = true;

  postPatch = ''
    patchShebangs \
      tests/test-runner.sh \
      tests/unittest_inspector.py \
      tests/virtual-image.py \
      tests/umockdev-test.py \
      tests/test-generated-hwdb.sh
    mkdir -p $out/include/libfprint-2
    cp -r libfprint/sigfm $out/include/libfprint-2
  '';

  mesonFlags = [
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    # Include virtual drivers for fprintd tests
    "-Ddrivers=default"
    "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
  ];

  # installPhase = ''
  #   mkdir -p "$out/lib/udev/rules.d/"
  # '';

  meta = with lib; {
    description = "libfprint fork for goodixtls 55x4 devices (supports 55b4, 55a4 support planned)";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
    homepage = "https://github.com/TheWeirdDev/libfprint";
  };
}
