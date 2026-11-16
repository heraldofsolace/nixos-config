{ inputs, ... }:
{
  blazar.games.nixos =
    { pkgs, ... }:
    let
      # Same nixpkgs snapshot hardware.graphics.package (hyprland.nix) and
      # games.nix's extraPackages pull mesa/vulkan-loader from. mesa and
      # vulkan-loader specifically need to stay off the main pkgs set here
      # for the same reason as there: mesa's radv ICD needs a glibc newer
      # than stable's, so a stable-linked vulkan-loader can't dlopen it
      # (GLIBC_2.44 not found) - see games.nix's hardware.graphics comment
      # for how this was confirmed. The rest of this list is unaffected,
      # left on the main pkgs set.
      pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          alsa-lib
          at-spi2-atk
          at-spi2-core
          atk
          cairo
          cups
          curl
          dbus
          expat
          fontconfig
          freetype
          fuse3
          gdk-pixbuf
          glib
          gtk3
          icu
          libGL
          libappindicator-gtk3
          libdrm
          libglvnd
          libnotify
          libpulseaudio
          libunwind
          libusb1
          libuuid
          libxkbcommon
          libxml2
          libgbm
          pkgs-unstable.mesa
          nspr
          nss
          openssl
          pango
          pipewire
          stdenv.cc.cc
          systemd
          pkgs-unstable.vulkan-loader
          # libX11
          # libXScrnSaver
          # libXcomposite
          # libXcursor
          # libXdamage
          # libXext
          # libXfixes
          # libXi
          # libXrandr
          # libXrender
          # libXtst
          # libxcb
          # libxkbfile
          # libxshmfence
          zlib
        ];
      };
    };
}
