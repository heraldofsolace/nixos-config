# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
/*
# paste the inputs you don't have in this set into your main system flake.nix
# (lazy.nvim wrapper only works on unstable)
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  nixCats.url = "github:BirdeeHub/nixCats-nvim";
};

Then call this file with:
myNixCats = import ./path/to/this/dir { inherit inputs; };
And the new variable myNixCats will contain all outputs of the normal flake format.
You could put myNixCats.packages.${pkgs.system}.thepackagename in your packages list.
You could install them with the module and reconfigure them too if you want.
You should definitely re export them under packages.${system}.packagenames
from your system flake so that you can still run it via nix run from anywhere.

The following is just the outputs function from the flake template.
*/
{inputs, ...} @ attrs: let
  nixpkgs = inputs.latest;
  inherit (inputs.nixCats) utils;
  luaPath = "${./.}";
  forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
  # the following extra_pkg_config contains any values
  # which you want to pass to the config set of nixpkgs
  # import nixpkgs { config = extra_pkg_config; inherit system; }
  # will not apply to module imports
  # as that will have your system values
  extra_pkg_config = {
    # allowUnfree = true;
  };
  dependencyOverlays =
    (import ./overlays/_default.nix inputs)
    ++ [
      # see :help nixCats.flake.outputs.overlays
      # This overlay grabs all the inputs named in the format
      # `plugins-<pluginName>`
      # Once we add this overlay to our nixpkgs, we are able to
      # use `pkgs.neovimPlugins`, which is a set of our plugins.
      (utils.standardPluginOverlay inputs)
      # add any flake overlays here.
      # inputs.neorg-overlay.overlays.default
      # when other people mess up their overlays by wrapping them with system,
      # you may instead call this function on their overlay.
      # it will check if it has the system in the set, and if so return the desired overlay
      # (utils.fixSystemizedOverlay inputs.codeium.overlays
      #   (system: inputs.codeium.overlays.${system}.default)
      # )
    ];

  categoryDefinitions = {
    pkgs,
    settings,
    categories,
    extra,
    name,
    mkNvimPlugin,
    ...
  } @ packageDef: {
    lspsAndRuntimeDeps = {
      general = with pkgs; [
        universal-ctags
        ripgrep
        fd
        gcc
        gopls
        pyright
        rust-analyzer
        typescript-language-server
        lua51Packages.lua-lsp
        clang
        clang-tools
        tree-sitter
      ];

      nix-dev = with pkgs; [
        nix-doc
        nil
        nixd
      ];

      lint = with pkgs; [
        eslint
      ];
      debug = with pkgs; [
        gdb
      ];
      format = with pkgs; [
        treefmt
        alejandra
        prettier
      ];

      org = with pkgs.lua51Packages; [
        lua
        luarocks
        plenary-nvim
        pathlib-nvim
        nui-nvim
        nvim-nio
      ];
    };

    startupPlugins = {
      lazy = with pkgs.vimPlugins; [
        lazy-nvim
      ];

      lint = with pkgs.vimPlugins; [
        nvim-lint
      ];

      general = {
        gitPlugins = with pkgs.neovimPlugins; [
        ];

        org = with pkgs.vimPlugins; [
          vimwiki
          neorg
          neorg-telescope
          vim-wakatime
        ];
        dev = {
          ruby = with pkgs.vimPlugins; [
            vim-rails
          ];
          nix-dev = with pkgs.vimPlugins; [
            neodev-nvim
            neoconf-nvim
          ];
        };
        general = with pkgs.vimPlugins; [
          fidget-nvim
          lualine-nvim
          gitsigns-nvim
          which-key-nvim
          comment-nvim
          vim-sleuth
          vim-fugitive
          vim-rhubarb
          vim-repeat
          vim-dadbod
          vim-dadbod-ui
          vim-eunuch
          vim-projectionist
          vim-speeddating
          indent-blankline-nvim
          wildfire-vim
          editorconfig-nvim
          lush-nvim
          vim-tmux-navigator
          alpha-nvim
          twilight-nvim
          direnv-vim
          vim-peekaboo
          kommentary
          sqlite-lua
          legendary-nvim
          bufferline-nvim
          auto-save-nvim
          dressing-nvim
          hardtime-nvim
          oil-nvim
          noice-nvim
          nvim-notify
          nui-nvim
          pkgs.nixCatsBuilds.vim-schlepp
        ];
      };
      # You can retreive information from the
      # packageDefinitions of the package this was packaged with.
      # :help nixCats.flake.outputs.categoryDefinitions.scheme
      themer = with pkgs.vimPlugins; (
        builtins.getAttr packageDef.categories.colorscheme {
          # Theme switcher without creating a new category
          "onedark" = onedark-nvim;
          # "catppuccin" = catppuccin-nvim;
          "tokyonight" = tokyonight-nvim;
          "nord" = nord-nvim;
          "nightfox" = nightfox-nvim;
        }
      );
    };

    optionalPlugins = {
      custom = with pkgs.nixCatsBuilds; [];
      format = with pkgs.vimPlugins; [
        conform-nvim
      ];
      debug = with pkgs.vimPlugins; [
        nvim-nio
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
      ];
      treesitter = with pkgs.vimPlugins; [
        nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars
      ];
      telescope = with pkgs.vimPlugins; [
        telescope-frecency-nvim
        plenary-nvim
        telescope-nvim
        telescope-fzf-native-nvim
        smart-open-nvim
      ];

      cmp = with pkgs.vimPlugins; [
        blink-cmp
        nvim-lspconfig
        dropbar-nvim
        pkgs.nixCatsBuilds.guihua-lua
        pkgs.nixCatsBuilds.navigator-lua
        pkgs.nixCatsBuilds.inlay-hints-nvim
      ];
      gitPlugins = with pkgs.vimPlugins; [
        lazygit-nvim
      ];
      markdown = with pkgs.vimPlugins; [
        glow-nvim
      ];
      general = with pkgs.vimPlugins; [
        zen-mode-nvim
        nvim-web-devicons
        todo-comments-nvim
        vimtex
        trouble-nvim
        flash-nvim
      ];
      org = with pkgs.vimPlugins; [
      ];
    };

    # shared libraries to be added to LD_LIBRARY_PATH
    # variable available to nvim runtime
    sharedLibraries = {
      general = with pkgs; [
        libgit2
        gcc
      ];
    };

    environmentVariables = {
      test = {
        CATTESTVAR = "It worked!";
      };
    };

    extraWrapperArgs = {
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      test = [
        ''--set CATTESTVAR2 "It worked again!"''
      ];
    };

    # lists of the functions you would have passed to
    # python.withPackages or lua.withPackages

    # get the path to this python environment
    # in your lua config via
    # vim.g.python3_host_prog
    # or run from nvim terminal via :!<packagename>-python3
    python3.libraries = {
      test = _: [];
    };

    python3.extraWrapperArgs = {
      general = [
        "--unset PYTHONSAFEPATH"
      ];
    };

    # populates $LUA_PATH and $LUA_CPATH
    extraLuaPackages = {
      test = [(_: [])];
    };
  };

  packageDefinitions = {
    anivim = {pkgs, ...}: {
      # they contain a settings set defined above
      # see :help nixCats.flake.outputs.settings
      settings = {
        wrapRc = true;
        configDirName = "anivim";
        aliases = ["neovim" "vim" "vi"];
        hosts.node.enable = true;
        hosts.python3.enable = true;
        hosts.perl.enable = true;
        hosts.ruby.enable = true;
        neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
      };
      # and a set of categories that you want
      # (and other information to pass to lua)
      categories = {
        lazy = true;
        generalBuildInputs = true;
        debug = true;
        lint = true;
        format = true;
        general = true;
        gitPlugins = true;
        telescope = true;
        treesitter = true;
        org = true;
        dev = true;
        cmp = true;
        markdown = true;
        # this does not have an associated category of plugins,
        # but lua can still check for it
        lspDebugMode = false;
        # you could also pass something else:
        themer = true;
        colorscheme = "nightfox";
      };
      extra = {};
    };
  };
  # In this section, the main thing you will need to do is change the default package name
  # to the name of the packageDefinitions entry you wish to use as the default.
  defaultPackageName = "anivim";
