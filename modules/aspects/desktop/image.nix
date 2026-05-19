{
  blazar.desktop._.image = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        gimp
        imagemagick
        inkscape
      ];
    };
  };
}
