{
  blazar,
  config,
  lib,
  ...
}: {
  blazar.ci-no-boot = {
    description = "Disable booting when running on CI on all NixOS hosts.";
    nixos = {
      fileSystems."/".device = lib.mkDefault "/dev/noroot";
      boot.loader.grub.enable = lib.mkDefault false;
    };
  };

  den.schema.host.includes = lib.optionals (config ? _module.args.CI) [
    blazar.ci-no-boot
  ];
}
