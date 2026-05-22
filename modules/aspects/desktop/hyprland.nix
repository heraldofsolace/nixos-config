{
  inputs,
  self,
  blazar,
  ...
}: {
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
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "latest";
    };

    sysc-greet = {
      url = "github:deephack1982/sysc-greet";
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
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "latest";
    };
    hyprland-profile-switcher.url = "github:heraldofsolace/hyprland-profile-switcher";
    elephant.url = "github:abenz1267/elephant";

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
  };

  blazar.hyprland.nixos = {
    pkgs,
    lib,
    ...
  }: {
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
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    services.displayManager.sddm.enable = lib.mkForce false;
    security.pam.services.hyprlock = {};
    security.pam.services.ags = {};
    security.pam.services.greetd.enableKwallet = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    hardware.graphics = let
      pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
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
      compositor = "hyprland"; # or "hyprland" or "sway"
    };

    services.atd.enable = true;
    services.atd.allowEveryone = true;
    systemd.tmpfiles.rules = [
      "d '/var/cache/greeter' - greeter greeter - -"
    ];
  };

  blazar.hyprland.includes = [
    blazar.noctalia
  ];
  blazar.hyprland.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: let
    terminal = "wezterm";
    generate-wallpapers = {pkgs, ...}: {
      name,
      colors,
      directory,
    }: let
      jsonContent = builtins.toJSON {
        inherit name;
        inherit colors;
      };
      themeFile = pkgs.writeText "stylix.json" jsonContent;
    in
      pkgs.runCommand "generate-wallpapers" {
        buildInputs = [pkgs.gowall];
      } ''
        export HOME=$(mktemp -d)
        mkdir -p $out
        echo "${themeFile}"
        gowall convert --dir ${directory} -t ${themeFile} --output $out
      '';
    red = config.lib.stylix.colors.base08;
    mauve = config.lib.stylix.colors.base0E;
    green = config.lib.stylix.colors.base0B;
    lavender = config.lib.stylix.colors.base08;
    blue = config.lib.stylix.colors.base0A;
    colors = config.lib.stylix.colors.withHashtag;
    baseNames = builtins.genList (i: lib.toUpper (lib.fixedWidthNumber 2 (lib.toHexString i))) 16;
    colorValues = map (n: colors."base${n}") baseNames;
    wallpapers = generate-wallpapers {inherit config pkgs;} {
      colors = colorValues;
      name = "stylix";
      directory = ./_files/walls;
    };
    padString = n:
      if n < 10
      then "0" + builtins.toString n
      else builtins.toString n;
    wallpaper-name = i: "${wallpapers}/${builtins.toString i}.png";
    swww-args = builtins.map (i: "-i \"${wallpaper-name i};${padString i}:00\" ") (lib.range 0 23);
    swww-command = "swww-schedule ${lib.concatStrings swww-args}";
    swww-script = pkgs.writeShellScript "swww" ''
      ${swww-command}
    '';
  in {
    imports = [
      inputs.hyprland-profile-switcher.homeModules.default
      inputs.walker.homeManagerModules.default
    ];

    home.packages = with pkgs;
    with self.packages.${pkgs.stdenv.hostPlatform.system}; [
      hyprsysteminfo
      hyprland-qt-support
      hyprland-qtutils
      grimblast
      uptime-nixos
      hass-report-status
      show-keybindings
      snapshot
      hyprland-gamemode
      jaq
      playerctl
      brightnessctl
      wireplumber
      swww
      swww-schedule
      kdePackages.kwallet-pam
      fzf
      copyq
      xdg-desktop-portal-hyprland
      # inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
      # (breeze-hacked-cursor-theme.override {accentColor = "#${red}";})
      # inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.breeze-hacked-cursor-theme.override {accentColor = "#${red}";};
      hyprcursor.enable = true;
      name = "Breeze_Hacked";
      size = 32;
    };

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
        providers.empty = ["desktopapplications"];
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
        keybinds.quick_activate = ["F1" "F2" "F3"];
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
      categories = ["X-Preferences"];
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
    };
    wayland.windowManager.hyprland.systemd.variables = ["--all"];
    wayland.windowManager.hyprland.settings = let
      # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
      workspaces = builtins.concatLists (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in [
            "$mod, ${ws}, workspace, ${toString (x + 1)}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
          ]
        )
        10);
      yt = pkgs.writeShellScript "yt" ''
        notify-send "Opening video" "$(wl-paste)"
        mpv "$(wl-paste)"
      '';
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
    in {
      "$mod" = "SUPER";
      "$key" = "tab";
      "$modifier" = "alt";
      "$modifier_release" = "ALT_L";
      "$reverse" = "shift";
      "$TERMINAL" = terminal;
      env = [
        # Cursor size
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,32"

        # # Cursor theme
        # "XCURSOR_THEME,Breeze-Hacked"
        # "HYPRCURSOR_THEME,Breeze-Hacked"

        # Force all apps to use Wayland
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_STYLE_OVERRIDE,Fusion"
        # "SDL_VIDEODRIVER,wayland"
        "MOZ_ENABLE_WAYLAND,1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "OZONE_PLATFORM,wayland"

        # Make Chromium use XCompose and all Wayland
        "CHROMIUM_FLAGS,\"--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4\""

        # Make .desktop files available for wofi
        "XDG_DATA_DIRS,$XDG_DATA_DIRS:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share"

        # Use XCompose file
        "XCOMPOSEFILE,~/.XCompose"
        "EDITOR,nvim"

        # GTK theme
        "GTK_THEME,Adwaita:dark"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      # Don't show update on first launch
      ecosystem = {
        no_update_news = true;
      };
      exec-once = [
        "swww-daemon"
        swww-script
        "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
        "copyq --start-server"
        ''bash -c "wl-paste --watch cliphist store &"''
        "systemctl --user start hyprpolkitagent"
        # "dms run"
        "noctalia-shell"
      ];
      exec = [
        # "hyprshade auto"
        "hass-report-status http://192.168.0.44:8123/api/webhook/eaea48a1-30e3-47bf-a076-30f816f0d3d1 true"
      ];
      workspace = [
        "special:term, on-created-empty:wezterm-gui"
        "special:file, on-created-empty:dolphin"
        "m[HDMI-A-1], layout:scrolling"
        "m[DP-3], layout:master"
      ];
      animations = {
        animation = [
          "windows, 1, 8, md3_decel, slide top"
          "windowsIn, 1, 8, md3_standard, slide top 0%"
          "windowsOut, 1, 8, md3_standard, slide top 0%"
          "windowsMove, 1, 8, md3_standard, slide top 20%"
          "layersIn, 1, 4, menu_accel, slide top 20%"
          "layersOut, 1, 4, menu_decel, slide top 20%"
          "fadeIn, 1, 8, default"
          "fadeOut, 1, 8, default"
          "fadeSwitch, 1, 8, default"
          "fadeShadow, 1, 8, default"
          "fadeDim, 1, 8, default"
          "fadeLayersIn, 1, 8, default"
          "fadeLayersOut, 1, 8, default"
          "border, 1, 6, linear"
          "borderangle, 1, 100, linear, loop"
          "fadeIn, 1, 10, default"
          "workspaces, 1, 8, default, slidevert"
        ];
        bezier = [
          "linear, 0.0, 0.0, 1.0, 1.0"
          "md3_standard, 0.2, 0, 0, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "crazyshot, 0.1, 1.5, 0.76, 0.92"
          "hyprnostretch, 0.05, 0.9, 0.1, 1.1"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.38, 0.04, 1, 0.07"
          "easeOutBack, 0.34, 1.3, 0.64, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
          "popIn, 0.05, 0.9, 0.1, 1.05"
          "softAcDecel, 0.26, 0.26, 0.15, 1"
          "md2, 0.4, 0, 0.2, 1"
        ];
      };

      misc = {
        vrr = 2;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      group = {
        "col.border_active" = lib.mkForce "rgb(${mauve}) rgb(${red}) rgb(${blue}) 45deg";
        "col.border_inactive" = lib.mkForce "rgb(${green}) rgb(${mauve}) 45deg";
        "col.border_locked_active" = lib.mkForce "rgb(${mauve}) rgb(${blue}) 45deg";
        "col.border_locked_inactive" = lib.mkForce "rgb(${green}) rgb(${mauve}) 45deg";
        groupbar = {
          font_size = 10;
          text_color = "rgb(${config.lib.stylix.colors.base05})";
        };
      };

      windowrule = let
        f = regex: "match:class ^(${regex})$, float on";
      in [
        (f "com.github.hluk.copyq")
        "size 622 652, match:class ^(com.github.hluk.copyq)$"
        "stay_focused on, match:class ^(com.github.hluk.copyq)$"
        "center on, match:class ^(com.github.hluk.copyq)$"
        "size 1800 1000, match:class ^(com.github.hluk.copyq)$"
        (f "system-monitoring-center")
        "center on, match:class ^(system-monitoring-center)$"
        "size 1800 1000, match:class ^(system-monitoring-center)$"
        "float on, match:class ([Tt]hunar), match:title (File Operation Progress)"
        "float on, match:class ([Tt]hunar), match:title (Confirm to replace files)"

        "float on, match:class (codium|codium-url-handler|VSCodium|code-oss), match:title (Add Folder to Workspace)"
        "float on, match:class (electron), match:title (Add Folder to Workspace)"
        "float on, match:class ^(nm-applet|nm-connection-editor|blueman-manager)$"
        "float on, match:class ^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$ " # system monitor
        "float on, match:title (Kvantum Manager)"
        "float on, match:class ^([Qq]alculate-gtk)$"
        "float on, match:title ^(Picture-in-Picture)$"

        "no_initial_focus on,match:class ^(.*jetbrains.*)$,match:title ^(win[0-9]+)$"

        "tag +picture-in-picture, match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
        "float on, match:tag picture-in-picture"
        "keep_aspect_ratio on, match:tag picture-in-picture"
        "move 73% 72%,match:tag picture-in-picture"
        "size 25% 25%,match:tag picture-in-picture"
        "float on, match:tag picture-in-picture"
        "pin on,match:tag picture-in-picture"
      ];

      bind = let
        snapshot = "${self.packages.${pkgs.stdenv.hostPlatform.system}.snapshot}/bin/blazar-snapshot";
        show-keybindings = "${self.packages.${pkgs.stdenv.hostPlatform.system}.show-keybindings}/bin/blazar-show-keybindings";
      in
        [
          "$mod, Return, exec, ${terminal}"
          "SUPER ALT, Return, exec, firefox"
          "SUPER SHIFT, K, exec, ${show-keybindings}"
          "SUPER, V, exec, copyq toggle"
          "SUPER SHIFT, ESCAPE, exec, dms ipc call powermenu toggle"
          "SUPER, Q, killactive"
          "$mod, ESCAPE, exec, dms ipc call lock lock"

          "$mod, G, togglegroup,"
          "$mod SHIFT, N, changegroupactive, f"
          "$mod SHIFT, P, changegroupactive, b"

          # move focus
          "$mod, s, layoutmsg, focus l"
          "$mod, t, layoutmsg, focus r"
          "$mod, m, layoutmsg, focus u"
          "$mod, n, layoutmsg, focus d"

          "$mod, s, layoutmsg, cyclenext"
          "$mod, t, layoutmsg, cycleprev"
          "$mod, m, layoutmsg, swapnext"
          "$mod, n, layoutmsg, swapprev"

          "$mod CTRL, s, layoutmsg, move -col"
          "$mod CTRL, t, layoutmsg, move +col"
          "$mod CTRL, m, movewindow, u"
          "$mod CTRL, n, movewindow, d"

          "CTRL ALT, t, layoutmsg, colresize +conf"
          "CTRL ALT, s, layoutmsg, colresize -conf"

          "$mod ALT, s, movewindow, l, nomode"
          "$mod ALT, t, movewindow, r, nomode"
          "$mod ALT, m, movewindow, u, nomode"
          "$mod ALT, n, movewindow, d, nomode"

          "SUPER SHIFT, s, layoutmsg, swapcol l"
          "SUPER SHIFT, t, layoutmsg, swapcol r"
          "SUPER SHIFT, m, swapwindow, u"
          "SUPER SHIFT, n, swapwindow, d"

          "SUPER, bracketleft, workspace, -1"
          "SUPER, bracketright, workspace, +1"

          "SUPER, mouse_down, workspace, e+1"
          "SUPER, mouse_up, workspace, e-1"
          ", XF86Launch1,  exec, ${yt}"

          # screenshot
          # area
          '', Print, exec, ${snapshot} area ''

          # current screen
          ''CTRL, Print, exec, ${snapshot} active ''

          # all screen
          ''ALT, Print, exec, ${snapshot} output ''

          # special workspace
          "$mod SHIFT, y, movetoworkspace, special"
          "$mod, y, togglespecialworkspace, eDP-1"

          # cycle workspaces
          "$mod SHIFT, bracketleft, workspace, m-1"
          "$mod SHIFT, bracketright, workspace, m+1"

          # cycle monitors
          "$mod CTRL, bracketleft, focusmonitor, l"
          "$mod CTRL, bracketright, focusmonitor, r"

          # send focused workspace to left/right monitors
          "$mod SHIFT ALT, bracketleft, movecurrentworkspacetomonitor, u"
          "$mod SHIFT ALT, bracketright, movecurrentworkspacetomonitor, d"

          "$mod, M, togglespecialworkspace, magic"
          "$mod, M, movetoworkspace, +0"
          "$mod, M, togglespecialworkspace, magic"
          "$mod, M, movetoworkspace, special:magic"
          "$mod, M, togglespecialworkspace, magic"

          "$mod SHIFT, G, exec, hyprland-profile-switcher --select \"walker -d\""
          "CTRL ALT, Delete, exit"
          "SUPER, L, exec, walker"
          "$mod, X, exec, noctalia-shell ipc call notifications toggleHistory"
          "$mod, escape, exec, noctalia-shell ipc call lockScreen lock"
          "$mod SHIFT, escape, exec, noctalia-shell ipc call sessionMenu toggle"

          "$mod, z, togglespecialworkspace, term"
          "$mod, j, togglespecialworkspace, file"
        ]
        ++ workspaces;
      bindl = [
        ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay,    exec, ${playerctl} play-pause"
        ",XF86AudioStop,    exec, ${playerctl} pause"
        ",XF86AudioPause,   exec, ${playerctl} pause"
        ",XF86AudioPrev,    exec, ${playerctl} previous"
        ",XF86AudioNext,    exec, ${playerctl} next"
      ];
      bindr = [
      ];
      bindel = [
        ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${wpctl} set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86MonBrightnessUp,   exec, ${brightnessctl} set +5%"
        ",XF86MonBrightnessDown, exec, ${brightnessctl} set  5%-"
      ];
      bindm = [
        "SUPER,mouse:272,movewindow"
      ];
      monitor = [
        "DP-3,2560x1440@165,0x0,1"
        "HDMI-A-1,3840x2160@60,2560x0,1.5"
        ",preferred,auto,1"
      ];

      layerrule = [
        "blur on,match:namespace quickshell:bar"
        "blur on, match:namespace quickshell:popout"
        "blur on, match:namespace quickshell:modal"
        "match:namespace quickshell:bar, no_screen_share on"
        "match:namespace quickshell:popout, no_screen_share on"
        "match:namespace quickshell:modal, no_screen_share on"
      ];
    };

    # wayland.windowManager.hyprland.submaps.settings = {
    #   sizing = {
    #     bind = [
    #       ", 1, scroller:setsize, oneeighth"
    #       ", 1, submap, reset"
    #       ", 2, scroller:setsize, onesixth"
    #       ", 2, submap, reset"
    #       ", 3, scroller:setsize, onefourth"
    #       ", 3, submap, reset"
    #       ", 4, scroller:setsize, onethird"
    #       ", 4, submap, reset"
    #       ", 5, scroller:setsize, threeeighths"
    #       ", 5, submap, reset"
    #       ", 6, scroller:setsize, onehalf"
    #       ", 6, submap, reset"
    #       ", 7, scroller:setsize, fiveeighths"
    #       ", 7, submap, reset"
    #       ", 8, scroller:setsize, twothirds"
    #       ", 8, submap, reset"
    #       ", 9, scroller:setsize, threequarters"
    #       ", 9, submap, reset"
    #       ", 0, scroller:setsize, fivesixths"
    #       ", 0, submap, reset"
    #       ", minus, scroller:setsize, seveneighths"
    #       ", minus, submap, reset"
    #       ", equal, scroller:setsize, one"
    #       ", equal, submap, reset"
    #       ", escape, submap, reset"
    #     ];
    #   };
    #   center = {
    #     bind =[
    #       ", C, scroller:alignwindow, c"
    #       ", C, submap, reset"
    #       ", f, scroller:alignwindow, m"
    #       ", f, submap, reset"
    #       ", t, scroller:alignwindow, r"
    #       ", t, submap, reset"
    #       ", s, scroller:alignwindow, l"
    #       ", s, submap, reset"
    #       ", m, scroller:alignwindow, u"
    #       ", m, submap, reset"
    #       ", n, scroller:alignwindow, d"
    #       ", n, submap, reset"
    #       ", escape, submap, reset"
    #     ];
    #   };

    #   resize = {
    #     bind = [
    #       ", t, resizeactive, 100 0"
    #       ", s, resizeactive, -100 0"
    #       ", m, resizeactive, 0 -100"
    #       ", n, resizeactive, 0 100"
    #       ", escape, submap, reset"
    #     ];
    #   };
    #   fitsize = {
    #     bind = [
    #       ", W, scroller:fitsize, visible"
    #       ", W, submap, reset"
    #       ", t, scroller:fitsize, toend"
    #       ", t, submap, reset"
    #       ", s, scroller:fitsize, tobeg"
    #       ", s, submap, reset"
    #       ", m, scroller:fitsize, active"
    #       ", m, submap, reset"
    #       ", n, scroller:fitsize, all"
    #       ", n, submap, reset"
    #       ", bracketleft, scroller:fitwidth, all"
    #       ", bracketleft, submap, reset"
    #       ", bracketright, scroller:fitheight, all"
    #       ", bracketright, submap, reset"
    #       ", escape, submap, reset"
    #     ];
    #   };
    # };

    wayland.windowManager.hyprland.hyprland-profile-switcher = {
      enable = true;
      profiles = [
        {
          name = "default";
          settings = {
            decoration = {
              rounding = 10;
              dim_inactive = false;
              active_opacity = 0.95;
              blur = {
                enabled = true;
                size = 6;
                passes = 3;
                ignore_opacity = true;
                new_optimizations = true;
                xray = false;
                brightness = 1;
                noise = 0.01;
                contrast = 1;
                popups = true;
                popups_ignorealpha = 0.6;
              };
              shadow = {
                offset = "0, 0";
                range = 30;
                render_power = 3;
                color = "0x66000000";
              };
            };

            general = {
              gaps_in = 3;
              gaps_out = 8;
              border_size = 2;
              "col.active_border" = "rgb(${lavender}) rgb(${mauve}) rgb(${red}) 45deg";
              "col.inactive_border" = "rgba(00000000)";

              resize_on_border = true;
            };

            windowrule = [
              # windowrule v2 - opacity #enable as desired
              "opacity 0.9 0.9, match:class ^(Brave-browser(-beta|-dev)?)$"
              "opacity 0.9 0.9, match:class ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
              "opacity 0.9 0.9, match:class ^(google-chrome(-beta|-dev|-unstable)?)$"
              "opacity 0.94 0.86, match:class ^(chrome-.+-Default)$ " # Chrome PWAs
              "opacity 0.9 0.8, match:class ^([Tt]hunar|org.gnome.Nautilus)$"
              "opacity 0.9 0.8, match:class ^(deluge)$"
              "opacity 0.8 0.7, match:class ^(org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$" # Terminals
              "opacity 0.8 0.8, match:class ^(VSCodium|codium-url-handler|code-oss)$"
              "opacity 0.8 0.8, match:class ^([Cc]ode)$"
              "opacity 0.9 0.8, match:class ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
              "opacity 0.8 0.8, match:class ^(kvantummanager)"
              "opacity 0.9 0.7, match:class ^(com.obsproject.Studio)$"
              "opacity 0.9 0.7, match:class ^([Aa]udacious)$"
              "opacity 1 1, match:class ^(VSCode|code-url-handler)$"
              "opacity 1 1, match:class ^(jetbrains-.+)$" # JetBrains IDEs
              "opacity 0.94 0.86, match:class ^([Dd]iscord|[Vv]esktop)$"
              "opacity 0.9 0.8, match:class ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
              "opacity 0.82 0.75, match:class ^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$"
              "opacity 0.9 0.8, match:class ^(xdg-desktop-portal-gtk)$" # gnome-keyring gui
              "opacity 0.95 0.75, match:title ^(Picture-in-Picture)$"
            ];
          };
        }

        {
          name = "gaming";
          settings = {
            animations = {
              enabled = false;
            };
            decoration = {
              shadow = {
                enabled = false;
              };
              blur = {
                enabled = false;
              };
              fullscreen_opacity = 1;
              rounding = 0;
            };
            general = {
              gaps_in = 0;
              gaps_out = 0;
              border_size = 1;
            };
            windowrule = [
              "opacity 1 1, match:class ^(.*)$"
            ];
          };
        }
      ];
    };
    wayland.windowManager.hyprland.extraConfig = ''
      debug:disable_logs = false
    '';
  };
}
