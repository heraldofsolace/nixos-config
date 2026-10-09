_: {
  blazar.keyboard._.polymath = {
    nixos = { self', ... }: {
      environment.systemPackages = with self'.packages; [
        polymath
      ];
      services.udev.packages = with self'.packages; [ polymath ];

      # Lets udisks2 auto-mount the RP2040 bootloader drive without a polkit
      # prompt, matching upstream's /etc/polkit-1/rules.d/10-rpi-rp2-mount.rules.
      security.polkit.extraConfig = builtins.readFile "${self'.packages.polymath}/share/polkit-1/rules.d/10-rpi-rp2-mount.rules";
    };

    homeManager =
      { self', ... }:
      {
        systemd.user.services.polymath = {
          Unit = {
            Description = "Flux Polymath keyboard configurator";
            After = [ "hyprland-session.target" ];
            PartOf = [ "hyprland-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${self'.packages.polymath}/bin/polymath";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install = {
            WantedBy = [ "hyprland-session.target" ];
          };
        };
      };
  };
}
