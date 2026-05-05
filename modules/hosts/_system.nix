{blazar, ...}: {
  den.hosts.x86_64-linux = {
    # users, homes, and hosts aspects are Nix module system submodules (one can define type-checked options) and freeform types (one can define freeform attributes).
    HOST-nixos = {
      hostName = "HOST"; # default is HOST-nixos
      description = "NixOS workstation for Work notebook Lenovo ThinkPad T14 Gen 4 Ryzen";
      # class = "nixos"; # default is guessed from platform
      # aspect = "workstation"; # default is HOST-nixos
      users = {
        aniket = {
          description = "Aniket";
          userName = "aniket"; # default was adda
          userNameNick = "Aniket";
          userNameReal = "Aniket Bhattacharýea"; # "David (Adda) Chocholatý"
          # aspect = "adda"; # default was adda
          # class = "homeManager"; # default is homeManager

          # Everything here accessible via `user.*` in aspects.
        };
      };

      # isWorkstation = true; # Default is already true.
    };
  };

  den.aspects.HOST-nixos = {
    nixos.imports = [
      ./_hardware-configuration.nix
    ];

    includes = with blazar; [
    ];
  };
}
