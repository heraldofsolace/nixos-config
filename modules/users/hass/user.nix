{
  blazar,
  den,
  ...
}:
{
  den.aspects.hass = {
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
        pkgs,
        config,
        lib,
        ...
      }:
      {
        sops.secrets.hass-password = {
          key = "hass";
          sopsFile = ../../../secrets/user-passwords.yaml;
          neededForUsers = true;
        };

        security.sudo.extraRules = [
          {
            users = [ "hass" ];
            commands = [
              {
                command = "${pkgs.systemd}/bin/systemctl poweroff";
                options = [ "NOPASSWD" ];
              }
            ];
          }
          {
            users = [ "hass" ];
            commands = [
              {
                command = "${pkgs.systemd}/bin/systemctl suspend";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];

        # security.sudo.configFile = lib.mkMerge [
        #   ''
        #     hass ALL=NOPASSWD:${pkgs.systemd}/bin/systemctl suspend
        #     hass ALL=NOPASSWD:${pkgs.systemd}/bin/systemctl poweroff
        #   ''
        # ];

        services.openssh.enable = true;

        users.users = {
          hass = {
            description = "Home Assistant";
            hashedPasswordFile = config.sops.secrets.hass-password.path;
          };
        };
      };
  };

  # homeManager.home.homeDirectory = lib.mkDefault (
  #   if pkgs.stdenvNoCC.isDarwin then "/Users/${userName}" else "/home/${userName}"
}
