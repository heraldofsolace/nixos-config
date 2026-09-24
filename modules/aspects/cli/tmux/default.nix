_: {
  blazar.tmux.homeManager =
    {
      lib,
      pkgs,
      config,
      self',
      ...
    }:
    let
      oh-my-tmux-conf = "oh-my-tmux.conf";
      oh-my-tmux-conf-path = "${config.xdg.configHome}/${oh-my-tmux-conf}";
      oh-tmux-conf-local = "${oh-my-tmux-conf}.local";

      oh-my-tmux = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "oh-my-tmux";

        src = pkgs.fetchFromGitHub {
          owner = "gpakosz";
          repo = ".tmux";
          rev = "58a3dcc0d718ec0fa1c0d5a2fddd640a1ad7a5b7";
          sha256 = "sha256-prLCwof+llElA0ej4t6zlq+S2UcKR0K69NO+3iI4IJg=";
          stripRoot = false;
        };

        version = "58a3dcc0d718ec0fa1c0d5a2fddd640a1ad7a5b7";

        nativeBuildInputs = [
          pkgs.gnused
          pkgs.perl
          pkgs.gawk
        ];

        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          mkdir -p $out
          sed -e 's/$HOME\/.tmux.conf/${
            builtins.replaceStrings [ "/" ] [ "\\/" ] oh-my-tmux-conf-path
          }/g' .tmux-*/.tmux.conf > $out/.tmux.conf
        '';

        meta = with lib; {
          description = "Self-contained, pretty & versatile tmux configuration";
          homepage = "https://github.com/gpakosz/.tmux";
          license = licenses.gpl3Only;
        };
      };
    in
    {
      home.packages = [
        self'.packages.tmx
        pkgs.gnused
        pkgs.perl
        pkgs.gawk
      ];
      programs.tmux = {
        enable = true;

        clock24 = true;
        keyMode = "vi";
        terminal = "xterm-256color";

        plugins = with pkgs; [
          tmuxPlugins.cpu
          {
            plugin = tmuxPlugins.resurrect;
            extraConfig = "set -g @resurrect-strategy-nvim 'session'";
          }
          {
            plugin = tmuxPlugins.continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '15'
            '';
          }
          tmuxPlugins.copycat
          tmuxPlugins.yank
        ];
        tmuxinator.enable = true;
        extraConfig = ''
          source-file "${oh-my-tmux-conf-path}";
        '';
      };

      xdg.configFile = {
        "${oh-my-tmux-conf}" = {
          source = "${oh-my-tmux}/.tmux.conf";
        };
        "${oh-tmux-conf-local}" = {
          source =
            with config.lib.stylix.colors.withHashtag;
            pkgs.replaceVars ./_files/tmux.conf {
              # base16 semantics: https://github.com/chriskempson/base16/blob/main/styling.md
              tmux_conf_theme_colour_1 = "${base00}"; # default background
              tmux_conf_theme_colour_2 = "${base01}"; # lighter background (status bars)
              tmux_conf_theme_colour_3 = "${base02}"; # selection background
              tmux_conf_theme_colour_4 = "${base03}"; # comments, invisibles
              tmux_conf_theme_colour_5 = "${base04}"; # dark foreground (status bars)
              tmux_conf_theme_colour_6 = "${base05}"; # default foreground
              tmux_conf_theme_colour_7 = "${base06}"; # light foreground
              tmux_conf_theme_colour_8 = "${base07}"; # light background
              tmux_conf_theme_colour_9 = "${base08}"; # red
              tmux_conf_theme_colour_10 = "${base09}"; # orange
              tmux_conf_theme_colour_11 = "${base0A}"; # yellow
              tmux_conf_theme_colour_12 = "${base0B}"; # green
              tmux_conf_theme_colour_13 = "${base0C}"; # cyan
              tmux_conf_theme_colour_14 = "${base0D}"; # blue
              tmux_conf_theme_colour_15 = "${base0E}"; # magenta/purple
              tmux_conf_theme_colour_16 = "${base0F}"; # brown
              tmux_conf_theme_colour_17 = "${base07}"; # light background, was hardcoded #e4e4e4
            };
        };
      };
    };
}
