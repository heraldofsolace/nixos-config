{
  blazar,
  den,
  ...
}:
{
  den.aspects.nginx = {
    # Including other aspects.
    # For small, private one-shot aspects, use let-bindings like here.
    # for more complex or re-usable ones, define on their own modules,
    # as part of any aspect-subtree.
    includes =
      let
        # not required, showcasing angle-brackets syntax.
        # deadnix: skip
        inherit (den.lib) __findFile;
        # customEmacs.homeManager =
        #   { pkgs, ... }:
        #   {
        #     programs.emacs.enable = true;
        #     programs.emacs.package = pkgs.emacs30-nox;
        #   };
      in
      with blazar;
      [
        # blazar.setUserName
      ];

    nixos =
      { lib, ... }:
      {
        users.groups.nginx = { };

        users.users = {
          nginx = {
            description = "Nginx User";
            isSystemUser = true;
            isNormalUser = lib.mkForce false;
            group = "nginx";
          };
        };
      };
  };

  # homeManager.home.homeDirectory = lib.mkDefault (
  #   if pkgs.stdenvNoCC.isDarwin then "/Users/${userName}" else "/home/${userName}"
}
