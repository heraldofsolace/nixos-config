{
  config,
  pkgs,
  ...
}:
{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "ab16568e";

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.copyKernels = true;
  # Unbounded otherwise - 160 generations had accumulated by the time this
  # was added, each one pinning its whole closure against GC regardless of
  # any nix.gc settings.
  boot.loader.grub.configurationLimit = 10;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;

  boot.loader.grub.extraPrepareConfig = ''
    mkdir -p /boot/efis
    for i in  /boot/efis/*; do mount $i ; done

    mkdir -p /boot/efi
    mount /boot/efi
  '';

  boot.loader.grub.extraInstallCommands = ''
    ESP_MIRROR=$(${pkgs.coreutils}/bin/mktemp -d)
    ${pkgs.coreutils}/bin/cp -r /boot/efi/EFI $ESP_MIRROR
    for i in /boot/efis/*; do
      ${pkgs.coreutils}/bin/cp -r $ESP_MIRROR/EFI $i
    done
    ${pkgs.coreutils}/bin/rm -rf $ESP_MIRROR
  '';

  boot.loader.grub.devices = [
    "/dev/disk/by-id/nvme-Seagate_FireCuda_520_SSD_ZP1000GM30002_7QG021QD"
    "/dev/disk/by-id/nvme-XPG_SPECTRIX_S40G_2K0920050772"
  ];

  boot.loader.grub.gfxmodeEfi = "2560x1440";
  # boot.loader.grub2-theme = {
  #   enable = true;
  #   theme = "tela";
  #   screen = "2k";
  #   footer = true;
  # };

  # ZFS scrub catches data corruption, but says nothing about a drive's own
  # wear/predictive-failure state (SMART) before it actually dies - nothing
  # else here watches that for the two NVMes + two SATA disks in this pool.
  services.smartd = {
    enable = true;
    autodetect = true;
    notifications.wall.enable = true;
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    autoSnapshot = {
      enable = true;
      frequent = 1;
      daily = 1;
      hourly = 1;
      weekly = 1;
      monthly = 1;
    };
    # TODO: autoReplication
  };
  boot.zfs.devNodes = "/dev/disk/by-partuuid";
  boot.zfs.forceImportRoot = false;
  systemd.services.zfs-mount.enable = false;

  # ZFS ARC is uncapped by default (up to ~50%+ of RAM). Measured 38GiB
  # (61%) in use on this 62GiB machine with only 3.8GiB genuinely free -
  # cap it so games/Ollama/VMs have real headroom, while still leaving
  # plenty for caching.
  boot.extraModprobeConfig = ''
    options zfs zfs_arc_max=${toString (24 * 1024 * 1024 * 1024)}
  '';

  # boot.initrd.postDeviceCommands = lib.mkAfter ''
  #   zpool import -a -d ${config.boot.zfs.devNodes}
  #   zfs rollback -r rpool/local/root@blank
  # '';

  boot.initrd.systemd = {
    enable = true; # this enabled systemd support in stage1 - required for the below setup
    services.rollback = {
      description = "Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [ "initrd.target" ];

      after = [ "zfs-import-rpool.service" ];

      # Before mounting the system root (/sysroot) during the early boot process
      before = [ "sysroot.mount" ];
      path = with pkgs; [
        zfs
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zpool import -a -d ${config.boot.zfs.devNodes}
        zfs rollback -r rpool/local/root@blank && echo "  >> >> rollback complete << <<"
      '';
    };
  };
}
