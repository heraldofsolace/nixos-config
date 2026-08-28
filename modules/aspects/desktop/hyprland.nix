{
  inputs,
  self,
  blazar,
  ...
}:
{
  flake-file.inputs = {
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprqt6engine = {
      url = "github:hyprwm/hyprqt6engine";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "latest";
    };

    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "latest";
    };

    dankMaterialShell = {
      url = "github:nick-linux8/DankMaterialShell/master";
      inputs.nixpkgs.follows = "latest";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "latest";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "latest";
    };
    hyprland-profile-switcher.url = "github:heraldofsolace/hyprland-profile-switcher";
    elephant.url = "github:abenz1267/elephant";

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
  };

  blazar.hyprland.nixos =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.sysc-greet.nixosModules.default
      ];

      programs.hyprland = {
        enable = true;
        xwayland = {
          enable = true;
        };
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        # make sure to also set the portal package, so that they are in sync
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
      services.displayManager.sddm.enable = lib.mkForce false;
      security.pam.services.hyprlock = { };
      security.pam.services.ags = { };
      security.pam.services.greetd.enableKwallet = true;
      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };

      hardware.graphics =
        let
          pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          package = pkgs-unstable.mesa;

          # if you also want 32-bit support (e.g for Steam)
          enable32Bit = true;
          package32 = pkgs-unstable.pkgsi686Linux.mesa;
          enable = true;
        };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1"; # hint electron apps to use wayland
        MOZ_ENABLE_WAYLAND = "1"; # ensure enable wayland for Firefox
        WLR_RENDERER_ALLOW_SOFTWARE = "1"; # enable software rendering for wlroots
        WLR_NO_HARDWARE_CURSORS = "1"; # disable hardware cursors for wlroots
      };

      # programs.dank-material-shell.greeter = {
      #   enable = true;
      #   compositor.name = "hyprland"; # Or "hyprland" or "sway"
      #   quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
      #   logs = {
      #     save = true;
      #     path = "/tmp/dms-greeter.log";
      #   };
      #   configHome = "/home/aniket";
      # };

      services.sysc-greet = {
        enable = true;
        compositor = "cagebreak"; # or "hyprland" or "sway"
        cagebreakPackage = pkgs.cagebreak;
      };

      services.atd.enable = true;
      services.atd.allowEveryone = true;
      systemd.tmpfiles.rules = [
        "d '/var/cache/greeter' - greeter greeter - -"
      ];
    };

  blazar.hyprland.includes = [
    blazar.noctalia-v5
    blazar.desktop._.phone-deck
  ];
  blazar.hyprland.homeManager =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      terminal = "waveterm";
      red = config.lib.stylix.colors.base08;
      mauve = config.lib.stylix.colors.base0E;
      green = config.lib.stylix.colors.base0B;
      lavender = config.lib.stylix.colors.base08;
      blue = config.lib.stylix.colors.base0A;
      # awww-script = pkgs.writeShellScriptBin "awww" ''
      #   ${awww-command}
      # '';
      awww-script = pkgs.writeShellScriptBin "awww" ''
        awww img ${./_files/wall.gif}
      '';
    in
    {
      imports = [
        # inputs.hyprland-profile-switcher.homeModules.default
        inputs.walker.homeManagerModules.default
      ];

      home.packages =
        with pkgs;
        with self.packages.${pkgs.stdenv.hostPlatform.system};
        [
          hyprsysteminfo
          hyprpolkitagent
          hyprland-qt-support
          hyprland-qtutils
          inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.default
          grimblast
          uptime-nixos
          hass-report-status
          show-keybindings
          snapshot
          hyprland-gamemode
          jaq
          join
          playerctl
          brightnessctl
          wireplumber
          awww
          awww-schedule
          kdePackages.kwallet-pam
          fzf
          copyq
          xdg-desktop-portal-hyprland
          kitty
          # inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
          # (breeze-hacked-cursor-theme.override {accentColor = "#${red}";})
          # inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      programs.waveterm.enable = true;
      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        # package = pkgs.breeze-hacked-cursor-theme.override {accentColor = "#${red}";};
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.hornet-cursor-theme;
        hyprcursor.enable = true;
        name = "Hornet";
        size = 64;
      };

      services.kdeconnect.enable = true;

      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local config = wezterm.config_builder()
          config.enable_wayland = true
          return config
        '';
      };
      programs.walker = {
        enable = true;
        runAsService = true;

        # All options from the config.json can be used here.
        config = {
          search.placeholder = "Search";
          providers."default" = [
            "desktopapplications"
            "calc"
            "runner"
            "websearch"
            "menus"
          ];
          providers.empty = [ "desktopapplications" ];
          providers.prefixes = [
            {
              provider = "websearch";
              prefix = "+";
            }
            {
              provider = "switcher";
              prefix = "_";
            }
          ];
          keybinds.quick_activate = [
            "F1"
            "F2"
            "F3"
          ];
          list = {
            height = 500;
          };
        };
      };

      services.hyprpaper.enable = lib.mkForce false;

      xdg.desktopEntries."org.gnome.Settings" = {
        name = "Settings";
        comment = "Gnome Control Center";
        icon = "org.gnome.Settings";
        exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
        categories = [ "X-Preferences" ];
        terminal = false;
      };
      xdg.configFile."xdg-desktop-portal/hyprland-portals.conf".text = ''
        [preferred]
        default = hyprland;gtk
        org.freedesktop.impl.portal.FileChooser = kde
      '';

      wayland.windowManager.hyprland = {
        enable = true;
        # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
        package = null;
        portalPackage = null;
        configType = "lua";
      };
      wayland.windowManager.hyprland.systemd.variables = [ "--all" ];
      # wayland.windowManager.hyprland.extraLuaFiles = {
      #   "config" = {
      #     content = ./_files/hyprland.lua;
      #   };
      # };
      home.file.".config/hypr/config.lua".source =
        config.lib.file.mkOutOfStoreSymlink "/home/aniket/my-nix/modules/aspects/desktop/_files/hyprland.lua";
      wayland.windowManager.hyprland.extraConfig =
        let
          yt = pkgs.writeShellScriptBin "yt" ''
            ${lib.getExe pkgs.libnotify} "Opening video" "$(wl-paste)"
            ${lib.getExe pkgs.mpv} "$(wl-paste)"
          '';

          myPkgs = with pkgs; [
            playerctl
            brightnessctl
            wireplumber
            copyq
          ];
          namedPkgs = {
            inherit yt;
            snapshot = self.packages.${pkgs.stdenv.hostPlatform.system}.snapshot;
            awww = awww-script;
            kwallet = pkgs.kdePackages.kwallet-pam;
          };

          vars = {
            mod = "SUPER";
            key = "tab";
            modifier = "alt";
            modifier_release = "ALT_L";
            reverse = "shift";
            TERMINAL = terminal;
            red = "rgb(${red})";
            mauve = "rgb(${mauve})";
            green = "rgb(${green})";
            lavender = "rgb(${lavender})";
            blue = "rgb(${blue})";
          };

          pkgsSet = lib.genAttrs (map (p: p.pname) myPkgs) (
            name: lib.findFirst (p: p.pname == name) null myPkgs
          );

          mergedPkgs = pkgsSet // namedPkgs;

          toLuaTable =
            set: prefix:
            "{\n"
            + lib.concatStringsSep ",\n" (lib.mapAttrsToList (k: v: ''${k} = "${prefix v}"'') set)
            + "\n}";
        in
        # lua
        ''
          package.path = package.path .. ";${./.}/?.lua"
          _G.nix = {
            pkgs = ${toLuaTable mergedPkgs lib.getExe},
            pkgpath = ${toLuaTable mergedPkgs (p: "${p}")},
            vars = ${toLuaTable vars (v: v)},
          }
          require("config")
        '';
    };
}
