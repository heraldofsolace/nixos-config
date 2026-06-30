{
  environment = {
    variables = {
      EDITOR = "vim";
    };

    persistence = {
      "/persist" = {
        hideMounts = true;
        directories = [
          "/etc/nix"
          # "/etc/pipewire"
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/samba"
          "/var/lib/systemd/coredump"
          "/var/db/sudo"
          "/var/lib/tailscale"
          "/var/lib/postgresql"
          "/root"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
    };
  };

  networking.interfaces.enp6s0.wakeOnLan.enable = true;
  networking.hostName = "andromeda";
  services = {
    geoclue2.enable = true;
    gnome.gnome-keyring.enable = true;
    xserver = {
      enable = true;
      wacom.enable = true;
      videoDrivers = [ "amdgpu" ];
    };
    gvfs.enable = true;
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      settings.PasswordAuthentication = false;
      hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };
  };

  security.polkit.enable = true;
  services.avahi.hostName = "andromeda";
}
