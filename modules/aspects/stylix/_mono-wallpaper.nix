# Shared monochrome wallpaper helper (leading underscore: ignored by
# import-tree, imported explicitly by hyprland.nix and stylix.nix).
#
# `ramp` builds a 16-step blue-grey ramp, linearly interpolated per RGB
# channel from base00 to base07 of a Stylix palette, so it tracks the scheme.
# `convertDir` / `convertFile` recolour images with gowall using that ramp as
# the theme, so every consumer shares the exact same step.
{ lib }:
let
  hexToInt = s: (builtins.fromTOML "x = 0x${s}").x;
  channel = hex: offset: hexToInt (builtins.substring offset 2 hex);
  toHex2 = v: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString v));
in
rec {
  steps = 16;

  # colors: config.lib.stylix.colors (hex without leading #).
  # value = c0 + (c1 - c0) * i / 15, rounded half up, per channel.
  ramp =
    colors:
    let
      from = colors.base00;
      to = colors.base07;
      lerp =
        offset: i:
        let
          c0 = channel from offset;
          c1 = channel to offset;
          # Numerator is always >= 0, so integer division floors it.
          num = 2 * (15 * c0 + (c1 - c0) * i) + 15;
        in
        num / 30;
    in
    builtins.genList (i: "#${toHex2 (lerp 0 i)}${toHex2 (lerp 2 i)}${toHex2 (lerp 4 i)}") steps;

  themeFile =
    pkgs: colors:
    pkgs.writeText "stylix.json" (
      builtins.toJSON {
        name = "stylix";
        colors = ramp colors;
      }
    );

  # Convert every image in `directory`; output is a directory of PNGs with the
  # same file names. gowall's --dir mode loads the theme JSON from one goroutine
  # per image and dies intermittently with "fatal error: concurrent map writes"
  # (seen on this 24-image directory), so feed it one image at a time.
  convertDir =
    pkgs: colors: directory:
    pkgs.runCommand "generate-wallpapers" { buildInputs = [ pkgs.gowall ]; } ''
      export HOME=$(mktemp -d)
      mkdir -p $out
      for img in ${directory}/*; do
        rm -rf in
        mkdir in
        cp "$img" in/
        gowall convert --dir in -t ${themeFile pkgs colors} --output $out
      done
    '';

  # Convert a single image; output is the converted PNG itself.
  convertFile =
    pkgs: colors: name: file:
    pkgs.runCommand name { buildInputs = [ pkgs.gowall ]; } ''
      export HOME=$(mktemp -d)
      mkdir -p in out
      cp ${file} in/${name}
      gowall convert --dir in -t ${themeFile pkgs colors} --output out
      cp out/${name} $out
    '';
}
