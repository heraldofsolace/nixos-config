_: {
  blazar.tmux.homeManager = {
    lib,
    pkgs,
    config,
    self',
    ...
  }: let
    oh-my-tmux-conf = "oh-my-tmux.conf";
    oh-my-tmux-conf-path = "${config.xdg.configHome}/${oh-my-tmux-conf}";
    oh-tmux-conf-local = "${oh-my-tmux-conf}.local";

    oh-my-tmux = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "oh-my-tmux";

      src = pkgs.fetchFromGitHub {
        owner = "gpakosz";
        repo = ".tmux";
        rev = "af33f07134b76134acca9d01eacbdecca9c9cda6";
        sha256 = "sha256-zXI1c9Mj8AJCAquOP4W1MCH7nIzisYjMcW7WuSZ+/yI=";
        stripRoot = false;
      };

      version = "af33f07134b76134acca9d01eacbdecca9c9cda6";

      nativeBuildInputs = [pkgs.gnused pkgs.perl pkgs.gawk];

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        mkdir -p $out
        sed -e 's/$HOME\/.tmux.conf/${builtins.replaceStrings ["/"] ["\\/"] oh-my-tmux-conf-path}/g' .tmux-*/.tmux.conf > $out/.tmux.conf
      '';

      meta = with lib; {
        description = "Self-contained, pretty & versatile tmux configuration";
        homepage = "https://github.com/gpakosz/.tmux";
        license = licenses.gpl3Only;
      };
    };
  in {
    home.packages = [self'.packages.tmx pkgs.gnused pkgs.perl pkgs.gawk];
    programs.tmux = {
      enable = true;

      clock24 = true;
      keyMode = "vi";
      shortcut = "b";
      terminal = "xterm-256color";

      plugins = with pkgs; [
        tmuxPlugins.cpu
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        tmuxPlugins.copycat
        tmuxPlugins.yank
      ];
      tmuxinator.enable = true;
      extraConfig = ''
        source-file "${oh-my-tmux-conf-path}";
      '';
    };

    # xdg.configFile."tmux/tmux.conf".text = "";
    # xdg.configFile."tmux/tmux.conf".source = "${oh-my-tmux}/.tmux.conf";

    xdg.configFile = {
      "${oh-my-tmux-conf}" = {
        source = "${oh-my-tmux}/.tmux.conf";
      };
      "${oh-tmux-conf-local}" = {
        source = with config.lib.stylix.colors.withHashtag;
          pkgs.replaceVars ./_files/tmux.conf {
            tmux_conf_theme_colour_1 = "${base00}"; # dark gray
            tmux_conf_theme_colour_2 = "${base01}"; # gray
            tmux_conf_theme_colour_3 = "${base02}"; # light gray
            tmux_conf_theme_colour_4 = "${base03}"; # light blue
            tmux_conf_theme_colour_5 = "${base04}"; # yellow
            tmux_conf_theme_colour_6 = "${base05}"; # dark gray
            tmux_conf_theme_colour_7 = "${base06}"; # white
            tmux_conf_theme_colour_8 = "${base07}"; # dark gray
            tmux_conf_theme_colour_9 = "${base08}"; # yellow
            tmux_conf_theme_colour_10 = "${base09}"; # pink
            tmux_conf_theme_colour_11 = "${base0A}"; # green
            tmux_conf_theme_colour_12 = "${base0B}"; # light gray
            tmux_conf_theme_colour_13 = "${base0C}"; # white
            tmux_conf_theme_colour_14 = "${base0D}"; # dark gray
            tmux_conf_theme_colour_15 = "${base0E}"; # dark gray
            tmux_conf_theme_colour_16 = "${base0F}"; # red
            tmux_conf_theme_colour_17 = "#e4e4e4"; # white
          };
      };
    };
  };
}
