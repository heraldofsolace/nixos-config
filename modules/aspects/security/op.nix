_: {
  blazar.security._.onepassword.nixos = _: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "aniket" ];
    };
    # security.wrappers."1Password-KeyringHelper".source = lib.mkForce "${pkgs._1password-gui}/share/1password/1Password-BrowserSupport";
    programs.ssh.extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
    '';

    environment.etc = {
      # This file replaces 1Password's built-in allowed-browsers list rather
      # than extending it - firefox is supported by default, but having this
      # file at all with only .zen-wrapped listed silently broke Firefox's
      # extension ("An unknown database error occurred").
      "1password/custom_allowed_browsers" = {
        text = ''
          .zen-wrapped
          firefox
        ''; # or just "zen" if you use unwrapped package
        mode = "0755";
      };
    };
  };

  blazar.security._.onepassword.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.git.extraConfig = {
        gpg.format = "ssh";
        "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
    };
}
