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
          # Every app we use is pinned via extraApps below; leaving the App
          # Store enabled lets Nextcloud's own `occ upgrade` self-fetch
          # "updates" for those same apps into the writable store-apps/
          # dir, which then collides with the Nix-provided copy (duplicate
          # composer autoloader class declarations crash the upgrade).
          appstoreEnable = false;
          autoUpdateApps.enable = false;
          settings = {
            trusted_domains = [ "miranda.dorper-ghost.ts.net" ];
            default_phone_region = "IN";
            "profile.enabled" = true;
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
            adminpassFile = config.sops.secrets.nextcloud-password.path;
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
          maxUploadSize = "5G";
          # notify_push.enable = true;
          configureRedis = true;
        };

        # Not a real DNS name - just an internal label for the
        # services.nginx.virtualHosts attribute below. The actual
        # serverName/listen port are overridden there so this vhost
        # doesn't merge with nextcloud's (which shares the real
        # hostname, miranda.dorper-ghost.ts.net, on port 443).
        services.onlyoffice = {
          enable = true;
          hostname = "onlyoffice-internal";
          securityNonceFile = config.sops.secrets.onlyoffice-nonce-file.path;
          jwtSecretFile = config.sops.secrets.onlyoffice-jwt-secret.path;
        };

        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
          8443
          # nextcloud's virtualHost below needs 443; onlyoffice's needs
          # 8444. Both scoped to tailscale0 to match nextcloud's own
          # privacy posture rather than opening them globally.
          443
          8444
        ];

        services.nginx.validateConfigFile = false;
        services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
          forceSSL = true;
          sslCertificate = "/var/lib/tailscale-certs/miranda.crt";
          sslCertificateKey = "/var/lib/tailscale-certs/miranda.key";
        };

        # onlyoffice.abhattacharyea.dev never had a real DNS record
        # pointing anywhere, which broke Nextcloud's connectivity check.
        # Serve it under the same Tailscale-only hostname/cert nextcloud
        # already uses instead, on its own port, rather than depending on
        # a custom domain + Cloudflare DNS-01 ACME cert for a service
        # that's tailnet-only anyway.
        services.nginx.virtualHosts.${config.services.onlyoffice.hostname} = {
          serverName = "miranda.dorper-ghost.ts.net";
          listen = [
            {
              addr = "0.0.0.0";
              port = 8444;
              ssl = true;
            }
            {
              addr = "[::0]";
              port = 8444;
              ssl = true;
            }
          ];
          sslCertificate = "/var/lib/tailscale-certs/miranda.crt";
          sslCertificateKey = "/var/lib/tailscale-certs/miranda.key";
        };
      };
  };
}
