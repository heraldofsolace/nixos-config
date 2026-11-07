{ inputs, ... }:
{
  blazar.keyboard._.polymath = {
    nixos =
      { pkgs, ... }:
      let
        # Same package the homeManager block below runs, built from the
        # unstable snapshot for EGL/mesa ABI consistency - see its comment.
        # Built here too (rather than reusing self'.packages.polymath) so
        # system-installed polymath isn't a different, stable-linked copy.
        pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        polymathPackage = pkgs-unstable.callPackage ../../../packages/polymath/package.nix { };
      in
      {
        environment.systemPackages = [ polymathPackage ];
        services.udev.packages = [ polymathPackage ];

        # Lets udisks2 auto-mount the RP2040 bootloader drive without a polkit
        # prompt, matching upstream's /etc/polkit-1/rules.d/10-rpi-rp2-mount.rules.
        security.polkit.extraConfig = builtins.readFile "${polymathPackage}/share/polkit-1/rules.d/10-rpi-rp2-mount.rules";
      };

    homeManager =
      { pkgs, ... }:
      let
        # polymath is a Flutter/GTK app autoPatchelf'd against the *stable*
        # mesa/libGL. hardware.graphics.package overrides the system's
        # runtime driver (/run/opengl-driver) with mesa from the unstable
        # snapshot, and the two don't share a glibc ABI - the same class of
        # EGL_EXT_platform_base bug fixed for cage/wezterm-gui in
        # hyprland.nix. Overriding just mesa/libGL/libdrm wasn't enough
        # (still crashed) - the whole dependency closure (glibc included)
        # needs to come from the same snapshot, so rebuild the package
        # entirely with pkgs-unstable rather than overriding individual
        # inputs on a stable-built derivation.
        pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        polymathPackage = pkgs-unstable.callPackage ../../../packages/polymath/package.nix { };
      in
      {
        systemd.user.services.polymath = {
          Unit = {
            Description = "Flux Polymath keyboard configurator";
            After = [ "hyprland-session.target" ];
            PartOf = [ "hyprland-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${polymathPackage}/bin/polymath";
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
