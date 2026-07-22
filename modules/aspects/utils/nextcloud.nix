_: {
  blazar.utils._.nextcloud = {
    nixos =
      {
        pkgs,
        config,
        ...
      }:
      {
        sops.secrets.nextcloud-password = {
          key = "nextcloud";
          sopsFile = ../../../secrets/user-passwords.yaml;
          owner = "nextcloud";
        };
        sops.secrets.onlyoffice-nonce-file = {
          key = "onlyoffice-nonce-file";
          sopsFile = ../../../secrets/keys.yaml;
          group = "onlyoffice";
          mode = "0440";
        };
        sops.secrets.onlyoffice-jwt-secret = {
          key = "onlyoffice-jwt-secret";
          sopsFile = ../../../secrets/keys.yaml;
          group = "onlyoffice";
          mode = "0440";
        };
        environment.systemPackages = with pkgs; [
          nodejs
          ffmpeg
        ];
        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud34;
          hostName = "miranda.dorper-ghost.ts.net";
          https = true;
          enableImagemagick = true;
          database.createLocally = true;
          appstoreEnable = true;
          autoUpdateApps.enable = false;
          settings = {
            trusted_domains = [ "miranda.dorper-ghost.ts.net" ];
            enabledPreviewProviders = [
              "OC\\Preview\\BMP"
              "OC\\Preview\\GIF"
              "OC\\Preview\\JPEG"
              "OC\\Preview\\Krita"
              "OC\\Preview\\MarkDown"
              "OC\\Preview\\MP3"
              "OC\\Preview\\OpenDocument"
              "OC\\Preview\\PNG"
              "OC\\Preview\\TXT"
              "OC\\Preview\\XBitmap"
              "OC\\Preview\\HEIC"
            ];
          };
          config = {
            dbtype = "pgsql";
            adminpassFile = "/run/secrets/nextcloud-password";
            defaultPhoneRegion = "IN";
          };
          extraApps = with config.services.nextcloud.package.packages.apps; {
            inherit
              news
              contacts
              calendar
              tasks
              bookmarks
              notes
              deck
              mail
              twofactor_webauthn
              end_to_end_encryption
              memories
              music
              onlyoffice
              previewgenerator
              recognize
              richdocuments
              spreed
              ;
            # recognize = pkgs.fetchNextcloudApp {
            #   hash = "sha256-x3LXZKDWmzCYLTaNqSvgu4Gvrn6w2c/jifNCx1oaw1U=";
            #   url = "https://github.com/nextcloud/recognize/releases/download/v11.0.1/recognize-11.0.1.tar.gz";
            #   license = "agpl3Only";
            # };
          };
          extraAppsEnable = true;
          globalProfiles = true;
          maxUploadSize = "5G";
          # notify_push.enable = true;
          configureRedis = true;
        };

        services.onlyoffice = {
          enable = true;
          hostname = "miranda.dorper-ghost.ts.net";
          port = 8080;
          securityNonceFile = "/run/secrets/onlyoffice-nonce-file";
          jwtSecretFile = "/run/secrets/onlyoffice-jwt-secret";
        };

        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
          8443
        ];

        services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
          forceSSL = true;
          sslCertificate = "/run/secrets/miranda-cert";
          sslCertificateKey = "/run/secrets/miranda-cert-key";
        };

        services.nginx.virtualHosts.${config.services.onlyoffice.hostname} = {
          serverAliases = [
            "miranda.dorper-ghost.ts.net"
          ];
          listen = [
            {
              addr = "0.0.0.0";
              port = 8443;
              ssl = true;
              extraParameters = [ "default_server" ];
            }
          ];
          forceSSL = true;
          sslCertificate = "/run/secrets/miranda-cert";
          sslCertificateKey = "/run/secrets/miranda-cert-key";
        };
      };
  };
}
