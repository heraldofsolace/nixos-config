{ inputs, ... }: {
  flake-file.inputs = {
    nixflix = {

      url = "github:kiriwalawren/nixflix";
      inputs.nixpkgs.follows = "latest";

    };
  };
  blazar.media._.nixflix = {
    nixos = { config, ... }: {
      imports = [
        inputs.nixflix.nixosModules.default
      ];
      sops.secrets = let sopsFile = ../../../secrets/nixflix-keys.yaml; in {
        "sonarr/api_key" = { inherit sopsFile; };
        "sonarr/password" = { inherit sopsFile; };
        "radarr/api_key" = { inherit sopsFile; };
        "radarr/password" = { inherit sopsFile; };
        "lidarr/api_key" = { inherit sopsFile; };
        "lidarr/password" = { inherit sopsFile; };
        "prowlarr/api_key" = { inherit sopsFile; };
        "prowlarr/password" = { inherit sopsFile; };
        "indexer-api-keys/DrunkenSlug" = { inherit sopsFile; };
        "indexer-api-keys/NZBFinder" = { inherit sopsFile; };
        "indexer-api-keys/NzbPlanet" = { inherit sopsFile; };
        "jellyfin/alice_password" = { inherit sopsFile; };
        "jellyfin/api_key" = { inherit sopsFile; };
        "seerr/api_key" = { inherit sopsFile; };
        "wireguard/conf" = { inherit sopsFile; };
        "sabnzbd/api_key" = { inherit sopsFile; };
        "sabnzbd/nzb_key" = { inherit sopsFile; };
        "sabnzbd/username" = { inherit sopsFile; };
        "sabnzbd/password" = { inherit sopsFile; };
        "usenet/eweka/username" = { inherit sopsFile; };
        "usenet/eweka/password" = { inherit sopsFile; };
        "usenet/newsgroupdirect/username" = { inherit sopsFile; };
        "usenet/newsgroupdirect/password" = { inherit sopsFile; };
        "navidrome/password" = { inherit sopsFile; };
        "torrent/qbittorrent/password" = { inherit sopsFile; };
      };

      nixflix = {
        enable = true;
        mediaDir = "/data/media";
        stateDir = "/data/.state";
        mediaUsers = [ "aniket" ];

        theme = {
          enable = true;
          name = "catppuccin-mocha";
        };

        # Reverse proxy (choose nginx or caddy, not both)
        nginx = {
          enable = true;
          addHostsEntries = true; # Disable this if you have your own DNS configuration
          domain = "miranda.lan.internal";
        };
        # caddy = {
        #   enable = true;
        #   addHostsEntries = true;
        # };

        postgres.enable = true;

        downloadarr = {
          enable = true;
          qbittorrent = {
            enable = true;
          };
        };

        torrentClients = {
          qbittorrent = {
            enable = true;
            password = config.sops.secrets."torrent/qbittorrent/password".path;
          };
        };

        sonarr = {
          enable = true;
          config = {
            apiKey._secret = config.sops.secrets."sonarr/api_key".path;
            hostConfig.password._secret = config.sops.secrets."sonarr/password".path;
          };
        };

        radarr = {
          enable = true;
          config = {
            apiKey._secret = config.sops.secrets."radarr/api_key".path;
            hostConfig.password._secret = config.sops.secrets."radarr/password".path;
          };
        };

        recyclarr = {
          enable = true;
          cleanupUnmanagedProfiles = {
            enable = true;
          };
        };

        lidarr = {
          enable = true;
          config = {
            apiKey._secret = config.sops.secrets."lidarr/api_key".path;
            hostConfig.password._secret = config.sops.secrets."lidarr/password".path;
          };
        };

        prowlarr = {
          enable = true;
          config = {
            apiKey._secret = config.sops.secrets."prowlarr/api_key".path;
            hostConfig.password._secret = config.sops.secrets."prowlarr/password".path;
            indexers = [
              # {
              #   name = "DrunkenSlug";
              #   apiKey._secret = config.sops.secrets."indexer-api-keys/DrunkenSlug".path;
              # }
              {
                name = "NZBFinder";
                apiKey._secret = config.sops.secrets."indexer-api-keys/NZBFinder".path;
              }
              # {
              #   name = "NzbPlanet";
              #   apiKey._secret = config.sops.secrets."indexer-api-keys/NzbPlanet".path;
              # }
            ];
          };
        };

        usenetClients.sabnzbd = {
          enable = true;

          settings = {
            misc = {
              api_key._secret = config.sops.secrets."sabnzbd/api_key".path;
              nzb_key._secret = config.sops.secrets."sabnzbd/nzb_key".path;
              username._secret = config.sops.secrets."sabnzbd/username".path;
              password._secret = config.sops.secrets."sabnzbd/password".path;
            };

            servers = [
              {
                name = "Eweka";
                host = "sslreader.eweka.nl";
                port = 563;
                username._secret = config.sops.secrets."usenet/eweka/username".path;
                password._secret = config.sops.secrets."usenet/eweka/password".path;
                connections = 20;
                ssl = true;
                priority = 0;
                retention = 3000;
              }
              # {
              #   name = "NewsgroupDirect";
              #   host = "news.newsgroupdirect.com";
              #   port = 563;
              #   username._secret = config.sops.secrets."usenet/newsgroupdirect/username".path;
              #   password._secret = config.sops.secrets."usenet/newsgroupdirect/password".path;
              #   connections = 10;
              #   ssl = true;
              #   priority = 1;
              #   optional = true;
              #   backup = true;
              # }
            ];
          };
        };

        jellyfin = {
          enable = true;
          apiKey._secret = config.sops.secrets."jellyfin/api_key".path;
          users = {
            admin = {
              mutable = false;
              policy.isAdministrator = true;
              password._secret = config.sops.secrets."jellyfin/alice_password".path;
            };
          };
        };

        seerr = {
          enable = true;
          apiKey._secret = config.sops.secrets."seerr/api_key".path;
        };

        navidrome = {
          enable = true;
          users = {
            "Aniket" = {
              # name displayed in the UI
              userName = "aniket"; # username used to login
              isAdmin = true;
              password._secret = config.sops.secrets."navidrome/password".path;
            };
          };
          settings = {
            MusicFolder = "/data/media/music";
          };
        };

        vpn = {
          enable = true;
          wgConfFile = config.sops.secrets."wireguard/conf".path;
          accessibleFrom = [ "192.168.0.0/24" ];
        };
      };
    };
  };
}
