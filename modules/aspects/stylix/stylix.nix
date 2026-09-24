{ inputs, ... }: {
  flake-file.inputs = {
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      # url = "git+file:///home/aniket/stylix";
    };
  };
  blazar.stylix.homeManager = { pkgs, ... }: {
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

  blazar.stylix.nixos = { pkgs, ... }: {
    imports = [
      inputs.stylix.nixosModules.stylix
    ];
    stylix = {
      enable = true;
      image = ./_files/wall.png;
      polarity = "dark";
      base16Scheme = ./_files/everforest.yaml;
      targets.grub.useWallpaper = true;
      fonts = {
        serif = {
          package = pkgs.nerd-fonts.iosevka;
          name = "Iosevka Nerd Font";
        };

        sansSerif = {
          package = pkgs.nerd-fonts.iosevka;
          name = "Iosevka Nerd Font";
        };

        monospace = {
          package = pkgs.nerd-fonts.iosevka;
          name = "Iosevka Nerd Font Mono";
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
