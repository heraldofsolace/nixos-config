{
  blazar,
  inputs,
  ...
}: {
  flake-file.inputs = {
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs-pkgs-update.url = "path:/home/adda/documents/it/nixos/nixpkgs-pkgs-update";

    tsui = {
      # url = "github:guibou/tsui/fix_nix_run";
      url = "github:guibou/tsui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xdg-ninja = {
      url = "github:b3nj5m1n/xdg-ninja";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  blazar.console.includes = with blazar; [
    # atuin
  ];

  blazar.console.homeManager = {
    pkgs,
    inputs',
    ...
  }: {
    imports = [
      inputs.nix-index-database.homeModules.nix-index
    ];
    fonts.fontconfig.enable = true;

    home = {
      packages = with pkgs; [
        github-copilot-cli

        # Archives.
        p7zip
        unzip
        # xz
        zip
        unrar
        inputs'.xdg-ninja.packages.default

        # Utils.
        jq # A lightweight and flexible command-line JSON processor.
        yq-go # yaml processer https://github.com/mikefarah/yq.
        glow # Markdown previewer in terminal.
        treemd
        moreutils
        broot
        xcp
        # TODO: Uncomment when build succeeds
        # igrep

        # Disc usage.
        ncdu
        dua
        # duf # Modern `df`.
        dysk # Modern `df`.

        # networking tools
        # mtr # A network diagnostic tool
        # iperf3
        # dnsutils  # `dig` + `nslookup`
        # ldns # replacement of `dig`, it provide the command `drill`
        # aria2 # A lightweight multi-protocol & multi-source command-line download utility
        # socat # replacement of openbsd-netcat
        # nmap # A utility for network discovery and security auditing
        # ipcalc  # it is a calculator for the IPv4/v6 addresses
        # iotop # io monitoring
        # iftop # network monitoring
        sshfs
        lazyssh
        # nbping

        # Misc.
        file
        which
        # tree
        # gnused
        # gnutar
        # gawk
        # zstd
        flirt

        # Development.
        # hugo # static site generator
        ast-grep
        chafa
        expect
        fd # Modern Unix `find`.
        hexyl
        just
        marksman
        sd # Modern Unix `sed`.
        serpl
        srgn
        scc

        ## Python.
        python3
        uv

        # system call monitoring
        # strace # system call monitoring
        # ltrace # library call monitoring
        # lsof # list open files

        # system tools
        sysstat
        lm_sensors # for `sensors` command
        ethtool
        pciutils # lspci
        usbutils # lsusb
        procs # Listing a snapshot of current processes. A modern replacement for 'ps'.
        lazyjournal

        # Systemctl TUIs.
        isd
        systemctl-tui
        sysz
        lnav

        # Other.
        fastfetch
        frogmouth # Terminal Mardown viewer.
        lolcat
        # thefuck
        # tldr # Modern Unix `man`.
        tealdeer

        # Trash handling.
        trash-cli
        gomi
        # trashy
        gtrash

        ueberzugpp # Terminal image viewer integration.
        # xdg-utils
        # python312Packages.xdg-base-dirs
        syncthingtray

        # Privacy.
        tor-browser
        veracrypt
        inputs'.tsui.packages.tsui
      ];

      sessionVariables = {
        # PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

        TERMINAL = "wezterm-gui";

        # Already set using programs.<program>.defaultEditor.
        EDITOR = "anivim"; # "codium", "nvim"
        VISUAL = "anivim"; # "codium", "nvim"

        SYSTEMD_EDITOR = "anivim"; # "codium", "nvim"

        MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
        MANROFFOPT = "-c";
        PAGER = "bat"; # "less -FR"
      };
    };

    xdg.configFile = {
      "tig/.tigrc".text = ''
        bind status C  !git cs
        bind status A  !git ars
        bind main   P  !git p
        bind main   F !git pf

        set vertical-split =  false
      '';

      "glow/glow.yml".text = ''
        # style name or JSON path (default "auto")
        style: "auto"
        # show local files only; no network (TUI-mode only)
        local: false
        # mouse support (TUI-mode only)
        mouse: true
        # use pager to display markdown
        pager: true
        # word-wrap at width
        width: 120
      '';
    };

    programs.jq.enable = true;
    programs.jq.colors = {
      null = "1;30";
      false = "0;31";
      true = "0;32";
      numbers = "0;36";
      strings = "0;33";
      arrays = "1;35";
      objects = "1;37";
      objectKeys = "1;34";
    };

    programs.less = {
      enable = true;
    };

    programs.mcfly = {
      enable = true;
    };

    programs.sagemath = {
      enable = true;
    };

    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.yazi = {
      enable = true;
      shellWrapperName = "yy";
      settings = {
        mgr = {
          show_hidden = true;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
        };
      };
      plugins = {
        inherit
          (pkgs.yaziPlugins)
          git
          diff
          glow
          lsar
          nord
          ouch
          sudo
          chmod
          dupes
          gitui
          mount
          piper
          # rsync
          bypass
          duckdb
          # mactag
          miller
          lazygit
          # jjui
          restore
          yatline
          compress
          mime-ext
          projects
          starship
          bookmarks
          mediainfo
          # no-status
          vcs-files
          full-border
          recycle-bin
          smart-enter
          smart-paste
          time-travel
          toggle-pane
          jump-to-char
          rich-preview
          smart-filter
          wl-clipboard
          yatline-githead
          relative-motions
          # yatline-catppuccin
          # nur.repos.xyenon.yaziPlugins.fg
          # nur.repos.xyenon.yaziPlugins.ouch
          # nur.repos.xyenon.yaziPlugins.yafg
          # nur.repos.Vortriz.yaziPlugins.gvfs
          # nur.repos.Vortriz.yaziPlugins.bunny
          # nur.repos.Vortriz.yaziPlugins.office
          # nur.repos.xyenon.yaziPlugins.clipboard
          # nur.repos.xyenon.yaziPlugins.exifaudio
          # nur.repos.Vortriz.yaziPlugins.what-size
          # nur.repos.xyenon.yaziPlugins.yazi-rs.git
          # nur.repos.xyenon.yaziPlugins.yazi-rs.diff
          # nur.repos.xyenon.yaziPlugins.yazi-rs.lsar
          # nur.repos.xyenon.yaziPlugins.yazi-rs.zoom
          # nur.repos.Vortriz.yaziPlugins.custom-shell
          # nur.repos.xyenon.yaziPlugins.yazi-rs.chmod
          # nur.repos.xyenon.yaziPlugins.yazi-rs.mount
          # nur.repos.xyenon.yaziPlugins.yazi-rs.piper
          # nur.repos.xyenon.yaziPlugins.yazi-rs.types
          # nur.repos.Vortriz.yaziPlugins.enhance-piper
          # nur.repos.xyenon.yaziPlugins.yazi-rs.mactag
          # nur.repos.xyenon.yaziPlugins.yazi-rs.mime-ext
          # nur.repos.xyenon.yaziPlugins.yazi-rs.no-status
          # nur.repos.xyenon.yaziPlugins.yazi-rs.sudo-demo
          # nur.repos.xyenon.yaziPlugins.yazi-rs.vcs-files
          # nur.repos.Vortriz.yaziPlugins.hover-after-moved
          # nur.repos.xyenon.yaziPlugins.yazi-rs.full-border
          # nur.repos.xyenon.yaziPlugins.yazi-rs.smart-enter
          # nur.repos.xyenon.yaziPlugins.yazi-rs.smart-paste
          # nur.repos.xyenon.yaziPlugins.yazi-rs.toggle-pane
          # nur.repos.Vortriz.yaziPlugins.file-extra-metadata
          # nur.repos.xyenon.yaziPlugins.yazi-rs.jump-to-char
          # nur.repos.xyenon.yaziPlugins.yazi-rs.smart-filter
          ;

        # inputs'.nixpkgs-pkgs-update.legacyPackages.yaziPlugins.jjui;
      };
      keymap = {
        mgr.prepend_keymap = [
          {
            on = [
              "c"
              "m"
            ];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = [
              "g"
              "j"
            ];
            run = "plugin jjui";
            desc = "run jjui";
          }
          {
            on = [
              "g"
              "l"
            ];
            run = "plugin lazygit";
            desc = "run lazygit";
          }
        ];
      };
    };

    services.syncthing = {
      enable = true;
    };

    # Nicely reload system units when changing configs
    #systemd.user.startServices = lib.mkIf isLinux "sd-switch";

    # A modern replacement for ‘ls’.
    programs.eza = {
      enable = true;

      icons = "auto";
      git = true;
      colors = "auto";
      extraOptions = [
        "--all"
        "--long"
        "--header"
        "--group-directories-first"
        "--classify"
        "--sort=newest"
        "--git"
        "--color-scale=all"
        "--octal-permissions"
      ];
    };

    programs.pay-respects = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.navi = {
      enable = true;
      settings = {};
    };

    programs.uv = {
      enable = true;
      settings = {
        preview = true;
        pip = {
          allow-empty-requirements = true;
          all-extras = true;
          strict = true;
          verify-hashes = true;
        };
      };
    };

    programs.bat = {
      enable = true;
      config = {
        pager = "less --quit-if-one-screen --RAW-CONTROL-CHARS";
      };
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };

    programs.wallust = {
      enable = true;
      # settings = { };
    };

    programs.television = {
      enable = true;
      # settings = { };
      # channels = { };
    };

    programs.clock-rs = {
      enable = true;
      # settings = {};
    };

    # services.home-manager.autoExpire = ...;

    programs.tray-tui = {
      enable = true;
      settings = {
        sorting = true;
        # columns = 3;
        mouse = true;
      };
    };

    programs.ripgrep.enable = true;
    programs.ripgrep-all.enable = true;

    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        proc_tree = true;
        proc_left = true;
        proc_aggregate = true;
      };
    };

    # programs.atool = {
    #   enable = true;
    #   settings = {
    #     path_unrar = "unrar-free";
    #   };
    #   extraPackages = with pkgs; [
    #     file
    #     gnutar
    #     gzip
    #     bzip2
    #     cpio
    #     lhasa
    #     lzop
    #     p7zip
    #     unrar-free
    #     unzip
    #     xz
    #     zip
    #   ];
    # };
  };
}
