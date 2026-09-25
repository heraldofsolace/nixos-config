{ self, ... }: {
  blazar.shells._.bash.homeManager =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.bash = {
        enable = true;
        shellAliases = lib.mkMerge [
          # commonShellAliases
          {
            # Bash-specific aliases.
          }
        ];
        historyFile = null;
        historySize = null;
        historyFileSize = null;
        enableCompletion = true;
        bashrcExtra = ''
          if [ -x "$(command -v tmux)" ] && { [ -n "''${DISPLAY}" ] || [ -n "''${WAYLAND_DISPLAY}" ]; } && [ -z "''${TMUX}" ]; then
              # No output redirection here: tmx's first-launch path
              # (`tmux new-session`, no server yet) creates *and attaches*
              # in one step, which needs a real tty on stdout. Redirecting
              # it to /dev/null broke that attach silently, leaving an
              # orphaned client (fd 0/1 -> /dev/null, no controlling
              # terminal) and making the terminal exit - only the *next*
              # launch worked, since by then the session already existed
              # and tmx takes the `-d` + separate `attach-session` path.
              exec ${self.packages.${pkgs.stdenv.hostPlatform.system}.tmx}/bin/tmx ''${USER} 1
          fi
          case "$(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm)" in
            "fish"|"systemd")
              ;;
            *)
            if [[ -z ''${BASH_EXECUTION_STRING} ]]; then
              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
            fi ;;
          esac
        '';
      };
    };
}
