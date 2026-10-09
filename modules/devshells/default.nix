{
  inputs,
  config,
  ...
}:
{
  flake-file.inputs.make-shell = {
    url = "github:nicknovitski/make-shell";
    inputs.flake-compat.follows = "flake-compat";
  };
  flake-file.inputs.nixos-anywhere = {
    url = "github:nix-community/nixos-anywhere";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.omnix = {
    url = "github:juspay/omnix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [
    inputs.make-shell.flakeModules.default
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      pkgs,
      lib,
      self',
      inputs',
      ...
    }:
    {
      files.file.".envrc" = {
        generateWarningMessage = false;
        # ${config.files.generateWarningMessage.textFormatted}
        text = ''
          #!/usr/bin/env sh
          # shellcheck shell=bash

          ${lib.concatMapStringsSep "\n" (line: "# ${line}") (
            lib.splitString "\n" config.files.generatedWarningMessage.text
          )}

          #use flake
          use flake path:. --impure

          dotenv_if_exists .env.private
          source_env_if_exists .envrc.private
        '';
      };

      make-shells.default =
        let
          version = "0.24.4";
          tag = "iii/v${version}";
          base = "https://github.com/iii-hq/iii/releases/download/${tag}";

          # sha256 values taken verbatim from the upstream *.sha256 files for
          # this release and cross-checked with `sha256sum` on the downloaded
          # tarballs. Bump `version` and every sha256 together; the upstream tag is `iii/v0.24.4`.
          mkIiiBin =
            {
              pname,
              sha256,
              target ? "unknown-linux-musl",
            }:
            pkgs.stdenvNoCC.mkDerivation {
              inherit pname version;
              src = pkgs.fetchurl {
                url = "${base}/${pname}-x86_64-${target}.tar.gz";
                inherit sha256;
              };
              sourceRoot = ".";
              dontBuild = true;
              # musl builds here are static-pie; nothing to patch for NixOS.
              installPhase = ''
                mkdir -p $out/bin
                install -m 755 ${pname} $out/bin/${pname}
              '';
            };

          iii-bin = mkIiiBin {
            pname = "iii";
            sha256 = "21da5cacc28b2d8a430662d8d99339ab258df32029d5448f1ed6746b4b9b5aee";
          };
          # iii-init is a libkrun microVM init binary that iii itself spawns
          # inside a sandboxed guest; it is not meant to be invoked directly
          # by a user (it tries to mkdir /new-root, which fails even for a
          # privileged interactive shell). Pinned here only so its hash and
          # presence are recorded; see EXPERIMENT_LOG.md.
          iii-init = mkIiiBin {
            pname = "iii-init";
            sha256 = "b17de7d63c0469246e7c2d06bc5e080778896d0fd3c559ec7e5611b766b9512c";
          };
          # iii-worker's musl build is dynamically linked against
          # /lib/ld-musl-x86_64.so.1 ("dynamic musl for firmware loading" per
          # the upstream installer's own comment), which NixOS does not provide
          # at that absolute path. Use the glibc build + autoPatchelfHook
          # instead, which nixpkgs can relink to its own glibc.
          iii-worker = pkgs.stdenv.mkDerivation {
            pname = "iii-worker";
            inherit version;
            src = pkgs.fetchurl {
              url = "${base}/iii-worker-x86_64-unknown-linux-gnu.tar.gz";
              sha256 = "f7b95e6103f6fedd5d9cf730c418f0ceb8a482c7534fabcd55bb96a5b345f514";
            };
            sourceRoot = ".";
            dontBuild = true;
            nativeBuildInputs = [ pkgs.autoPatchelfHook ];
            buildInputs = [
              pkgs.libcap_ng
              pkgs.stdenv.cc.cc.lib
            ];
            installPhase = ''
              mkdir -p $out/bin
              install -m 755 iii-worker $out/bin/iii-worker
            '';
          };
          iii-console = mkIiiBin {
            pname = "iii-console";
            sha256 = "d4dbf9566cea5679529db122252dedd73c9cab25181c26dde9defb3ad9087f2f";
          };
        in
        {
          packages = with pkgs; [
            nixfmt
            nixd
            statix
            deadnix
            yazi
            zellij
            git
            jujutsu
            jjui
            neovim
            dysk
            nh
            just
            treefmt
            alejandra
            shfmt
            deploy-rs
            claude-code
            nix-du
            nurl
            cachix
            nix-melt
            nixpkgs-hammering
            angrr
            inputs'.nixos-anywhere.packages.default
            inputs'.omnix.packages.default
            iii-bin
            iii-init
            iii-worker
            iii-console
          ];
          shellHook = "${self'.checks.pre-commit}";
        };

      make-shells.latex = {
        packages = with pkgs; [
          tex-fmt
          coreutils
          (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-full latex-bin latexmk; })
          texlive.combined.scheme-full
          texlab
          tectonic
          rubber
          gnumake
        ];
      };
    };
}
