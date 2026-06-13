{
  blazar.shells._.carapace.homeManager =
    { lib, pkgs, ... }:
    let
      carapaceBridges = [
        "argcomplete"
        "bash"
        "carapace"
        "carapace-bin"
        "clap"
        "click"
        "cobra"
        "complete"
        "fish"
        "inshellisense"
        "kingpin"
        "macro"
        "powershell"
        "urfavecli"
        "yargs"
        "zsh"
        "fzf"
      ];
      carapaceBridgesStr = lib.concatStringsSep "," carapaceBridges;
    in

    {
      programs.carapace = {
        enable = true;
      };

      home.packages = with pkgs; [
        carapace-bridge
      ];

      programs.fish.interactiveShellInit = lib.mkMerge [
        # fish
        ''
          set -Ux CARAPACE_BRIDGES ${carapaceBridgesStr}
          # set -Ux CARAPACE_ENV 1
          set -Ux CARAPACE_MATCH 1
          set -Ux CARAPACE_NOSPACE '*'
          # set -Ux CARAPACE_MERGEFLAGS 0
          set -Ux CARAPACE_UNFILTERED 1


          # carapace _carapace | source
        ''
      ];
    };
}
