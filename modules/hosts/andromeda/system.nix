{
  blazar,
  inputs,
  ...
}: {
  den.hosts.x86_64-linux.andromeda = {
    pkgs,
    config,
    lib,
    ...
  }: {
    description = "NixOS workstation for Work notebook Lenovo ThinkPad T14 Gen 4 Ryzen";
    users.aniket = {
      description = "Aniket";
      userNameNick = "Aniket";
      userNameReal = "Aniket Bhattacharyea";
    };
    users.hass = {
      description = "Home Assistant";
      userNameNick = "hass";
      userNameReal = "Home Assistant";
    };

    # users.root = {
    #   description = "Root";
    #   userNameNick = "root";
    #   userNameReal = "Root";
    #   uid = 0;
    #   home = lib.mkForce "/root";
    #   # passwordFile = config.sops.secrets.root-password.path;
    #   hashedPassword = "$6$z0zrqUB8GGXrbGo/$JEeOmM3VRn3zs9cuOXOzl5eU1YQlt1xaSqtv33cftqIsgK0MZQYET8a.oiGuWY9d32t5CX4CB3bNQNDUHmHQj0";
    # };
  };

  den.aspects.andromeda = {
    nixos.imports = with inputs; [
      ./_hardware-configuration.nix
      ./_zfs.nix
      ./_defaults.nix
      dankMaterialShell.nixosModules.greeter
      sops-nix.nixosModules.sops
    ];

    nixos = {
      sops.secrets = {
        root-password = {
          key = "root";
          sopsFile = ../../../secrets/user-passwords.yaml;
          neededForUsers = true;
        };

        hass-password = {
          key = "hass";
          sopsFile = ../../../secrets/user-passwords.yaml;
          neededForUsers = true;
        };

        tailscale-key = {
          key = "tailscale";
          sopsFile = ../../../secrets/keys.yaml;
        };

        weatherapi-key = {
          key = "weatherapi-key";
          sopsFile = ../../../secrets/keys.yaml;
          mode = "0444";
        };
      };
    };

    includes = with blazar; [
      stylix
      impermanence
    ];
  };
}
