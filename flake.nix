# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "My personal Nix configuration, built with Dendritic.";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  nixConfig = {
    accept-flake-config = true;
    allow-import-from-derivation = true;
    auto-optimise-store = true;
    experimental-features = [
      "auto-allocate-uids"
      "blake3-hashes"
      "ca-derivations"
      "cgroups"
      "dynamic-derivations"
      "fetch-closure"
      "flakes"
      "impure-derivations"
      "nix-command"
      "parse-toml-timestamps"
      "pipe-operators"
      "read-only-local-store"
      "recursive-nix"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.flox.dev"
      "https://numtide.cachix.org"
      "https://cache.numtide.com"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE"
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
    lint-url-literals = "fatal";
    submodules = true;
    use-xdg-base-directories = true;
  };

  inputs = {
    dankMaterialShell = {
      inputs.nixpkgs.follows = "latest";
      url = "github:nick-linux8/DankMaterialShell/master";
    };
    danksearch = {
      inputs.nixpkgs.follows = "latest";
      url = "github:AvengeMedia/danksearch";
    };
    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-darwin/nix-darwin";
    };
    den.url = "github:vic/den";
    dendrix.url = "github:vic/dendrix";
    determinate = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    };
    determinate-nix.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    dgop = {
      inputs.nixpkgs.follows = "latest";
      url = "github:AvengeMedia/dgop";
    };
    dolphin-overlay.url = "github:rumboon/dolphin-overlay";
    elephant.url = "github:abenz1267/elephant";
    files.url = "github:mightyiam/files";
    flake-aspects.url = "github:vic/flake-aspects";
    flake-compat.url = "github:nix-community/flake-compat";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    flake-utils = {
      inputs.systems.follows = "systems";
      url = "github:numtide/flake-utils";
    };
    git-hooks-nix = {
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:cachix/git-hooks.nix";
    };
    github-gitignore = {
      flake = false;
      url = "github:github/gitignore";
    };
    hjem.follows = "hjem-rum/hjem";
    hjem-rum = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
      url = "github:snugnug/hjem-rum";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-25.11";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hyprwm/contrib";
    };
    hyprland-plugins = {
      inputs.hyprland.follows = "hyprland";
      url = "github:hyprwm/hyprland-plugins";
    };
    hyprland-profile-switcher.url = "github:heraldofsolace/hyprland-profile-switcher";
    ignoreBoy = {
      inputs = {
        gitignore-repo.follows = "github-gitignore";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "git-hooks-nix";
        systems.follows = "systems";
      };
      url = "github:Ookiiboy/ignoreBoy";
    };
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    jjui = {
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:idursun/jjui/main";
    };
    latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    make-shell = {
      inputs.flake-compat.follows = "flake-compat";
      url = "github:nicknovitski/make-shell";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-formatter-pack = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Gerschtli/nix-formatter-pack";
    };
    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-index-database";
    };
    nix-maid.url = "github:viperML/nix-maid";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    nixos.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-lib.follows = "nixpkgs";
    noctalia = {
      inputs.nixpkgs.follows = "latest";
      url = "github:noctalia-dev/noctalia-shell";
    };
    nur = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/NUR";
    };
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    quickshell = {
      inputs.nixpkgs.follows = "latest";
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    };
    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
    stylix.url = "github:nix-community/stylix/release-25.11";
    sysc-greet = {
      inputs.nixpkgs.follows = "latest";
      url = "github:deephack1982/sysc-greet";
    };
    systems.url = "github:nix-systems/x86_64-linux";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    tsui = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:guibou/tsui";
    };
    walker = {
      inputs.elephant.follows = "elephant";
      url = "github:abenz1267/walker";
    };
    xdg-ninja = {
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:b3nj5m1n/xdg-ninja";
    };
  };

}
