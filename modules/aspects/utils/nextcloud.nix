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
          owner = "onlyoffice";
        };
        sops.secrets.onlyoffice-jwt-secret = {
          key = "onlyoffice-jwt-secret";
          sopsFile = ../../../secrets/keys.yaml;
          owner = "onlyoffice";
        };
        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud33;
          hostName = "miranda.dorper-ghost.ts.net";
          https = true;
          enableImagemagick = true;
          database.createLocally = true;
          appstoreEnable = true;
          autoUpdateApps.enable = true;
          settings = {
            trusted_domains = [ "miranda.dorper-ghost.ts.net" ];
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
              richdocuments
              spreed
              ;
          };
          extraAppsEnable = true;
          globalProfiles = true;
          maxUploadSize = "5G";
          notify_push.enable = true;
          configureRedis = true;
        };

        services.onlyoffice = {
          enable = true;
          hostname = "onlyoffice.miranda.dorper-ghost.ts.net";
          securityNonceFile = "/run/secrets/onlyoffice-nonce-file";
          jwtSecretFile = "/run/secrets/onlyoffice-jwt-secret";
        };

        services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
          forceSSL = true;
          sslCertificate = "/run/secrets/miranda-cert";
          sslCertificateKey = "/run/secrets/miranda-cert-key";
        };

        services.nginx.virtualHosts.${config.services.onlyoffice.hostname} = {
          forceSSL = true;
          sslCertificate = "/run/secrets/miranda-cert";
          sslCertificateKey = "/run/secrets/miranda-cert-key";
        };
      };
  };
}
