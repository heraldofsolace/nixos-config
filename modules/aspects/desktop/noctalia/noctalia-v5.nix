{ inputs, ... }: {
  flake-file.inputs.noctalia-v5 = {
    url = "github:noctalia-dev/noctalia/cachix";
  };

  blazar.noctalia-v5.nixos = {
    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };
  blazar.noctalia-v5.homeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [
        inputs.noctalia-v5.homeModules.default
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
      programs.noctalia =
        let
          noctaliaCustomSettings = (builtins.fromTOML (builtins.readFile ./noctalia-full-config.toml)) // {
            theme.mode = if config.stylix.polarity == "dark" then config.stylix.polarity else "light";
            dock.background_opacity = config.stylix.opacity.desktop;
            notification.background_opacity = config.stylix.opacity.popups;
            osd.background_opacity = config.stylix.opacity.popups;
            shell.font_family = config.stylix.fonts.sansSerif.name;
          };
        in
        {
          enable = true;
          settings = lib.mapAttrs (_name: value: lib.mkDefault value) noctaliaCustomSettings;
        };
      home.file.".config/noctalia/palettes/custom.json".text =
        let
          colorScheme = {
            dark = with config.lib.stylix.colors.withHashtag; {
              mPrimary = base0D;
              mOnPrimary = base00;
              mSecondary = base0E;
              mOnSecondary = base00;
              mTertiary = base0C;
              mOnTertiary = base00;
              mError = base08;
              mOnError = base00;
              mSurface = base00;
              mOnSurface = base05;
              mHover = base0C;
              mOnHover = base00;
              mSurfaceVariant = base01;
              mOnSurfaceVariant = base04;
              mOutline = base03;
              mShadow = base00;

              terminal = {
                foreground = base05;
                background = base00;
                cursor = base05;
                cursorText = base00;
                selectionFg = base05;
                selectionBg = base02;
                normal = {
                  black = base00;
                  red = base08;
                  green = base0B;
                  yellow = base0A;
                  blue = base0D;
                  magenta = base0E;
                  cyan = base0C;
                  white = base05;
                };
                bright = {
                  black = base03;
                  red = base08;
                  green = base0B;
                  yellow = base0A;
                  blue = base0D;
                  magenta = base0E;
                  cyan = base0C;
                  white = base07;
                };
              };
            };
          };
        in
        builtins.toJSON colorScheme;
    };
}
