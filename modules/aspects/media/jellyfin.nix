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
        hardwareAcceleration = {
          enable = true;
          device = "/dev/dri/by-path/pci-0000:0c:00.0-render";
          type = "vaapi";
        };
      };
    };
  };
}
