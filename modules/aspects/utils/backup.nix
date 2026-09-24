{
  blazar.utils._.backup = {
    nixos =
      { config, pkgs, ... }:
      {
        sops.secrets.restic-repo-password = {
          key = "restic-repo-password";
          sopsFile = ../../../secrets/keys.yaml;
        };

        services.restic.backups.miranda = {
          # PLACEHOLDER: a local path protects against accidental deletion/
          # corruption but not disk/hardware loss. Point this at a real
          # offsite target (Backblaze B2, andromeda over tailscale, etc.)
          # once decided - everything else here is ready to go as-is.
          repository = "/var/backups/restic-repo";
          passwordFile = config.sops.secrets.restic-repo-password.path;
          initialize = true;

          paths = [
            # config.php (with its encryption keys) lives alongside the data
            # here, so the whole directory - not just data/ - is needed for
            # a working restore.
            "/var/lib/nextcloud"
            "/var/backups/postgres-dump"
          ];

          # pg_dumpall as root relies on postgresql.nix's current pg_hba.conf
          # `trust` policy for local connections.
          backupPrepareCommand = ''
            mkdir -p /var/backups/postgres-dump
            ${config.services.postgresql.package}/bin/pg_dumpall > /var/backups/postgres-dump/dump.sql
            nextcloud-occ maintenance:mode --on
          '';
          backupCleanupCommand = ''
            nextcloud-occ maintenance:mode --off
          '';

          timerConfig = {
            OnCalendar = "08:00";
            Persistent = true;
          };

          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 4"
            "--keep-monthly 6"
          ];
        };

        environment.systemPackages = [ pkgs.restic ];
      };
  };
}
