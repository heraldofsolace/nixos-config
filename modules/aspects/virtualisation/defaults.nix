{
  blazar.virtualisation = {user, ...}: {
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      #https://nixos.org/wiki/Podman
      environment = {
        systemPackages = with pkgs; [
          #ventoy-full-qt

          distrobox-tui
          fuse-overlayfs
          boxbuddy
          distroshelf
          pods
        ];
      };

      boot.enableContainers = true;

      virtualisation = {
        containers.enable = true;
        podman = {
          defaultNetwork.settings = {
            dns_enabled = true;
          };
          dockerCompat = true;
          dockerSocket.enable = true;
          enable = true;
        };

        docker = {
          enable = false;
          autoPrune.enable = true;
          enableOnBoot = true;
        };

        libvirtd.enable = true;
      };

      programs.virt-manager.enable = true;

      users.users.${user.userName}.extraGroups =
        (lib.optional config.virtualisation.podman.enable "podman")
        ++ (lib.optional config.virtualisation.libvirtd.enable "libvirtd") ++ (lib.optional config.virtualisation.docker.enable "docker");
    };

    blazar.virtualisation.homeManager = {
      # services.podman = { };
      programs.distrobox = {
        enable = true;
        containers = {
        };
      };
    };
  };
}
