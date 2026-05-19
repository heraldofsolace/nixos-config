_: {
  blazar.security._.onepassword.nixos = _: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = ["aniket"];
    };
    # security.wrappers."1Password-KeyringHelper".source = lib.mkForce "${pkgs._1password-gui}/share/1password/1Password-BrowserSupport";
    programs.ssh.extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
    '';

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          .zen-wrapped
        ''; # or just "zen" if you use unwrapped package
        mode = "0755";
      };
    };
  };

  blazar.security._.onepassword.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    programs.git.extraConfig = {
      gpg.format = "ssh";
      "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
    };
  };
}
