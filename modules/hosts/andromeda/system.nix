{
  blazar,
  inputs,
  ...
}: {
  den.hosts.x86_64-linux.andromeda = _: {
    description = "NixOS workstation for Work notebook Lenovo ThinkPad T14 Gen 4 Ryzen";
    users.aniket = {
      description = "Aniket";
      userNameNick = "Aniket";
      userNameReal = "Aniket Bhattacharyea";
      classes = ["homeManager" "hjem" "maid"];
    };
    users.hass = {
      description = "Home Assistant";
      userNameNick = "hass";
      userNameReal = "Home Assistant";
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

  den.aspects.andromeda = {
    nixos.imports = with inputs; [
      ./_hardware-configuration.nix
      ./_zfs.nix
      dankMaterialShell.nixosModules.greeter
      chaotic.nixosModules.default
    ];

    nixos = {
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
          videoDrivers = ["amdgpu"];
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

      nixpkgs.overlays = [
        (_final: prev: {
          kdePackages = prev.kdePackages.overrideScope (_kfinal: kprev: {
            dolphin = prev.symlinkJoin {
              name = "dolphin-wrapped";
              paths = [kprev.dolphin kprev.dolphin.dev];
              nativeBuildInputs = [prev.makeWrapper];
              postBuild = ''
                rm $out/bin/dolphin
                makeWrapper ${kprev.dolphin}/bin/dolphin $out/bin/dolphin \
                  --set XDG_CONFIG_DIRS "${prev.kdePackages.kservice}/etc/xdg:$XDG_CONFIG_DIRS" \
                  --run "${kprev.kservice}/bin/kbuildsycoca6 --noincremental ${prev.kdePackages.kservice}/etc/xdg/menus/applications.menu"
              '';
            };
          });
        })
      ];
    };

    includes = with blazar; [
      stylix
      impermanence
      determinate-nix
    ];
  };
}
