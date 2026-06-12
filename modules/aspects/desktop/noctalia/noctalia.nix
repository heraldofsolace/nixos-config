{inputs, ...}: {
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia/legacy-v4";
    inputs.nixpkgs.follows = "latest";
  };

  blazar.noctalia.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      tesseract
      imagemagick
      zbar
      curl
      translate-shell
      wl-screenrec
      gifski
    ];
    programs.noctalia-shell = {
      enable = true;
      settings = lib.mkForce ./settings.json;
      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          fancy-audiovisualizer = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          kde-connect = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          keybind-cheatsheet = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          screen-toolkit = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          tailscale = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          wallcards = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          workspace-overview = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 2;
      };
    };
  };
}
