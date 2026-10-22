{
  blazar,
  inputs,
  ...
}:
{
  den.hosts.x86_64-linux.andromeda = _: {
    # Hardware survey of the machine andromeda actually is, taken from the
    # running system with the command named next to each fact. The string
    # below previously described a laptop that was never this host.
    #
    # Form factor - `hostnamectl` reports Icon name `computer-desktop` and
    # Chassis `desktop`; `/sys/class/dmi/id/chassis_type` is 3 (desktop).
    # Board - `hostnamectl`: Hardware Vendor ASUSTeK COMPUTER INC., Model
    # ROG STRIX X570-E GAMING WIFI II, firmware 0309 dated 2021-08-16.
    # CPU - `lscpu`: AMD Ryzen 9 5950X 16-Core Processor, 32 CPUs, 2
    # threads per core, 16 cores per socket, 1 socket, L3 64 MiB (2
    # instances), L2 8 MiB. `policy0/scaling_driver` is amd-pstate-epp
    # with governor `performance`.
    # RAM - `free -h`: 62Gi total memory and 31Gi of swap (nvme0n1p4).
    # `nohibernate` on the kernel command line means the swap is not
    # there to hibernate into.
    # GPU - `lspci -nn`: Navi 21 [Radeon RX 6800/6800 XT / 6900 XT]
    # [1002:73bf], driver amdgpu, amdgpu.ppfeaturemask=0xfffd7fff; VRAM
    # from `mem_info_vram_total` is 17163091968 bytes (~16 GiB). sysfs
    # only ever names the family, so the SKU is not guessed at here.
    # Storage - `lsblk -o NAME,SIZE,MODEL` and `zpool list`: rpool 888G on
    # a 931.5G Seagate FireCuda 520 NVMe, archive 928G on a 931.5G Seagate
    # ST1000DM010 HDD, games 343G striped across a 238.5G XPG SPECTRIX
    # S40G NVMe and a 111.8G WD Green SATA SSD, bpool 3.75G mirrored over
    # the 4G boot partitions of both NVMes, each NVMe with a 1G vfat ESP.
    # `zpool status` has all four ONLINE and scrubbed with zero errors; a
    # DVD-RW (GP70N) and a card reader are attached too.
    # Network - `lspci -nn` and `ip -br link`: RTL8125 2.5GbE (enp6s0),
    # Intel I211 GbE (enp7s0, no carrier), MediaTek MT7921K Wi-Fi 6E
    # (wlan0, down).
    # OS - `hostnamectl`: NixOS 26.05 (Yarara) on kernel 7.2.8-cachyos;
    # `/boot/grub` exists and there is no systemd-boot loader directory,
    # so GRUB is the boot loader.
    description = "NixOS desktop on an ASUS ROG STRIX X570-E - Ryzen 9 5950X, 62 GiB RAM, 16 GiB Navi 21 Radeon, four ZFS pools over NVMe, SATA SSD and HDD";
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
      ./_disko.nix
      disko.nixosModules.disko
      dankMaterialShell.nixosModules.greeter
      chaotic.nixosModules.default
    ];

    nixos = {
      nixpkgs.config.permittedInsecurePackages = [
        "pnpm-10.29.2"
      ];

      environment = {
        variables = {
          EDITOR = "vim";
        };

        persistence = {
          "/persist" = {
            hideMounts = true;
            directories = [
              "/etc/nix"
              "/etc/coolercontrol"
              # "/etc/pipewire"
              "/var/log"
              "/var/lib/bluetooth"
              "/var/lib/nixos"
              "/var/lib/samba"
              "/var/lib/systemd/coredump"
              "/var/db/sudo"
              "/var/lib/tailscale"
              "/var/lib/postgresql"
              "/var/lib/coolercontrol"
              "/var/lib/qemu"
              "/var/lib/comin"
              "/var/lib/OpenRGB"
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

      # The Focusrite Scarlett 2i2 (1235:8210) doesn't reliably resume from
      # suspend on its own - it sometimes stays disconnected until physically
      # replugged. USB_QUIRK_RESET_RESUME ('b') makes the kernel force a full
      # USB reset on resume instead of trying (and failing) a normal restore.
      boot.kernelParams = [ "usbcore.quirks=1235:8210:b" ];
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
          kdePackages = prev.kdePackages.overrideScope (
            _kfinal: kprev: {
              dolphin = prev.symlinkJoin {
                name = "dolphin-wrapped";
                paths = [
                  kprev.dolphin
                  kprev.dolphin.dev
                ];
                nativeBuildInputs = [ prev.makeWrapper ];
                postBuild = ''
                  rm $out/bin/dolphin
                  makeWrapper ${kprev.dolphin}/bin/dolphin $out/bin/dolphin \
                    --run "${kprev.kservice}/bin/kbuildsycoca6 --noincremental"
                '';
              };
            }
          );
        })
      ];
    };

    includes = with blazar; [
      stylix
      impermanence
      determinate-nix
      utils._.samba
    ];
  };
}
