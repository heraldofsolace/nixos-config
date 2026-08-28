{
  blazar,
  den,
  lib,
  ...
}:
{
  den.aspects.aniket = { host, ... }: {
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
        # from the aspect tree
        ai
        security._.sops
        security._.onepassword
        virtualisation
        # cpu
        console
        atuin
        vcs
        shells
        tmux
        keyboard
        # nix
        # development._.desktop
        # development._.console
      ]
      ++ [
        # from local bindings.
        # customEmacs
        # from the `eg` namespace.
        # eg.autologin
        # den included batteries that provide common configs.
        <den/primary-user> # The user is always admin.
        # blazar.setUserName
        # (<den/user-shell> "dash") # default user shell # Cannot be used for `dash`.
      ]
      ++ (lib.optional (host.name == "andromeda") [
        hyprland
        desktop
        desktop._.image
        desktop._.messaging._.vesktop
        desktop._.messaging._.zoom
        firefox
        brave
        zen
        # ai
        media
        media._.music
        media._.console
        media._.desktop
        # documentation
        # waydroid
        # xremap
        editors._.anivim
        editors._.vscode
        editors._.jetbrains

        utils._.obsidian
        utils._.openrgb

        games
      ])
      ++ (lib.optional (host.name == "horologium") [
        plasma
        desktop
        desktop._.image
        desktop._.messaging._.vesktop
        desktop._.messaging._.zoom
        firefox
        brave
        zen
        # ai
        media
        media._.music
        media._.console
        media._.desktop
        # documentation
        # waydroid
        # xremap
        editors._.anivim
        editors._.vscode
        editors._.jetbrains

        utils._.obsidian

        games
      ]);

    nixos =
      {
        pkgs,
        config,
        ...
      }:
      {
        users.users = {
          aniket = {
            # You can set an initial password for your user.
            # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
            # Be sure to change it (using passwd) after rebooting!
            # initialPassword = "correcthorsebatterystaple";
            description = "Aniket";

            # isNormalUser = true;
            extraGroups = [
              "networkmanager"
              "wheel"
              "video"
              "audio"
              "camera"
              "kvm"
              "lp"
              "scanner"
              "dialout"
            ]
            ++ (lib.optional (host.name == "miranda") "music");

            shell = pkgs.bash; # bash as default shell to keep myself sane. In interactive mode, bash drops into fish
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA3GRcKkyXAJvKjyovyzkPzV9aaT7FRBSbnR1t1bmwqP"
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrWDTKOYQ8HmWvmB8KI8rQBBIVsHdtFt0l3a3Y/D0Em+8sOTp86IFAi0RqFjlQabvaNGvYH2djCj57dnWQ5bOEF2EGbQ7dqON0i5RSKiIGpw+aSY58LueNK6Ht7dVGHMvRbDQMbLwxh8zbaxooVnLdG39zWSEKe8xS9fBw4Ym6E1Z8egcYYCGze2J+M3DOwj6/YIEpYOA1QQr60wPld6yfDsENdMk09G1uJp/ZI/Zz0a7DkCBtIQTz80yTvJSRCYDIfCNKqApa6NXTU9hqS7LoAxgAxb8jduO2b3JseRPhxGvS9wcuBIYRKZAOX5fmTVSqqFPox21gSn7yGGFJgiOeFZ3PCQXoimebRcTEiaffwcu7HE58ZT57ly5FVhQvJ6AIag2FjdExJqz5A6WYEaQFFPcJBZno2uaayGxzOYGzaCG6wbNR28HkvVf0wF2XiaHvtWCAAcYJ7f17cEtkCptYQQOnZ4tjFGaDmuKXRYFV4Kz79ceca9kYlY5bM3U+qyk= aniket@andromeda"
            ];
            uid = 1000;
            hashedPasswordFile = config.sops.secrets.aniket-password.path;
          };
        };

        users.groups.uinput.members = [ "aniket" ];
        users.groups.input.members = [ "aniket" ];

        sops.gnupg.sshKeyPaths = [
          "/persist/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key"
        ];

        sops.secrets.aniket-password = {
          key = "aniket";
          sopsFile = ../../../secrets/user-passwords.yaml;
          neededForUsers = true;
        };
      };

    # maid-activation.service (user service) replaces ~/.config/systemd/user with a
    # GC-root symlink into the read-only nix store after each login.
    # home-manager's linkGeneration (system service) then fails on the next rebuild
    # because it tries to create symlinks inside a read-only store path.
    # This activation step converts the store symlink back to a real directory before
    # linkGeneration runs so home-manager can populate it normally.
    homeManager =
      { lib, ... }:
      {
        home.activation.fixSystemdUserDir = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
          _sd="''${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
          if [[ -L "$_sd" && "$(readlink "$_sd")" == /nix/store/* ]]; then
            $DRY_RUN_CMD rm "$_sd"
            $DRY_RUN_CMD mkdir -p "$_sd"
          fi
        '';
      };
  };

  # homeManager.home.homeDirectory = lib.mkDefault (
  #   if pkgs.stdenvNoCC.isDarwin then "/Users/${userName}" else "/home/${userName}"
}
