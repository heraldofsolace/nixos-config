{
  config,
  # deadnix: skip # enable <den/brackets> syntax for demo.
  __findFile ? __findFile,
  den,
  ...
}: {
  # # Lets also configure some defaults using aspects.
  # # These are global static settings.
  # den.schema.user.classes = lib.mkDefault [
  #   "homeManager"
  #   "hjem"
  #   "maid"
  # ];
  den.schema.host = {
    hjem.enable = true;
    home-manager.enable = true;
  };

  den.default = {
    nixos = {
      # darwin.system.stateVersion = 6;
      system.stateVersion = "25.11";

      home-manager = {
        backupFileExtension = "backup";
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
    homeManager.home.stateVersion = "25.11";
  };

  # These are functions that produce configs
  den.default.includes = [
    # ${user}.provides.${host} and ${host}.provides.${user}
    <den/mutual-provider>

    # Automatically set hostname
    <den/hostname>

    # Automatically create the user on host.
    <den/define-user>

    # Disable booting when running on CI on all NixOS hosts.
    (
      if config ? _module.args.CI
      then <eg/ci-no-boot>
      else {}
    )
    # Provides the `flake-parts` `self'` (the flake's `self` with system pre-selected) as a top-level module argument.
    # This allows modules to access per-system flake outputs without needing
    # `pkgs.stdenv.hostPlatform.system`.
    # ## Usage
    # **Global (Recommended):**
    # Apply to all hosts, users, and homes.
    #     den.default.includes = [ den._.self' ];
    # **Specific:**
    # Apply only to a specific host, user, or home aspect.
    #     den.aspects.my-laptop.includes = [ den._.self' ];
    #     den.aspects.alice.includes = [ den._.self' ];
    # **Note:** This aspect is contextual. When included in a `host` aspect, it
    # configures `self'` for the host's OS. When included in a `user` or `home`
    # aspect, it configures `self'` for the corresponding Home Manager configuration.
    den._.self'

    # Provides the `flake-parts` `inputs'` (the flake's `inputs` with system pre-selected)
    # as a top-level module argument.
    # This allows modules to access per-system flake outputs without needing
    # `pkgs.stdenv.hostPlatform.system`.
    # ## Usage
    # **Global (Recommended):**
    # Apply to all hosts, users, and homes.
    #     den.default.includes = [ den._.inputs' ];
    # **Specific:**
    # Apply only to a specific host, user, or home aspect.
    #     den.aspects.my-laptop.includes = [ den._.inputs' ];
    #     den.aspects.alice.includes = [ den._.inputs' ];
    # **Note:** This aspect is contextual. When included in a `host` aspect, it
    # configures `inputs'` for the host's OS. When included in a `user` or `home`
    # aspect, it configures `inputs'` for the corresponding Home Manager configuration.
    den._.inputs'

    <blazar/routes>
  ];
}
