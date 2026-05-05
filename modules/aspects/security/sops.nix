{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  blazar.security._.sops.homeManager = {pkgs, ...}: {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];

    sops.secrets = with lib; {
      user-passwords = {
        key = "user-passwords";
        sopsFile = ../../../secrets/user-passwords.yaml;
        neededForUsers = true;
      };
    };

    home.packages = with pkgs; [
      age
      sops
      ssh-to-age
      ssh-to-pgp
    ];
  };

  blazar.security._.sops.nixos = {pkgs, ...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.secrets = with lib; {
      root-password = {
        key = "root";
        sopsFile = ../../../secrets/user-passwords.yaml;
        neededForUsers = true;
      };

      aniket-password = {
        key = "aniket";
        sopsFile = ../../../secrets/user-passwords.yaml;
        neededForUsers = true;
      };

      hass-password = {
        key = "hass";
        sopsFile = ../../../secrets/user-passwords.yaml;
        neededForUsers = true;
      };

      nextcloud-password = mkIf config.${namespace}.system.users.nextcloud.enable {
        key = "nextcloud";
        sopsFile = ../../../secrets/user-passwords.yaml;
        owner = "nextcloud";
      };

      miranda-cert = mkIf config.${namespace}.system.users.nginx.enable {
        key = "miranda-cert";
        sopsFile = ../../../secrets/keys.yaml;
        owner = "nginx";
      };

      miranda-cert-key = mkIf config.${namespace}.system.users.nginx.enable {
        key = "miranda-cert-key";
        sopsFile = ../../../secrets/keys.yaml;
        owner = "nginx";
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

    environment.systemPackages = with pkgs; [
      age
      sops
      ssh-to-age
      ssh-to-pgp
    ];
  };
}
