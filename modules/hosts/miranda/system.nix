{
  blazar,
  ...
}:
{
  den.hosts.x86_64-linux.miranda = _: {
    description = "NixOS workstation for Work notebook Lenovo ThinkPad T14 Gen 4 Ryzen";
    users.aniket = {
      description = "Aniket";
      userNameNick = "Aniket";
      userNameReal = "Aniket Bhattacharyea";
      classes = [
        "homeManager"
      ];
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
    nixos = { ... }: {
      imports = [
        ./_hardware-configuration.nix
      ];

      sops.secrets.miranda-cert = {
        key = "miranda-cert";
        sopsFile = ../../../secrets/keys.yaml;
        owner = "nginx";
      };

      sops.secrets.miranda-cert-key = {
        key = "miranda-cert-key";
        sopsFile = ../../../secrets/keys.yaml;
        owner = "nginx";
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

      # networking.interfaces.enp6s0.wakeOnLan.enable = true;
      networking.hostName = "miranda";
      services = {
        openssh = {
          enable = true;
          settings.PermitRootLogin = "no";
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
      media._.jellyfin
      database._.postgresql
      utils._.nextcloud
      # plasma
    ];
  };
}
