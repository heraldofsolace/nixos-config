{blazar, ...}: {
  blazar.shells.includes = with blazar; [
    shells._.starship
    shells._.bash
    shells._.fish
  ];

  blazar.shells.homeManager = {
    home.shell.enableShellIntegration = true;

    home.sessionVariables = {
      "NIXPKGS_ALLOW_UNFREE" = 1;
    };

    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    programs.zoxide = {
      enable = true;
      options = ["--cmd cd"];
      enableFishIntegration = true;
    };

    home.sessionVariables._ZO_ECHO = 1; # Enable zoxide echoing the directory it is changing to.

    programs.vivid = {
      enable = true;
      # filetypes = lib.readFile (
      #   builtins.fetchurl {
      #     url = "https://github.com/sharkdp/vivid/blob/master/config/filetypes.yml";
      #     sha256 = "sha256:0lzsdc2v5f0bif52fz0w92mapachywkkdbfc6kqvkj9gbg3wz6m1";
      #   }
      # );
    };
  };
}
