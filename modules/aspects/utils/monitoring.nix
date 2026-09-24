_: {
  blazar.utils._.monitoring = {
    nixos = _: {
      services.gatus = {
        enable = true;
        # Tailscale-only, matching nextcloud/onlyoffice's own exposure in
        # utils/nextcloud.nix, rather than opening it more broadly.
        openFirewall = false;
        settings = {
          web.port = 8081;
          endpoints = [
            {
              name = "nextcloud";
              url = "https://miranda.dorper-ghost.ts.net";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "onlyoffice";
              url = "https://onlyoffice.abhattacharyea.dev/healthcheck";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "sonarr";
              url = "http://sonarr.miranda";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "radarr";
              url = "http://radarr.miranda";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "lidarr";
              url = "http://lidarr.miranda";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "prowlarr";
              url = "http://prowlarr.miranda";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "sabnzbd";
              url = "http://sabnzbd.miranda";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "qbittorrent";
              url = "http://qbittorrent.miranda";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "seerr";
              url = "http://seerr.miranda";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "navidrome";
              url = "http://navidrome.miranda";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "plex";
              url = "http://localhost:32400/identity";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "ollama";
              url = "http://localhost:11434";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
            {
              name = "open-webui";
              url = "http://localhost:8080/health";
              interval = "2m";
              conditions = [ "[STATUS] == 200" ];
            }
          ];
        };
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8081 ];
    };
  };
}
