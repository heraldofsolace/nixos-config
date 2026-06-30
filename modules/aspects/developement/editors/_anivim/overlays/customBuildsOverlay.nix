importName: _inputs:
let
  overlay = _self: super: rec {
    ${importName} = rec {
      vim-schlepp = super.vimUtils.buildVimPlugin {
        pname = "vim-schlepp";
        version = "2018-05-04";
        src = super.fetchFromGitHub {
          owner = "zirrostig";
          repo = "vim-schlepp";
          rev = "master";
          sha256 = "NNoHvLNIIjZLNHsI3jrhbsHmSO0eOldP0s7nMBMJoXE=";
        };
      };

      guihua-lua = super.vimUtils.buildVimPlugin {
        pname = "guihua.lua";
        version = "2025-11-12";
        src = super.fetchFromGitHub {
          owner = "ray-x";
          repo = "guihua.lua";
          rev = "ef44ba40f12e56c1c9fa45967f2b4d142e4b97a0";
          sha256 = "sha256-9iFqh12orsGnQniDloO+aXoBYuTqOW4pGHi3LBB2m4Q=";
        };
        buildPhase = ''
          cd lua/fzy && make
          cd ../..
        '';
        doCheck = false;
      };

      navigator-lua = super.vimUtils.buildVimPlugin {
        pname = "navigator.lua";
        version = "2025-10-30";
        src = super.fetchFromGitHub {
          owner = "ray-x";
          repo = "navigator.lua";
          rev = "deaf00338fe288d24f5632b1842130f8d9c15b0a";
          sha256 = "sha256-VjKaSzibXFufCGb6x2RFtkgWTDqZQRbdNtgXQgDUGys=";
        };
        doCheck = false;
        depenedencies = [ guihua-lua ];
      };

      inlay-hints-nvim = super.vimUtils.buildVimPlugin {
        pname = "inlay-hints.nvim";
        version = "2025-12-25";
        src = super.fetchFromGitHub {
          owner = "MysticalDevil";
          repo = "inlay-hints.nvim";
          rev = "12c48937702906f67dfbd7f64b1c0d8861635506";
          sha256 = "sha256-zCR7VnFbcWsE52Ytc9IluY1EjKNPxGDTo2quMOekIGE=";
        };
      };
    };
  };
in
overlay
