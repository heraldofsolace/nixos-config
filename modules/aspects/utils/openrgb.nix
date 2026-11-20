{ inputs, lib', ... }: {
  flake-file.inputs = {
    # Fork, not upstream directly: carries a local packaging commit (the
    # home-manager module for session-capture autostart) that hasn't been
    # upstreamed. Was a local git+file:// path, which doesn't exist outside
    # this machine and broke every CI check that touches it.
    lian-li-linux.url = "github:heraldofsolace/lian-li-linux/449db489aea2a1673e5e0ffd458223ba9d6ef543";
  };
  blazar.utils._.openrgb = {
    nixos =
      { pkgs, lib, ... }:
      let
        # lianli-daemon's own package wraps the *stable* pkgs.ffmpeg onto
        # its PATH. That ffmpeg can't load hardware.graphics.package's
        # (unstable-sourced) mesa VAAPI driver - glibc/mesa ABI mismatch,
        # the same class of bug fixed for cage/wezterm-gui in hyprland.nix.
        # Without this, enabling hardware_video in ~/.config/lianli
        # silently falls back to software decode with no benefit.
        pkgs-unstable = lib'.unstableUnfree pkgs.stdenv.hostPlatform.system;
        lianliPackage = inputs.lian-li-linux.packages.${pkgs.stdenv.hostPlatform.system}.default;
      in
      {
        imports = [
          inputs.lian-li-linux.nixosModules.default
        ];

        services.lianli-linux.package = lianliPackage.overrideAttrs (_old: {
          postFixup = ''
            for bin in lianli-daemon lianli-gui lianli-session lianli-control; do
              wrapProgram "$out/bin/$bin" \
                --prefix PATH : "${
                  lib.makeBinPath [
                    pkgs-unstable.ffmpeg
                    pkgs.fontconfig
                    pkgs.kmod
                  ]
                }" \
                --set FONTCONFIG_FILE "${pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; }}"
            done
          '';
        });

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
