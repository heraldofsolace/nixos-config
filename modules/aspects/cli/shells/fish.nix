{ lib', ... }: {
  blazar.shells._.fish.homeManager =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe;
      inherit (lib') getExeName getExeName';

      inherit (pkgs.python3Packages) sparklines;

      runIfCommandExists = commandToCheck: command: ''
        if type ${commandToCheck} &> /dev/null
          ${command}
        end
      '';
    in
    {
      home.packages = with pkgs; [
        fzf
        htop
        tealdeer
        television
        dig
        manix
        claude-code
        # protonup
      ];
      # tmux auto-launch and bash->fish handoff live in bash.nix's
      # programs.bash.bashrcExtra, not here (this used to be duplicated in
      # both files).
      programs.fish = {
        enable = true;
        preferAbbrs = true;
        shellAliases = {
          # nix
          nrb = "sudo nixos-rebuild";
          # systemd
          ctl = "systemctl";
          stl = "s systemctl";
          utl = "systemctl --user";
          ut = "systemctl --user start";
          un = "systemctl --user stop";
          up = "s systemctl start";
          dn = "s systemctl stop";
          jtl = "journalctl";

          # quick cd
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";

          # git
          g = "git";

          # grep
          grep = "rg";
          gi = "grep -i";

          # internet ip
          # TODO: explain this hard-coded IP address
          myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

          # nix
          n = "nix";
          np = "n profile";
          ni = "np install";
          nr = "np remove";
          ns = "n search --no-update-lock-file";
          nf = "n flake";
          nepl = "n repl '<nixpkgs>'";
          srch = "ns nixos";
          orch = "ns override";
          mn = ''
            manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix
          '';
          top = "htop";

          # sudo
          s = "sudo -E ";
          si = "sudo -i";
          se = "sudoedit";

          # bat
          cat = "bat --style header --style snip --style changes";
        };
        shellInit = lib.mkMerge [
          ''
            # Disable the fish greeting message.
            set -U fish_greeting

            # function fish_greeting
            #   fortune -a
            # end
          ''

          # ''
          #   if test ! -d ~/.config/fish/functions/fisher.fish
          #     curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
          #   end
          # ''
        ];
        interactiveShellInit = lib.mkMerge [
          ''
            # Print expanded commands after each command invocation before the output.
            if status --is-interactive
              function preexec
                [ $1 != $2 ] && print -rP '%F{green}> $2%f'
              end
            end
          ''

          /* fish */ ''
            fish_vi_key_bindings
            set fish_cursor_default block
            set fish_cursor_insert line
            set fish_cursor_replace_one underscore
            set fish_cursor_visual block
            set fish_cursor_unknown block
            # bind --mode insert --sets-mode default jk repaint
          ''

          # fish
          ''
            # Printing colourful spark lines at the top of the terminal.
            print_terminal_line_sparklines
          ''
        ];
        shellInitLast = lib.mkMerge [
          ''
            # (builtins.readFile (
            #   builtins.fetchurl {
            #     url = "https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish";
            #     sha256 = "sha256:124nflgy5qpzah1ldz75wr39zdwzg65drsfz1ynz50m1pl3hsr2r";
            #   }
            # ))
            # fisher install jorgebucaran/fisher
          ''
        ];
        functions = {
          print_terminal_line_sparklines = {
            description = "Print colourful sparklines";
            body = "seq 1 $(tput cols) | sort -R | ${getExe sparklines} | ${getExeName pkgs.lolcat}";
          };

          # Printing colourful spark lines at the top of the terminal before the prompt.
          clear_screen = {
            description = "Custom clear screen";
            body = ''
              command clear -x
              print_terminal_line_sparklines
              # echo
              # echo
              commandline --function repaint
            '';
          };
          clear_screen_newlines = {
            description = "Custom clear screen with inserted newlines";
            body = ''
              command clear -x
              print_terminal_line_sparklines
              echo
              echo
              commandline --function repaint
            '';
          };

          fish_user_key_bindings = {
            description = "Custom user key bindings";
            body = ''
              bind --user --mode insert ctrl-l clear_screen_newlines
              # fish_vi_key_bindings calls vi's normal/command mode "default", not "command"
              bind --user --mode default ctrl-l clear_screen_newlines
            '';
          };

          update-system = {
            description = "Update all system components";
            body = ''
              # System.
              nix flake update --flake ${config.home.homeDirectory}/my-nix
              ${getExe pkgs.nh} os switch -- --impure
              ${getExe pkgs.nh} home switch -- --impure
              # ${getExe pkgs.flatpak} update --assumeyes

              ${getExe pkgs.television} update-channels
              ${getExe pkgs.tealdeer} --update

              # Games.
              ${runIfCommandExists "protonup" "protonup"}

              # if command -v pipx >/dev/null; then pipx upgrade-all; fi
            '';
          };

          home-manager-news = {
            description = "Get the home-manager news";
            body = ''
              ${getExeName pkgs.home-manager} news --flake .
            '';
          };

          list-desktop-files = {
            description = "Get list of desktop files";
            body = ''
              begin
                ls /run/current-system/sw/share/applications # For global packages.
                ls ~/.nix-profile/share/applications # For home-manager packages.
              end | sort
            '';
          };

          update-cheatsheet = {
            description = "Resume the dedicated cheatsheet-maintenance Claude Code session";
            body = ''
              set -l msg (string join ' ' $argv)
              if test -z "$msg"
                set msg "Check git status/diff for what changed and update the cheatsheet accordingly."
              end
              set msg "$msg After updating modules/aspects/desktop/_files/cheatsheet.html, also republish it to the existing claude.ai artifact at https://claude.ai/code/artifact/3d5ffbb7-f8ac-454f-a93b-4ed444b92a50 (same URL, so it keeps updating in place) - strip the standalone <!DOCTYPE>/<html>/<head>/<body> wrapper first, since the Artifact tool adds its own."
              ${getExe pkgs.claude-code} --resume bcd27ae9-5246-4211-816e-2ff5702bd1e3 "$msg"
            '';
          };

          fzf-open-edit = {
            description = "Open file for editing using fzf";
            body =
              # fish
              ''
                set -l files (
                  ${getExeName' pkgs.fzf "fzf-tmux"} --query="$argv[1]" --multi --select-1 --exit-0 --preview "${getExeName pkgs.bat} --style=numbers --color=always --line-range :500 {}"
                )
                if test -n "$files"
                  $EDITOR $files
                end
              '';
          };

          # pushd_on_pwd_change = {
          #   description = "Push target to dirs stack on PWD change in interactive mode.";
          #   onVariable = "PWD";
          #   body = # fish
          #     ''
          #       if not status --is-interactive; or status --is-command-substitution
          #         return
          #       end

          #       # set -l MAX_DIR_HIST 25

          #       # Get the top entry of the stack (previous directory)
          #       set stack_top (dirs -n 1)

          #       # Only push if the previous stack entry is not the current directory and is not empty
          #       if test -n "$stack_top" -a "$stack_top" != "$PWD"
          #           pushd $stack_top > /dev/null
          #       end

          #       # FIZME: According to https://github.com/fish-shell/fish-shell/blob/master/share/functions/cd.fish.
          #       # if test "$PWD" != "$previous"
          #       #     set -q dirprev
          #       #     or set -l dirprev
          #       #     set -q dirprev[$MAX_DIR_HIST]
          #       #     and set -e dirprev[1]

          #       #     # If dirprev, dirnext, __fish_cd_direction
          #       #     # are set as universal variables, honor their scope.

          #       #     set -U -q dirprev
          #       #     and set -U -a dirprev $previous
          #       #     or set -g -a dirprev $previous

          #       #     set -U -q dirnext
          #       #     and set -U -e dirnext
          #       #     or set -e dirnext

          #       #     set -U -q __fish_cd_direction
          #       #     and set -U __fish_cd_direction prev
          #       #     or set -g __fish_cd_direction prev
          #       # end
          #     '';
          # };
        };
        plugins =
          let
            packagedPluginsFromList =
              plugins:
              map (plugin: {
                name = "${plugin}";
                inherit (pkgs.fishPlugins."${plugin}") src;
              }) plugins;
          in
          (packagedPluginsFromList [
            "autopair"
            "bang-bang"
            # "fifc"
            "bass"
            "colored-man-pages"
            "done"
            "fzf-fish"
            # "grc"
            "humantime-fish"
            "plugin-git"
            "fish-bd"
            "forgit"
          ])
          ++ [
            # {
            #   name = "fzf-fish";
            #   src = pkgs.fishPlugins.fzf-fish.src;
            # }

            # Using this to get shell completion for programs added to the path through nix+direnv.
            # Issue to upstream into direnv: https://github.com/direnv/direnv/issues/443.
            {
              name = "completion-sync";
              src = pkgs.fetchFromGitHub {
                owner = "iynaix";
                repo = "fish-completion-sync";
                rev = "master";
                sha256 = "sha256-kHpdCQdYcpvi9EFM/uZXv93mZqlk1zCi2DRhWaDyK5g=";
              };
            }
          ];
      };
      # xdg.configFile."fish/conf.d/script_loaded_before_every_shell.fish".text = ''
      # '';

      # xdg.configFile."fish/themes/fish_default_green.theme".source = ./fish_default_green.theme;

      xdg.configFile."fish/completions/nix.fish".source =
        "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";
    };
}
