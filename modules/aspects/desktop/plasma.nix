_: {
  blazar.plasma.nixos = { pkgs, ... }: {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.plasma-login-manager.enable = true;
    services.xserver.wacom.enable = true;

    programs.ssh = {
      askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
      # startAgent = true;
    };

    programs.kdeconnect.enable = true;
    # environment.systemPackages = [pkgs.kdePackages.yakuake pkgs.kdePackages.ark pkgs.kdePackages.dolphin];
  };
}