in
  # see :help nixCats.flake.outputs.exports
  forEachSystem (system: let
    nixCatsBuilder =
      utils.baseBuilder luaPath {
        inherit system dependencyOverlays extra_pkg_config nixpkgs;
      }
      categoryDefinitions
      packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;
    # this is just for using utils such as pkgs.mkShell
    # The one used to build neovim is resolved inside the builder
    # and is passed to our categoryDefinitions and packageDefinitions
    pkgs = import nixpkgs {inherit system;};
  in {
    # this will make a package out of each of the packageDefinitions defined above
    # and set the default package to the one passed in here.
    packages = utils.mkAllWithDefault defaultPackage;

    # choose your package for devShell
    # and add whatever else you want in it.
    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [defaultPackage];
        inputsFrom = [];
        shellHook = ''
        '';
      };
    };
  })
  // (let
    # we also export a nixos module to allow reconfiguration from configuration.nix
    nixosModule = utils.mkNixosModules {
      inherit
        defaultPackageName
        dependencyOverlays
        luaPath
        categoryDefinitions
        packageDefinitions
        extra_pkg_config
        nixpkgs
        ;
    };
    # and the same for home manager
    homeModule = utils.mkHomeModules {
      inherit
        defaultPackageName
        dependencyOverlays
        luaPath
        categoryDefinitions
        packageDefinitions
        extra_pkg_config
        nixpkgs
        ;
    };
  in {
    # these outputs will be NOT wrapped with ${system}

    # this will make an overlay out of each of the packageDefinitions defined above
    # and set the default overlay to the one named here.
    overlays =
      utils.makeOverlays luaPath {
        # we pass in the things to make a pkgs variable to build nvim with later
        inherit nixpkgs dependencyOverlays extra_pkg_config;
        # and also our categoryDefinitions
      }
      categoryDefinitions
      packageDefinitions
      defaultPackageName;

    nixosModules.default = nixosModule;
    homeModules.default = homeModule;

    inherit utils nixosModule homeModule;
    inherit (utils) templates;
  })
