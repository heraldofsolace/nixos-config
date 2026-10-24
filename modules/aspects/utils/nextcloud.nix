_: {
  blazar.utils._.nextcloud = {
    nixos =
      {
        lib,
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
            # Defaults to http://localhost for any URL generated outside
            # a real HTTP request (occ, cron, the onlyoffice document
            # service's download callback) - that doesn't match any
            # nginx vhost here, so those downloads just hang.
            "overwrite.cli.url" = "https://miranda.dorper-ghost.ts.net";
            overwriteprotocol = "https";
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
          # Nextcloud's own hostname resolves to its Tailscale address
          # (100.64.0.0/10), which the docservice's request-filtering
          # agent treats as a private IP and refuses to fetch from by
          # default - exactly where it needs to download documents from.
          allowLocalConnections = true;
        };

        # storage.externalHost isn't exposed as a module option. Without
        # it, the docservice assumes the standard port when building the
        # result URLs it hands back to Nextcloud (e.g. /cache/files/...),
        # so they come back missing :8444 and 404 against nextcloud's own
        # vhost instead. mkAfter guarantees this runs after the module's
        # own prestart populates the file, so it's there to patch.
        systemd.services.onlyoffice-docservice.serviceConfig.ExecStartPre = lib.mkAfter [
          (pkgs.writeShellScript "onlyoffice-external-host-patch" ''
            set -euo pipefail
            ${pkgs.jq}/bin/jq \
              --arg host "https://miranda.dorper-ghost.ts.net:8444" \
              '.storage.externalHost = $host' \
              /run/onlyoffice/config/default.json | ${pkgs.moreutils}/bin/sponge /run/onlyoffice/config/default.json
          '')
        ];

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
          # nginx's module only emits ssl_certificate when one of
          # onlySSL/addSSL/forceSSL is set - a manual listen.*.ssl = true
          # alone isn't enough. No plain-HTTP listener here, so onlySSL.
          onlySSL = true;
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
          # The onlyoffice module's own vhost config forwards
          # X-Forwarded-Host as nginx's $host, which strips the port.
          # The docservice trusts that header to build the result URLs
          # it hands back to Nextcloud (e.g. /cache/files/...), so
          # without the port those requests fall back to 443 - which is
          # nextcloud's vhost, not this one - and 404. $http_host keeps
          # the port; mkAfter guarantees this line wins (nginx uses
          # last-directive-wins for repeated proxy_set_header).
          extraConfig = lib.mkAfter ''
            proxy_set_header X-Forwarded-Host $http_host;
          '';
        };
      };
  };
}
