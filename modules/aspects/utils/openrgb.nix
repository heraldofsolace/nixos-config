{ self, ... }: {
  blazar.utils._.openrgb = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        openrgb-with-all-plugins
        self.packages.${pkgs.stdenv.hostPlatform.system}.lian-li-linux
      ];

      services.udev.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.lian-li-linux
      ];

      programs.coolercontrol.enable = true;

      users.groups.lianli = { };

      # Your user.
      users.users.aniket = {
        isNormalUser = true;

        # Add this only if you actually want the group-based permissions.
        extraGroups = [
          "lianli"
        ];
      };

      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
        motherboard = "amd";
        server.port = 6742;
      };
    };

    homeManager = { pkgs, ... }: {
      systemd.user.services.lianli-daemon = {
        Unit = {
          Description = "Lian Li Device Daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";

          ExecStart = "${self.packages.${pkgs.stdenv.hostPlatform.system}.lian-li-linux}/bin/lianli-daemon";

          Restart = "on-failure";
          RestartSec = 5;
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
