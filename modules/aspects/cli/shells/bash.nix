{self, ...}: {
  blazar.shells._.bash.homeManager = {
    lib,
    pkgs,
    ...
  }: {
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
        if [ -x "$(command -v tmux)" ] && [ -n "''${DISPLAY}" ] && [ -z "''${TMUX}" ]; then
            exec ${self.packages.${pkgs.stdenv.hostPlatform.system}.tmx}/bin/tmx ''${USER} 1 >/dev/null 2>&1
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
