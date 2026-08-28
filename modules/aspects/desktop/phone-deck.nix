{ inputs, ... }: {
  flake-file.inputs = {
    phone-deck = {
      url = "github:heraldofsolace/phone-deck";
    };
  };
  blazar.desktop._.phone-deck = {
    nixos = { ... }: {
      imports = [
        inputs.phone-deck.nixosModules.default
      ];
      services.phone-deck = {
        enable = true;
        user = "aniket";
        secureCookies = true;
      };
    };
  };
}
