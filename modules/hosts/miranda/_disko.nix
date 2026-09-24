{
  # Reference disko layout describing miranda's existing disk setup (see
  # _hardware-configuration.nix for the config that actually mounts/boots
  # this today). Read directly off the live host over SSH via `lsblk`,
  # `sfdisk -d`, and `ls /dev/disk/by-id` - not guessed.
  #
  # Wired into system.nix via disko.nixosModules.disko - the corresponding
  # fileSystems/swapDevices entries were removed from
  # _hardware-configuration.nix so disko is now the sole source of them.
  # This still does NOT format/partition anything on `nixos-rebuild
  # switch`: the `uuid` pinned on each filesystem/swap partition below
  # matches the real, already-existing partition UUIDs (captured via
  # `sfdisk -d` / `lsblk -o PARTUUID` over SSH), so the fileSystems disko
  # generates (/dev/disk/by-partuuid/<uuid>) resolve to the exact same
  # partitions that are already formatted and in use - no relabeling or
  # reformatting required. Actually reformatting from scratch still needs
  # the disko tool run explicitly:
  #   nix run github:nix-community/disko -- --mode disko \
  #     --arg disko ./modules/hosts/miranda/_disko.nix
  # (or via disko-install / nixos-anywhere) from a live environment.
  #
  # The /var/lib/nextcloud and /data bind mounts in
  # _hardware-configuration.nix are subdirectories of /mnt/storage, not
  # separate block devices - disko has nothing to manage there, they stay
  # hand-written regardless.
  disko.devices = {
    disk = {
      # 954GB XPG Gammix NVMe: root + swap + ESP. Physical partition order
      # on disk is ESP, root, swap (despite numbering being root=1,
      # swap=2, ESP=3) - priority below reproduces that order.
      xpg = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-XPG_GAMMIX_S11_Pro_2L282LAEGBJA";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "487M";
              type = "EF00";
              priority = 1;
              # Pinned to the real, already-existing GPT partition UUID so
              # the generated fileSystems device (/dev/disk/by-partuuid/...)
              # resolves to this exact partition without any reformatting.
              uuid = "6b322996-9643-4649-98b0-01e9ff3d8d0c";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
              };
            };
            root = {
              size = "894G";
              priority = 2;
              uuid = "f2eb71d7-c5c8-4692-b6d8-f6035c512a5e";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              # Last partition on the disk - consumes the remainder
              # (~59.6G today).
              size = "100%";
              priority = 3;
              uuid = "54418fd1-d62c-408d-862c-163315291fcb";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
        };
      };

      # 2TB Seagate Barracuda SATA HDD, single partition spanning the
      # whole disk, holding /mnt/storage (nextcloud + *arr data live under
      # bind mounts of this).
      storage = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST2000DM008-2FR102_WK208TP0";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              uuid = "580d510f-08e4-a844-b6a3-ee851c8f46f1";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/storage";
              };
            };
          };
        };
      };
    };
  };
}
