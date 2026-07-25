{
  blazar,
  den,
  ...
}:
{
  den.aspects.nextcloud = {
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
      {
        lib,
        ...
      }:
      {
        # sops.secrets.nextcloud-password = {
        #   key = "nextcloud";
        #   sopsFile = ../../../secrets/user-passwords.yaml;
        #   neededForUsers = true;
        # };
        users.groups.nextcloud = { };
        users.groups.music = { };

        users.users = {
          nextcloud = {
            description = "Nextcloud User";
            isSystemUser = true;
            isNormalUser = lib.mkForce false;
            group = "nextcloud";
            home = lib.mkForce "/var/lib/nextcloud";
            extraGroups = [
              "music"
            ];
            # hashedPasswordFile = config.sops.secrets.nextcloud-password.path;
          };
        };
      };
  };

  # homeManager.home.homeDirectory = lib.mkDefault (
  #   if pkgs.stdenvNoCC.isDarwin then "/Users/${userName}" else "/home/${userName}"
}
