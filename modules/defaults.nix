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
        latestPackages = final: _: {
          stable = import inputs.latest {
            inherit (final.stdenv.hostPlatform) system;
            inherit (final) config;
          };
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

    nix =
      # let
      #   flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
      # in
      {
        # package =
        #   lib.mkForce
        #     # pkgs.nix;
        #     # pkgs.nixVersions.latest;
        #     # pkgs.lixPackageSets.latest.lix;
        #     inputs.determinate.packages.${pkgs.stdenv.hostPlatform.system}.default;

        # This will add each flake input as a registry
        # To make nix3 commands consistent with your flake
        # registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
        #   # (lib.filterAttrs (_: lib.isType "flake"))
        #   inputs
        # );

        # Garbage collecting.
        # gc = {
        #   automatic = true;
        #   dates = "weekly";
        #   options = "--delete-older-than 7d";
        # };

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
            "no-url-literals"
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
          # lint-url-literals = "fatal";
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
        };
        # Opinionated: disable channels
        channel.enable = false;

        # Opinionated: make flake registry and nix path match flake inputs
        # This will add each flake input as a registry
        # To make nix3 commands consistent with your flake
        # registry = lib.mapAttrs (_name: flake: { inherit flake; }) flakeInputs;

        # This will add each flake input as a registry
        # To make nix3 commands consistent with your flake
        # registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

        # This will add each flake input as a registry
        # To make nix3 commands consistent with your flake
        # registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
        #   (lib.filterAttrs (_: lib.isType "flake")) inputs
        # );

        # nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
        # This will additionally add your inputs to the system's legacy channels
        # Making legacy nix commands consistent as well, awesome!
        # nixPath = [ "/etc/nix/path" ];
      };
    # environment.etc = (
    #   lib.mapAttrs' (name: value: {
    #     name = "nix/path/${name}";
    #     value.source = value.flake;
    #   }) config.nix.registry
    # )

    # # Bootloader.
    # boot = {
    #   loader = {
    #     systemd-boot.enable = lib.mkForce false;
    #     grub = {
    #       enable = lib.mkForce true;
    #       #device = "/dev/nvme0n1p5";
    #       device = "nodev";
    #       efiSupport = true;
    #       #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
    #       useOSProber = true;
    #       configurationLimit = 10;
    #     };
    #     efi = {
    #       canTouchEfiVariables = lib.mkForce true;
    #       efiSysMountPoint = "/boot/efi"; # use the same mount point here.
    #     };
    #     timeout = null; # Remain in boot menu indefinitely.
    #   };
    #   supportedFilesystems = [
    #     "ntfs"
    #   ];
    #   # kernelPackages = ;
    #   # kernelPackages = pkgs.linuxPackages_latest;
    #   kernelPackages = pkgs.linuxPackages_xanmod_latest;
    #   extraModulePackages = [
    #     # pkgs.linuxPackages_zen.kernel
    #     # pkgs.linuxPackages_latest.kernel
    #   ];
    #   # initrd.kernelModules = [
    #   #   "amdgpu"
    #   # ];
    # };

    hardware.uinput.enable = true;

    hardware.graphics.enable = true;

    # This setups a SSH server. Very important if you're setting up a headless system.
    # Feel free to remove if you don't need it.
    services.openssh = {
      enable = true;
      settings = {
        # Forbid root login through SSH.
        PermitRootLogin = "no";
        # Use keys only. Remove if you want to SSH using password (not recommended)
        PasswordAuthentication = false;

        X11Forwarding = true;
      };

      openFirewall = true;
    };

    services.envfs = {
      enable = true;
      extraFallbackPathCommands = ''
        ln -s ${pkgs.bash}/bin/bash $out/bash
      '';
    };

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Prague";

    # Select internationalisation properties.
    i18n.defaultLocale = lib.mkForce "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "cs_CZ.UTF-8";
      LC_IDENTIFICATION = "cs_CZ.UTF-8";
      LC_MEASUREMENT = "cs_CZ.UTF-8";
      LC_MONETARY = "cs_CZ.UTF-8";
      LC_NAME = "cs_CZ.UTF-8";
      LC_NUMERIC = "cs_CZ.UTF-8";
      LC_PAPER = "cs_CZ.UTF-8";
      LC_TELEPHONE = "cs_CZ.UTF-8";
      LC_TIME = "cs_CZ.UTF-8";
      LC_DATE = "en_US.UTF-8";
    };

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = true;

    # Configure keymap in X11
    # services.xserver = {
    #   xkb.layout = "cz";
    #   xkb.variant = "coder";
    # };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
      #   hsphfpd.enable = true;
      #   settings = {
      #     General = {
      #       enable = "Soure,Sink,Media,Socket";
      #     };
      #   };
    };
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

    programs.zsh.enable = true;
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
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.fstrim = {
      enable = true;
      #interval = "weekly"; # The default.
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
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
      ];
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder.

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
    systemd.user.startServices = "sd-switch";

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
