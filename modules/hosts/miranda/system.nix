{
  blazar,
  inputs,
  ...
}:
{
  den.hosts.x86_64-linux.miranda = _: {
    # Hardware survey of the machine miranda actually is, taken from the
    # running system over `ssh aniket@192.168.0.4` with the command named
    # next to each fact. The string below said "NixOS workstation", which
    # was wrong on both counts: this is a desktop tower doing server duty,
    # not a workstation like andromeda or horologium.
    #
    # Form factor - `hostnamectl` reports Icon name `computer-desktop` and
    # Chassis `desktop`; `/sys/class/dmi/id/chassis_type` is 3 (desktop).
    # Board - `hostnamectl`: Hardware Vendor ASUS, Model ROG STRIX B550-A
    # GAMING, firmware 2006 dated 2021-03-19.
    # CPU - `lscpu`: AMD Ryzen 7 5800X 8-Core Processor, 16 CPUs, 2 threads
    # per core, 8 cores per socket, 1 socket, L3 32 MiB (1 instance), L2
    # 4 MiB (8 instances).
    # RAM - `free -h`: 31Gi total memory and 59Gi of swap on nvme0n1p2.
    # GPU - `lspci -nn`: Navi 23 [Radeon RX 6600/6600 XT/6600M] [1002:73ff]
    # with its Navi 21/23 HDMI/DP audio controller [1002:ab28]; the only GPU
    # in the box. VRAM from `mem_info_vram_total` is 8573157376 bytes
    # (~8 GiB). sysfs only names the family, so the SKU is not guessed at.
    # Storage - `lsblk -o NAME,SIZE,MODEL,TYPE,FSTYPE,MOUNTPOINTS` and
    # `df -h`: plain ext4, no ZFS and no pool layout, unlike andromeda.
    # nvme0n1 953.9G XPG GAMMIX S11 Pro holds p1 893.8G ext4 mounted at both
    # `/` and `/nix/store` (43% full), p2 59.6G swap, p3 487M vfat
    # `/boot/efi`; sda 1.8T ST2000DM008-2FR102 holds one ext4 partition
    # bind-mounted at `/mnt/storage`, `/data` and `/var/lib/nextcloud` (30%
    # full). `lspci -nn` names the NVMe controller as ADATA XPG SX8200 Pro
    # [1cc1:8201]; the model string above is the disk's own.
    # Network - `lspci -nn` and `ip -br addr`: Intel I225-V 2.5GbE (enp9s0)
    # at 192.168.0.4, Tailscale (tailscale0, 100.96.77.9), a WireGuard
    # bridge wg-br 192.168.15.5 with a veth-wg-br peer, vboxnet0, and wlan0
    # present but down (iwd runs, but no Wi-Fi radio appears in `lspci`).
    # OS - `hostnamectl`: NixOS 26.05 (Yarara) on kernel 6.18.50, the
    # mainline kernel, not the cachyos kernel andromeda runs.
    # Role - this is the fleet's server, not a workstation. `systemctl
    # list-units --type=service --state=running` and `ss -lnt` show nginx
    # on 0.0.0.0:80 and :443 fronting plex, jellyfin, the sonarr/radarr/
    # lidarr/prowlarr/sabnzbd/qbittorrent/seerr stack, navidrome,
    # phpfpm-nextcloud with redis-nextcloud and postgresql on :5432, the
    # onlyoffice-docservice/converter pair over rabbitmq, and ollama on
    # :11434 behind open-webui on :8000, all alongside tailscaled and
    # ivpn-service.
    description = "NixOS server in a desktop tower - ASUS ROG STRIX B550-A GAMING - Ryzen 7 5800X, 31 GiB RAM, 8 GiB Navi 23 Radeon, a 953G XPG NVMe root on ext4 plus a 1.8T Seagate HDD, fronting the fleet's media, Nextcloud and Ollama stacks through nginx";
    users.aniket = {
      description = "Aniket";
      userNameNick = "Aniket";
      userNameReal = "Aniket Bhattacharyea";
      classes = [
        "homeManager"
      ];
    };

    users.hass = {
      description = "Home Assistant";
      userNameNick = "hass";
      userNameReal = "Home Assistant";
    };

    users.nextcloud = {
      description = "Nextcloud";
      userNameNick = "nextcloud";
      userNameReal = "Nextcloud";
    };

    users.nginx = {
      description = "Nginx";
      userNameNick = "nginx";
      userNameReal = "Nginx";
    };

    # users.root = {
    #   description = "Root";
    #   userNameNick = "root";
    #   userNameReal = "Root";
    #   uid = 0;
    #   home = lib.mkForce "/root";
    #   # passwordFile = config.sops.secrets.root-password.path;
    #   hashedPassword = "$6$z0zrqUB8GGXrbGo/$JEeOmM3VRn3zs9cuOXOzl5eU1YQlt1xaSqtv33cftqIsgK0MZQYET8a.oiGuWY9d32t5CX4CB3bNQNDUHmHQj0";
    # };
  };

  den.aspects.miranda = {
    nixos = { pkgs, ... }: {
      imports = [
        ./_hardware-configuration.nix
        inputs.disko.nixosModules.disko
        ./_disko.nix
      ];

      # The cert used to be a one-shot `tailscale cert` run baked into
      # sops; it expired silently (Tailscale certs are ~90 days) since
      # nothing ever renewed it. Generate it live via a timer instead,
      # straight from tailscaled's local API - no secret to rotate.
      systemd.tmpfiles.rules = [
        "d /var/lib/tailscale-certs 0750 root nginx -"
      ];

      systemd.services.tailscale-cert-renew = {
        description = "Renew the Tailscale TLS cert for miranda.dorper-ghost.ts.net";
        after = [ "tailscaled.service" ];
        requires = [ "tailscaled.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "tailscale-cert-renew" ''
            set -euo pipefail
            ${pkgs.tailscale}/bin/tailscale cert \
              --cert-file /var/lib/tailscale-certs/miranda.crt \
              --key-file /var/lib/tailscale-certs/miranda.key \
              miranda.dorper-ghost.ts.net
            chown root:nginx /var/lib/tailscale-certs/miranda.key
            chmod 640 /var/lib/tailscale-certs/miranda.key
            chmod 644 /var/lib/tailscale-certs/miranda.crt
          '';
          # No-op if nginx isn't up yet (first boot); on later timer-driven
          # renewals this picks up the fresh cert without dropping conns.
          ExecStartPost = "${pkgs.systemd}/bin/systemctl try-reload-or-restart nginx.service";
        };
      };

      systemd.timers.tailscale-cert-renew = {
        description = "Periodic renewal check for the Tailscale TLS cert";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };

      # Tailscale's MagicDNS (100.100.100.100) doesn't resolve a node's
      # own hostname when queried from itself - only from other tailnet
      # peers. Nextcloud's onlyoffice connectivity check runs locally on
      # miranda and needs this to work, so override it here.
      networking.hosts."127.0.0.1" = [ "miranda.dorper-ghost.ts.net" ];

      # nginx's ssl_certificate* paths must exist before it starts.
      systemd.services.nginx = {
        after = [ "tailscale-cert-renew.service" ];
        requires = [ "tailscale-cert-renew.service" ];
      };

      # stylix.enable = lib.mkForce false;

      boot.loader.efi.efiSysMountPoint = "/boot/efi";
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.grub.enable = true;
      boot.loader.grub.copyKernels = true;
      boot.loader.grub.efiSupport = true;
      boot.loader.grub.device = "nodev";

      environment = {
        variables = {
          EDITOR = "vim";
        };
      };

      networking.interfaces.enp9s0.wakeOnLan.enable = true;
      networking.hostName = "miranda";
      services = {
        openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
        };
      };

      security.polkit.enable = true;
      services.avahi.hostName = "miranda";
    };

    includes = with blazar; [
      stylix
      determinate-nix
      media._.plex
      # media._.jellyfin
      database._.postgresql
      utils._.nextcloud
      # plasma
    ];
  };
}
