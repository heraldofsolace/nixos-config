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
      generate-wallpapers =
        { pkgs, ... }:
        {
          name,
          colors,
          directory,
        }:
        let
          jsonContent = builtins.toJSON {
            inherit name;
            inherit colors;
          };
          themeFile = pkgs.writeText "stylix.json" jsonContent;
        in
        pkgs.runCommand "generate-wallpapers"
          {
            buildInputs = [ pkgs.gowall ];
          }
          ''
            export HOME=$(mktemp -d)
            mkdir -p $out
            echo "${themeFile}"
            gowall convert --dir ${directory} -t ${themeFile} --output $out
          '';
      red = config.lib.stylix.colors.base08;
      mauve = config.lib.stylix.colors.base0E;
      green = config.lib.stylix.colors.base0B;
      # base16 has no dedicated lavender slot (mauve already claims the one
      # purple/magenta slot, base0E); base0C (cyan) is the closest distinct,
      # cool-toned color left, was previously a duplicate of `red`.
      lavender = config.lib.stylix.colors.base0C;
      blue = config.lib.stylix.colors.base0D;
      colors = config.lib.stylix.colors.withHashtag;
      baseNames = builtins.genList (i: lib.toUpper (lib.fixedWidthNumber 2 (lib.toHexString i))) 16;
      colorValues = map (n: colors."base${n}") baseNames;
      # Full base16 passthrough (rgb(...), no leading #) so hyprland.lua can
      # reach any palette slot by name (e.g. nix.vars.base00 for background,
      # nix.vars.base05 for foreground) instead of hardcoding hex that would
      # silently drift from stylix.base16Scheme on a theme change.
      stylixVars = lib.listToAttrs (
        map (n: {
          name = "base${n}";
          value = "rgb(${config.lib.stylix.colors."base${n}"})";
        }) baseNames
      );
      wallpapers = generate-wallpapers { inherit config pkgs; } {
        colors = colorValues;
        name = "stylix";
        directory = ./_files/walls;
      };
      padString = n: if n < 10 then "0" + builtins.toString n else builtins.toString n;
      wallpaper-name = i: "${wallpapers}/${builtins.toString i}.png";
      awww-args = builtins.map (i: "-i \"${wallpaper-name i};${padString i}:00\" ") (lib.range 0 23);
      awww-command = "awww-schedule ${lib.concatStrings awww-args}";
      awww-script = pkgs.writeShellScriptBin "awww" ''
        ${awww-command}
      '';
      # awww-script =
      #   let
      #     myawww = pkgs.awww.overrideAttrs (oldAttrs: {
      #       buildInputs = oldAttrs.buildInputs ++ [ pkgs.dav1d ];
      #       cargoBuildFlags = [ "--features=avif" ];
      #     });
      #   in
      #   pkgs.writeShellScriptBin "awww" ''
      #     ${myawww}/bin/awww img ${./_files/wall.gif}
      #   '';
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
        plugins = [
          inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprfocus
        ];
      };
      wayland.windowManager.hyprland.systemd.variables = [ "--all" ];
      # wayland.windowManager.hyprland.extraLuaFiles = {
      #   "config" = {
      #     content = ./_files/hyprland.lua;
      #   };
      # };
      home.file.".config/hypr/config.lua".source =
        config.lib.file.mkOutOfStoreSymlink "/home/aniket/my-nix/modules/aspects/desktop/_files/hyprland.lua";
      # Keybind cheatsheet, opened as a floating overlay by SUPER+C (see hyprland.lua).
      xdg.dataFile."cheatsheet/index.html".source = ./_files/cheatsheet.html;
      # Isolated Firefox profile for the cheatsheet overlay - kept separate from the
      # real browsing profile so this HUD never touches its history/extensions/cookies.
      # user.js (not prefs.js) so Firefox can still write its own prefs.js alongside it.
      xdg.dataFile."cheatsheet-ff-profile/user.js".text = ''
        user_pref("browser.shell.checkDefaultBrowser", false);
        user_pref("browser.startup.page", 0);
        user_pref("browser.startup.homepage", "about:blank");
        user_pref("browser.aboutwelcome.enabled", false);
        user_pref("browser.tabs.warnOnClose", false);
        user_pref("datareporting.policy.dataSubmissionEnabled", false);
        user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
      '';
      wayland.windowManager.hyprland.extraConfig =
        let
          yt = pkgs.writeShellScriptBin "yt" ''
            ${lib.getExe pkgs.libnotify} "Opening video" "$(wl-paste)"
            ${lib.getExe pkgs.mpv} "$(wl-paste)"
          '';

          # Pushes a flat RGB color to every LED on the Dygma Defy over its
          # Focus-protocol serial port (led.setAll, see FOCUS_API.md). No-ops
          # silently if the keyboard isn't plugged in (e.g. on horologium).
          # led.setAll writes to the keyboard's flash on every call, so this
          # is meant to be called on discrete events (workspace switches),
          # not continuously.
          # Nix binding name must stay hyphen-free: it's exposed to Lua as
          # nix.pkgs.<name>, and `nix.pkgs.keyboard-accent` would parse as
          # subtraction in Lua. The binary itself is still named
          # keyboard-accent.
          keyboardAccent = pkgs.writeShellScriptBin "keyboard-accent" ''
            set -euo pipefail
            device="/dev/serial/by-id/usb-DYGMA_DEFY_C49AE5F2FDE93A35-if00"
            [ -e "$device" ] || exit 0
            printf 'led.setAll %s %s %s\n' "$1" "$2" "$3" > "$device"
          '';

          myPkgs = with pkgs; [
            playerctl
            brightnessctl
            wireplumber
            copyq
          ];
          namedPkgs = {
            inherit yt keyboardAccent;
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
          }
          // stylixVars;

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
