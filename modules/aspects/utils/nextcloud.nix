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
              ;
          };
          extraAppsEnable = true;
          globalProfiles = true;
          maxUploadSize = "5G";
          notify_push.enable = true;
          configureRedis = true;
        };

        services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
          forceSSL = true;
          sslCertificate = "/run/secrets/miranda-cert";
          sslCertificateKey = "/run/secrets/miranda-cert-key";
        };
      };
  };
}
