{
  flake-file.inputs = {
    # rimsort = {
    #   url = "https://github.com/RimSort/RimSort";
    #   flake = false;
    # };
  };

  blazar.games.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      # (inputs.nur.repos.username.package)

      protonup-qt
      protonup-ng
      protonplus
      wineWow64Packages.unstableFull
      # wineWow64Packages.waylandFull
      winetricks

      heroic
      bottles

      umu-launcher
      # umu-launcher-unwrapped
      nero-umu

      # (rimsort.overrideAttrs (prevAttrs: {
      #   version = "latest";
      #   src = inputs.rimsort;
      #   # pkgs.fetchFromGitHub {
      #   #   owner = "RimSort";
      #   #   repo = "RimSort";
      #   #   rev = "refs/heads/main";
      #   #   hash = "sha256-Mh0RkLWuFkqsb9cxc1TGhtgdY2VeulCOaa4aZxRxKJU=";
      #   # };
      # }))
      # inputs'.nixpkgs-local.legacyPackages.rimsort
    ];
  };

  blazar.games.nixos = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };
    environment.systemPackages = [
      pkgs.mangohud
      pkgs.steamcmd
      pkgs.lact
    ];
    programs.gamemode.enable = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };

    hardware.amdgpu.overdrive.enable = true;
    systemd.packages = with pkgs; [ lact ];
    systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  };
}
