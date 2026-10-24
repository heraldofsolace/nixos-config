# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
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
      "https://heraldofsolace.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.flox.dev"
      "https://numtide.cachix.org"
      "https://cache.numtide.com"
      "https://install.determinate.systems"
      "https://nyx-cache.chaotic.cx/"
    ];
    extra-trusted-public-keys = [
      "heraldofsolace.cachix.org-1:9lDlToY337Al15dD5qga1RUkc98rhYKlFhPxxaD4I+s="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE"
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
    lint-url-literals = "fatal";
    submodules = true;
    use-xdg-base-directories = true;
  };

  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/5ce5dc04c257f328f35f068ff1575064b5598c8c";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dankMaterialShell = {
      url = "github:nick-linux8/DankMaterialShell/master";
      inputs.nixpkgs.follows = "latest";
    };
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "latest";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    den.url = "github:denful/den";
    deploy-rs.url = "github:serokell/deploy-rs";
    determinate-nix.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "latest";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    elephant.url = "github:abenz1267/elephant";
    files = {
      url = "github:mightyiam/files/bec7bba1cfd70a6305c8a690b33dac5771812a28";
      flake = false;
    };
    flake-compat.url = "github:nix-community/flake-compat";
    flake-file.url = "github:denful/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };
    github-gitignore = {
      url = "github:github/gitignore";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-profile-switcher.url = "github:heraldofsolace/hyprland-profile-switcher";
    hyprqt6engine.url = "github:hyprwm/hyprqt6engine";
    ignoreBoy = {
      url = "github:Ookiiboy/ignoreBoy";
      inputs = {
        gitignore-repo.follows = "github-gitignore";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "git-hooks-nix";
        systems.follows = "systems";
      };
    };
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:denful/import-tree";
    jjui = {
      url = "github:idursun/jjui/main";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    lian-li-linux.url = "github:heraldofsolace/lian-li-linux/449db489aea2a1673e5e0ffd458223ba9d6ef543";
    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "flake-compat";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    nixflix = {
      url = "github:kiriwalawren/nixflix";
      inputs.nixpkgs.follows = "latest";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-multiverse.url = "github:fzakaria/nixpkgs-multiverse";
    noctalia-v5.url = "github:noctalia-dev/noctalia/cachix";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omnix = {
      url = "github:juspay/omnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    phone-deck.url = "github:heraldofsolace/phone-deck";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    prismnix = {
      url = "github:qacow37/prismnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "latest";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:nix-community/stylix/release-26.05";
    systems.url = "github:nix-systems/x86_64-linux";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tsui = {
      url = "github:guibou/tsui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
    xdg-ninja = {
      url = "github:b3nj5m1n/xdg-ninja";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    zen = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "latest";
    };
  };
}
