{blazar, ...}: {
  blazar.media = {
    description = "Media";

    nixos = {lib, ...}: {
      services.speechd.enable = lib.mkForce false;
      services.orca.enable = lib.mkForce false;
    };

    provides.console = {
      description = "Media for a console environment.";
      homeManager = {pkgs, ...}: {
        home.packages = with pkgs; [
          ffmpeg-full
          yt-dlp
          # exiftool
        ];
      };
    };

    provides.desktop = {
      description = "Media for a desktop environment.";
      homeManager = {pkgs, ...}: {
        home.packages = with pkgs; [
          mpv
          vlc

          tartube-yt-dlp

          nuclear
          shortwave
        ];

        services.easyeffects.enable = true;

        programs.freetube = {
          enable = true;
          #settings = {};
        };
      };
      includes = [
        blazar.media._.console
      ];
    };
  };
}
