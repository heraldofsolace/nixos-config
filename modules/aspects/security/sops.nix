{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  blazar.security._.sops.homeManager = { pkgs, ... }: {
    # imports = [
    #   inputs.sops-nix.homeManagerModules.sops
    # ];

    # sops.secrets = with lib; {
    #   user-passwords = {
    #     key = "user-passwords";
    #     sopsFile = ../../../secrets/user-passwords.yaml;
    #     neededForUsers = true;
    #   };
    # };

    # sops.gnupg.sshKeyPaths = null;

    home.packages = with pkgs; [
      age
      sops
      ssh-to-age
      ssh-to-pgp
    ];
  };

  blazar.security._.sops.nixos = { pkgs, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    services.openssh.enable = true;

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

      # nextcloud-password = {
      #   key = "nextcloud";
      #   sopsFile = ../../../secrets/user-passwords.yaml;
      #   owner = "nextcloud";
      # };

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
