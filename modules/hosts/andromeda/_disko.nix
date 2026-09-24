{
  # Reference disko layout describing andromeda's existing ZFS setup (see
  # _hardware-configuration.nix and _zfs.nix for the config that actually
  # mounts/boots this today). Read directly off the live system via
  # `lsblk`, `zpool status -v`, `zfs list`, and `sfdisk -d` - not guessed.
  #
  # Wired into system.nix via disko.nixosModules.disko - the corresponding
  # fileSystems/swapDevices entries were removed from
  # _hardware-configuration.nix so disko is now the sole source of them
  # (ZFS-backed mounts still come from the zpool/dataset config below, as
  # before - only the ESP and swap partitions needed a pinned `uuid`).
  # This still does NOT format/partition anything on `nixos-rebuild
  # switch`: the `uuid` pinned on the ESP/swap partitions below matches
  # the real, already-existing partition UUIDs (captured via `sfdisk -d`
  # on the live system), so the fileSystems disko generates
  # (/dev/disk/by-partuuid/<uuid>) resolve to the exact same partitions
  # that are already formatted and in use - no relabeling or reformatting
  # required. Actually reformatting from scratch still needs the disko
  # tool run explicitly:
  #   nix run github:nix-community/disko -- --mode disko \
  #     --arg disko ./modules/hosts/andromeda/_disko.nix
  # (or via disko-install / nixos-anywhere) from a live environment.
  disko.devices = {
    disk = {
      # 1TB Seagate FireCuda NVMe: ESP + BIOS-boot + bpool (mirror half) +
      # rpool (sole member, NOT mirrored) + swap.
      seagate = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Seagate_FireCuda_520_SSD_ZP1000GM30002_7QG021QD";
        content = {
          type = "gpt";
          partitions = {
            bios-boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            ESP = {
              size = "1G";
              type = "EF00";
              priority = 2;
              # Pinned to the real, already-existing GPT partition UUID so
              # the generated fileSystems device (/dev/disk/by-partuuid/...)
              # resolves to this exact partition without any reformatting.
              uuid = "4f65d74c-5c81-47ba-b8b4-5ba007efed1b";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efis/nvme-Seagate_FireCuda_520_SSD_ZP1000GM30002_7QG021QD-part1";
                mountOptions = [ "nofail" ];
              };
            };
            bpool = {
              size = "4G";
              priority = 3;
              content = {
                type = "zfs";
                pool = "bpool";
              };
            };
            swap = {
              size = "32G";
              priority = 4;
              uuid = "dcf6bf64-2a0d-4d4e-8521-7b08346913e7";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            rpool = {
              # Last partition on this disk in the real layout - consumes
              # whatever remains (~894G today).
              size = "100%";
              priority = 5;
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };

      # 240GB XPG Spectrix NVMe: ESP + BIOS-boot + bpool (mirror half) +
      # a partition contributed to the `games` pool (striped, not mirrored).
      xpg = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-XPG_SPECTRIX_S40G_2K0920050772";
        content = {
          type = "gpt";
          partitions = {
            bios-boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            ESP = {
              size = "1G";
              type = "EF00";
              priority = 2;
              uuid = "cce647df-e608-4603-9623-de8a3f55bf46";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efis/nvme-XPG_SPECTRIX_S40G_2K0920050772-part1";
                mountOptions = [ "nofail" ];
              };
            };
            bpool = {
              size = "4G";
              priority = 3;
              content = {
                type = "zfs";
                pool = "bpool";
              };
            };
            games = {
              # Last partition on this disk - consumes the remainder
              # (~233G today) and stripes into the `games` pool below.
              size = "100%";
              priority = 4;
              content = {
                type = "zfs";
                pool = "games";
              };
            };
          };
        };
      };

      # 1TB Seagate Barracuda SATA HDD, used whole-disk (no partition
      # table) as the sole vdev of the `archive` pool.
      archive-hdd = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST1000DM010-2EP102_ZN10JDQ3";
        content = {
          type = "zfs";
          pool = "archive";
        };
      };

      # 120GB WD SATA SSD, used whole-disk (no partition table) as the
      # other, non-mirrored member striped into the `games` pool.
      games-ssd = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_184290802184";
        content = {
          type = "zfs";
          pool = "games";
        };
      };
    };

    zpool = {
      bpool = {
        type = "zpool";
        mode = "mirror";
        # Grub's ZFS support only understands a restricted feature set;
        # "grub2" is OpenZFS's built-in compatibility profile
        # (/usr/share/zfs/compatibility.d/grub2) covering exactly the
        # feature list this pool was actually created with (verified via
        # `zpool get all bpool`).
        options = {
          ashift = "12";
          autotrim = "on";
          compatibility = "grub2";
        };
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          "nixos/root" = {
            type = "zfs_fs";
            mountpoint = "/boot";
            options.mountpoint = "legacy";
          };
        };
      };

      # NOT mirrored in the real layout - a single vdev on the Seagate
      # disk's last partition. The "local"/"safe" dataset split is a
      # snapshot/backup convention, not disk-level redundancy.
      rpool = {
        type = "zpool";
        options.ashift = "12";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };
        };
      };

      # Single whole-disk vdev, no redundancy.
      archive = {
        type = "zpool";
        options.ashift = "12";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        datasets."root" = {
          type = "zfs_fs";
          mountpoint = "/archive";
          options.mountpoint = "legacy";
        };
      };

      # Striped (not mirrored) across two differently-sized devices -
      # no redundancy here either; matches the real `zpool status games`
      # output (two bare top-level members, no mirror-N grouping).
      games = {
        type = "zpool";
        options.ashift = "12";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        datasets."root" = {
          type = "zfs_fs";
          mountpoint = "/games";
          options.mountpoint = "legacy";
        };
      };
    };
  };
}
