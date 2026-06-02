{
  den,
  inputs,
  ...
}: {
  den.ctx.host.nixos = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      # Adds the NUR overlay
      inputs.nur.modules.nixos.default
      # NUR modules to import
      # inputs.nur.legacyPackages."${system}".repos.iopq.modules.xraya
      # This adds the NUR nixpkgs overlay.
      # Example:
      # ({ pkgs, ... }: {
      #   environment.systemPackages = [ pkgs.nur.repos.mic92.hello-nur ];
      # })
    ];

    # fonts.packages = with pkgs.nerd-fonts; [
    # victor-mono
    # jetbrains-mono
    # inconsolata
    # ];

    hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;

    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    # FIXME: Would be nice to have, but fails too often.
    systemd.enableStrictShellChecks = false;

    nixpkgs = {
      overlays = let
        # When applied, the stable nixpkgs set (declared in the flake inputs) will
        # be accessible through 'pkgs.stable'
        latestPackages = final: _: rec {
          latest = import inputs.latest {
            inherit (final.stdenv.hostPlatform) system;
            inherit (final) config;
          };
          inherit
            (latest)
            _1password-cli
            _1password-gui
            direnv
            tailscale
            jetbrains
            siril
            obs-studio
            vial
            via
            wally-cli
            kanata
            wrapNeovimUnstable
            openrgb
            copyq
            zoom
            kstars
            electron
            awww
            ;
        };
      in
        with inputs; [
          # Add overlays your own flake exports (from overlays and pkgs dir):
          # inputs.self.overlays.additions
          # inputs.self.overlays.modifications
          latestPackages

          nur.overlays.default
          # agenix.overlays.default
          # nvfetcher.overlays.default
          hyprland-contrib.overlays.default
          # nix-vscode-extensions.overlays.default
          dolphin-overlay.overlays.default

          # You can also add overlays exported from other flakes:
          # neovim-nightly-overlay.overlays.default
          #inputs.agenix.overlays.default

          # Or define it inline, for example:
          # (final: prev: {
          #   hi = final.hello.overrideAttrs (oldAttrs: {
          #     patches = [ ./change-hello-to-hi.patch ];
          #   });
          # })
        ];
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    # system = {
    #   autoUpgrade = {
    #     enable = true;
    #     flake = "file+git://~/.nixos-config";
    #   };
    # };

    nix = {
      settings = {
        experimental-features = [
          "auto-allocate-uids"
          "blake3-hashes"
          "ca-derivations"
          "cgroups"
          "dynamic-derivations"
          "fetch-closure"
          "flakes"
          "impure-derivations"
          #"local-overlay-store"
          "nix-command"
          "parse-toml-timestamps"
          "pipe-operators"
          # "pipe-operator"
          "read-only-local-store"
          "recursive-nix"
          # "repl-automation"
        ];

        auto-allocate-uids = true;

        # Deduplicate and optimize nix store
        auto-optimise-store = true;

        # Opinionated: disable global registry
        #flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        # nix-path = config.nix.nixPath;

        # lazy-trees = true;

        # FIXME: Remove "no-url-literals" and uncomment these when Nix 2.34 is available.
        lint-url-literals = "fatal";
        # lint-short-path-literals = "warn";
        # lint-absolute-path-literals = "warn";

        warn-dirty = false;

        # Avoid unwanted garbage collection when using nix-direnv.
        keep-outputs = true;
        keep-derivations = true;

        trusted-users = [
          "root"
          "@wheel"
        ];
        sandbox = true;
        allowed-users = ["root @wheel"];
      };
      # Opinionated: disable channels
      # channel.enable = false;

      optimise.automatic = true;
      extraOptions = ''
        min-free = 536870912
        keep-outputs = true
        keep-derivations = true
        fallback = true
      '';
    };
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/aniket/my-nix";
    };
    hardware.uinput.enable = true;

    hardware.graphics.enable = true;

    # This setups a SSH server. Very important if you're setting up a headless system.
    # Feel free to remove if you don't need it.

    services.openssh = {
      enable = lib.mkDefault true;

      settings = {
        # Use only public keys
        PasswordAuthentication = lib.mkForce false;
        KbdInteractiveAuthentication = lib.mkForce false;

        # root login is never welcome, except for remote builders
        PermitRootLogin = lib.mkForce "prohibit-password";
      };

      startWhenNeeded = lib.mkDefault true;
      openFirewall = lib.mkDefault false;
    };

    services.envfs = {
      enable = true;
      extraFallbackPathCommands = ''
        ln -s ${pkgs.bash}/bin/bash $out/bash
      '';
    };

    # Set your time zone.
    time.timeZone = "Asia/Kolkata";

    users.mutableUsers = lib.mkDefault false;
    security.sudo.enable = lib.mkForce true;
    security.sudo.wheelNeedsPassword = lib.mkForce false;

    console = {
      font = "Lat2-Terminus16";
    };

    fonts.fontconfig.defaultFonts = {
      monospace = ["FiraCode Nerd Font Mono"];
      sansSerif = ["DejaVu Sans"];
    };

    programs.fuse = {
      userAllowOther = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocales = "all";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_IN.UTF-8";
      LC_IDENTIFICATION = "en_IN.UTF-8";
      LC_MEASUREMENT = "en_IN.UTF-8";
      LC_MONETARY = "en_IN.UTF-8";
      LC_NAME = "en_IN.UTF-8";
      LC_NUMERIC = "en_IN.UTF-8";
      LC_PAPER = "en_IN.UTF-8";
      LC_TELEPHONE = "en_IN.UTF-8";
      LC_TIME = "en_IN.UTF-8";
    };
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        # fcitx5-openbangla-keyboard
      ];
    };
    environment.sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      QT_IM_MODULE = "fcitx";
      GTK_IM_MODULE = "fcitx";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers = [pkgs.hplip];

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    services.earlyoom.enable = true;

    users.groups.realtime = {};
    users.groups.uinput = {};
    security.pam.loginLimits = [
      {
        domain = "@realtime";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@realtime";
        type = "-";
        item = "rtprio";
        value = "95";
      }
      {
        domain = "@realtime";
        type = "-";
        item = "nice";
        value = "-11";
      }
    ];

    hardware.sane.enable = true;
    hardware.sane.extraBackends = [pkgs.hplipWithPlugin pkgs.sane-airscan];

    hardware.bluetooth = {
      enable = true;
      #   hsphfpd.enable = true;
      #   settings = {
      #     General = {
      #       enable = "Soure,Sink,Media,Socket";
      #     };
      #   };
    };
    hardware.opentabletdriver.enable = true;
    hardware.opentabletdriver.daemon.enable = true;

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
    ];
    #services.blueman.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment = {
      systemPackages = with pkgs; [
        git
        gnupg
        killall
        pciutils
        usbutils
        wget
        xterm
        comma

        # Fix Flatpak fonts
        # xsettingsd
        # xrdb

        # nur.repos.mic92.hello-nur
      ];

      shells = with pkgs; [
        bash
        zsh
        fish
        dash
      ];
    };

    programs.nano.enable = false;
    programs.fish = {
      enable = true;
      # vendor = {
      #   completions.enable = true;
      #   config.enable = true;
      #   functions.enable = true;
      # };
    };
    users.defaultUserShell = pkgs.bash;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    services.fstrim = {
      enable = true;
      #interval = "weekly"; # The default.
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs;
        [
          nerd-fonts.ubuntu-mono
          source-code-pro
          nerd-fonts.fira-code
          dejavu_fonts
          powerline-fonts
          font-awesome
          nerd-fonts.jetbrains-mono
          nerd-fonts.liberation # no mono version of this?
          nerd-fonts.droid-sans-mono
          nerd-fonts.symbols-only
          nerd-fonts.fantasque-sans-mono
        ]
        ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    };

    services.fwupd = {
      enable = true;
    };
    # Allow fwupd-refresh to restart if failed (after resume)
    systemd.services.fwupd-refresh = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "20";
      };
      unitConfig = {
        StartLimitIntervalSec = 100;
        StartLimitBurst = 5;
      };
    };
  };

  den.ctx.host.homeManager = {
    programs.home-manager.enable = true;
    # Nicely reload system units when changing configs
    # systemd.user.startServices = "sd-switch";

    # You can import other home-manager modules here
    # Only import desktop configuration if the host is desktop enabled
    # Only import user specific configuration if they have bespoke settings
    imports =
      [
        # If you want to use modules your own flake exports (from modules/home-manager):
        # outputs.homeManagerModules.example

        # Or modules exported from other flakes (such as nix-colors):
        # inputs.nix-colors.homeManagerModules.default

        # You can also split up your configuration and import pieces of it here:
        # ./_mixins/network
      ]
      # ++ lib.optional (builtins.isPath (./. + "/_mixins/users/${username}")) ./_mixins/users/${username}
      # ++ lib.optional (builtins.pathExists (
      #   ./. + "/_mixins/users/${username}/hosts/${hostname}.nix"
      # )) ./_mixins/users/${username}/hosts/${hostname}.nix
      ;
  };

  # mutual-provider is activated at a `{host,user}` context
  # either per-user or for all of them.
  den.ctx.user.includes = [den._.mutual-provider];
}
