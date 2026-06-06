{blazar, ...}: {
  den.hosts.x86_64-linux.horologium = _: {
    description = "NixOS workstation for Work notebook Lenovo ThinkPad T14 Gen 4 Ryzen";
    users.aniket = {
      description = "Aniket";
      userNameNick = "Aniket";
      userNameReal = "Aniket Bhattacharyea";
      classes = ["homeManager" "hjem" "maid"];
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

  den.aspects.horologium = {
    nixos = {pkgs, ...}: {
      imports = [
        ./_hardware-configuration.nix
      ];

      # Enable swap on luks
      boot.initrd.luks.devices."luks-ac0722b1-35f7-4b31-a215-942322657a7c".device = "/dev/disk/by-uuid/ac0722b1-35f7-4b31-a215-942322657a7c";
      boot.initrd.luks.devices."luks-ac0722b1-35f7-4b31-a215-942322657a7c".keyFile = "/crypto_keyfile.bin";

      boot.loader.efi.efiSysMountPoint = "/boot/efi";
      boot.loader.grub.enable = true;
      boot.loader.grub.copyKernels = true;
      boot.loader.grub.efiSupport = true;
      boot.loader.grub.enableCryptodisk = true;
      boot.loader.grub.efiInstallAsRemovable = true;
      boot.loader.grub.device = "nodev";

      environment = {
        variables = {
          EDITOR = "vim";
        };
        systemPackages = with pkgs; [
          maliit-keyboard
          maliit-framework
          brightnessctl
        ];
      };

      # networking.interfaces.enp6s0.wakeOnLan.enable = true;
      networking.hostName = "horologium";
      services = {
        geoclue2.enable = true;
        gnome.gnome-keyring.enable = true;
        xserver = {
          enable = true;
          wacom.enable = true;
          videoDrivers = ["amdgpu"];
        };
        gvfs.enable = true;
        openssh = {
          enable = true;
          settings.PermitRootLogin = "no";
          settings.PasswordAuthentication = false;
        };
      };

      security.polkit.enable = true;
      services.avahi.hostName = "horologium";

      # Install the driver
      services.fprintd.enable = true;
      # If simply enabling fprintd is not enough, try enabling fprintd.tod...
      services.fprintd.tod.enable = true;
      # ...and use one of the next four drivers
      services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix; # Goodix driver module
      system.stateVersion = "25.11";
    };

    includes = with blazar; [
      stylix
      determinate-nix
      # plasma
    ];
  };
}
