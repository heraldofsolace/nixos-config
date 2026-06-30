{ lib
, git
, stdenv
, fetchFromGitHub
, pkg-config
, meson
, ninja
, gtk-doc
, docbook-xsl-nons
, docbook_xml_dtd_43
, gobject-introspection
, cmake
, openssl
, doctest
, opencv
, gusb
, pixman
, glib
, nss
, cairo
, libgudev
,
}: stdenv.mkDerivation {
  pname = "libfprint-goodixtls-55x4";
  version = "1.0";
  # branch: 55b4-experimental

  src = fetchFromGitHub {
    owner = "TheWeirdDev";
    repo = "libfprint";
    rev = "d1ca62a801aa565e67d1a2a47aaa7a33232b7990";
    sha256 = "";
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

  mesonFlags = [
    "-Ddoc=false"
    "--buildtype=release"
    "--prefix=usr/"
  ];

  meta = with lib; {
    description = "libfprint fork for goodixtls 55x4 devices (supports 55b4, 55a4 support planned)";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
    homepage = "https://github.com/TheWeirdDev/libfprint";
  };
}
