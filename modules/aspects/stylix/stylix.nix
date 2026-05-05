{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs = {
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      # url = "git+file:///home/aniket/stylix";
    };
  };
  blazar.stylix.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: {
    stylix.enable = true;

    stylix.targets.tmux.enable = false;
    stylix.targets.hyprland.enable = false;
    stylix.targets.vscode.enable = true;
    stylix.targets.kde.enable = true;
    stylix.targets.qt.enable = true;
    stylix.targets.qt.platform = "qtct";

    home.packages = with pkgs; [
      morewaita-icon-theme
      adwaita-icon-theme
      papirus-icon-theme
    ];
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };
  };

  blazar.stylix.nixos = {pkgs, ...}: {
    imports = [
      inputs.stylix.nixosModules.stylix
    ];
    stylix = let
      anomaly = pkgs.stdenvNoCC.mkDerivation {
        name = "anomaly-font";
        dontConfigue = true;
        nativeBuildInputs = [pkgs.nerd-font-patcher];
        src = pkgs.fetchFromGitHub {
          owner = "benbusby";
          repo = "anomaly-mono";
          rev = "3f1d10fe8ee2c4da32c65a784164c494102c3f83";
          sha256 = "sha256-6qeRb9YOaFzbipkIHbfNwRv5GnG4oX8AbHZllRFZl7k=";
          stripRoot = false;
        };
        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          cp $src/**/*.otf $out/share/fonts/opentype/
        '';
        postInstall = ''
          mkdir -p $out/share/fonts/opentype/{anomaly-mono,anomaly-mono-nerd}
          mv $out/share/fonts/opentype/*.otf $out/share/fonts/opentype/anomaly-mono/
          for f in $out/share/fonts/opentype/anomaly-mono/*.otf; do
            nerd-font-patcher --complete --outputdir $out/share/fonts/opentype/anomaly-mono-nerd/ $f
          done
        '';
      };
    in {
      enable = true;
      image = ./_files/wall10.jpg;
      polarity = "dark";
      base16Scheme = ./_files/everforest.yaml;
      targets.grub.useWallpaper = true;
      fonts = {
        serif = {
          package = pkgs.nerd-fonts.iosevka;
          name = "Iosevka Serif";
        };

        sansSerif = {
          package = pkgs.nerd-fonts.iosevka;
          name = "Iosevka Sans";
        };

        monospace = {
          package = anomaly;
          name = "Anomaly Mono";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };

        sizes = {
          desktop = 14;
          applications = 14;
        };
      };

      opacity = {
        popups = 0.5;
        applications = 0.5;
        desktop = 0.5;
        terminal = 0.8;
      };
    };
  };
}
