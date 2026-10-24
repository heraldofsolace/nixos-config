{ inputs, ... }: {
  flake-file.inputs = {
    # Fork, not upstream directly: carries a local packaging commit (the
    # home-manager module for session-capture autostart) that hasn't been
    # upstreamed. Was a local git+file:// path, which doesn't exist outside
    # this machine and broke every CI check that touches it.
    lian-li-linux.url = "github:heraldofsolace/lian-li-linux/449db489aea2a1673e5e0ffd458223ba9d6ef543";
  };
  blazar.utils._.openrgb = {
    nixos = { pkgs, ... }: {
      imports = [
        inputs.lian-li-linux.nixosModules.default
      ];

      environment.systemPackages = with pkgs; [
        openrgb-with-all-plugins
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

      services.lianli-linux = {
        enable = true;
        daemonMode = "user";
      };
    };

    homeManager = { ... }: {
      imports = [
        inputs.lian-li-linux.homeManagerModules.default
      ];
      services.lianli-linux.session.enable = true;
      # systemd.user.services.lianli-daemon = {
      #   Unit = {
      #     Description = "Lian Li Device Daemon";
      #     After = [ "graphical-session.target" ];
      #     PartOf = [ "graphical-session.target" ];
      #   };

      #   Service = {
      #     Type = "simple";

      #     ExecStart = "${self.packages.${pkgs.stdenv.hostPlatform.system}.lian-li-linux}/bin/lianli-daemon";

      #     Restart = "on-failure";
      #     RestartSec = 5;
      #   };

      #   Install = {
      #     WantedBy = [ "default.target" ];
      #   };
      # };
    };
  };
}
