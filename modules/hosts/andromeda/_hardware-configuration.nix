{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-amd"
    "uinput"
    "v4l2loopback"
    "coretemp"
    "nct6775"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.zfs.package = pkgs.zfs_cachyos;
  services.scx.enable = true; # by default uses scx_rustland scheduler
  boot.blacklistedKernelModules = [
    "rtl8192cu"
    "rtl_usb"
    "rtl8192c_common"
    "rtlwifi"
  ];
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235,0x1235 pid=0x8211,0x8210 device_setup=1,1
  '';
  boot.zfs.extraPools = [ "rpool" ];
  fileSystems."/" = {
    device = "rpool/local/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "rpool/local/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/safe/home";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "rpool/safe/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "bpool/nixos/root";
    fsType = "zfs";
  };

  fileSystems."/archive" = {
    device = "archive/root";
    fsType = "zfs";
  };

  fileSystems."/boot/efis/nvme-Seagate_FireCuda_520_SSD_ZP1000GM30002_7QG021QD-part1" = {
    device = "/dev/disk/by-uuid/F582-0E75";
    fsType = "vfat";
  };

  fileSystems."/boot/efis/nvme-XPG_SPECTRIX_S40G_2K0920050772_1-part1" = {
    device = "/dev/disk/by-uuid/9149-63F8";
    fsType = "vfat";
  };

  fileSystems."/boot/efi" = {
    device = "/boot/efis/nvme-Seagate_FireCuda_520_SSD_ZP1000GM30002_7QG021QD-part1";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/games" = {
    device = "games/root";
    fsType = "zfs";
  };

  swapDevices = [
    { device = "/dev/disk/by-id/nvme-Seagate_FireCuda_520_SSD_ZP1000GM30002_7QG021QD-part4"; }
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

  hardware.keyboard.zsa.enable = true;
  hardware.keyboard.qmk.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  hardware.bluetooth.enable = true;
  services.udev.packages = [ pkgs.bazecor ];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';
  powerManagement.cpuFreqGovernor = "performance";
}
