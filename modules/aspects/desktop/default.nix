{
  blazar.desktop.homeManager =
    {
      host,
      pkgs,
      ...
    }:
    {
      home = {
        packages =
          with pkgs;
          [
            appimage-run

            junction

            # inputs'.nixpkgs-local.legacyPackages.atuin-desktop
            atuin-desktop
            # stable.atuin-desktop

            libportal-qt6

            libreoffice
            onlyoffice-desktopeditors

            # thunderbird
            gparted

            discord

            qbittorrent
            transmission_4-qt6

            signal-desktop

            boxbuddy

            localsend

            # megasync

            cameractrls

            wl-clipboard

            kdePackages.dolphin
            obs-studio
          ]
          ++ (lib.optional (host.name == "andromeda") bambu-studio);
      };

      services.wl-clip-persist = {
        enable = false;
      };

      # Nicely reload system units when changing configs
      #systemd.user.startServices = lib.mkIf isLinux "sd-switch";

      home.preferXdgDirectories = true;
      xdg = {
        enable = true;

        mime.enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            "application/pdf" = "org.kde.okular.desktop";
            "image/*" = "gwenview.desktop";
            "text/html" = "firefox.desktop";
            "x-scheme-handler/http" = "firefox.desktop";
            "x-scheme-handler/https" = "firefox.desktop";
            "x-scheme-handler/about" = "firefox.desktop";
            "x-scheme-handler/unknown" = "firefox.desktop";
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
              "onlyoffice-desktopeditors.desktop";
          };
          associations.added = {
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
              "onlyoffice-desktopeditors.desktop";
            "x-scheme-handler/anytype" = "io.anytype.anytype.desktop;anytype.desktop";
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
              "onlyoffice-desktopeditors.desktop";
          };
        };

        # systemDirs = {
        #   data = [
        #     "/usr/share"
        #     "/usr/local/share"
        #   ];
        #   config = ["/etc/xdg"];
        # };
        userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = true;

          # desktop = "${config.home.homeDirectory}/desktop";
          # documents = "${config.home.homeDirectory}/documents";
          # download = "${config.home.homeDirectory}/downloads";
          # music = "${config.home.homeDirectory}/media/music";
          # pictures = "${config.home.homeDirectory}/media/pictures";
          # publicShare = "${config.home.homeDirectory}/public";
          # templates = "${config.home.homeDirectory}/templates";
          # videos = "${config.home.homeDirectory}/media/videos";
          # extraConfig = {
          #   SCREENSHOTS = "${config.xdg.userDirs.pictures}/screenshots";
          # };
        };
        # Default paths:
        # dataHome = "~/.local/share";
        # stateHome = "~/.local/state";
        # cacheHome = "~/.cache";
        # configHome = "~/.config";
      };

      #gtk = {
      #  enable = true;
      #  # theme = {
      #  #   name = "Breeze-dark";
      #  #   package = pkgs.breeze-gtk;
      #  # };
      #  iconTheme = {
      #    name = "Breeze-dark"; package = pkgs.breeze-icons;
      #  };
      #};

      programs.joplin-desktop = {
        enable = false;
        sync = {
          target = "file-system";
        };
      };

      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };

      # programs.calibre = {
      #   enable = true;
      # };

      # programs.screen = {
      #   enable = true;
      #   screenrc = ''
      #     defscrollback 10000
      #     startup_message off
      #   '';
      # };

      xdg.configFile."mpv/input.conf".text = ''
        [ add speed -0.1
        ] add speed 0.1
      '';
    };

  # blazar.desktop.nixos.services.flatpak.packages = [
  #   "com.protonvpn.www"
  #   "it.mijorus.gearlever"
  #   "io.anytype.anytype"
  #   "com.jgraph.drawio.desktop"
  #   "it.mijorus.collector"
  #   "eu.betterbird.Betterbird"
  #   "com.usebottles.bottles"
  #   "org.zotero.Zotero"
  #   "re.sonny.Eloquent"
  # ];
}
