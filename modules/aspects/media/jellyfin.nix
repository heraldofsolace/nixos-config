_: {
  blazar.media._.jellyfin = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.jellyfin
        pkgs.jellyfin-web
        pkgs.jellyfin-ffmpeg
      ];
      services.jellyfin = {
        enable = true;
        openFirewall = true;
      };
    };
  };
}
