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
          version = "0.24.6-rc.3";
          tag = "iii/v${version}";
          base = "https://github.com/iii-hq/iii/releases/download/${tag}";

          # sha256 values taken verbatim from the upstream *.sha256 files for
          # this release and cross-checked with `sha256sum` on the downloaded
          # tarballs. Bump `version` and every sha256 together; the upstream tag is `iii/v0.24.6-rc.3`.
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
            sha256 = "c8ad9acce63c82e6bcd4abdbf5ec52ce4a326cc91c8b53970700e30ecfe79a1f";
          };
          # iii-init is a libkrun microVM init binary that iii itself spawns
          # inside a sandboxed guest; it is not meant to be invoked directly
          # by a user (it tries to mkdir /new-root, which fails even for a
          # privileged interactive shell). Pinned here only so its hash and
          # presence are recorded; see EXPERIMENT_LOG.md.
          iii-init = mkIiiBin {
            pname = "iii-init";
            sha256 = "79499b1738f9dcc0fb312226026414d39bfee7b4944b92bb3063206398ac3899";
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
              sha256 = "0ff1fe7cbf720f3d15014727e6c0d931ea25a0907ed2246cc74a6593336905bb";
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
            sha256 = "f83a9a101f838353ba4b328c2cce15cbcbfbc8ba5b3c815903d2d1ce2684b120";
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
          shellHook = ''
            ${self'.checks.pre-commit}
            # iii's local-worker launcher dlopens libkrun to boot a microVM for a
            # `path://` worker, and NixOS has no loader cache to find it in: without
            # this, a path worker fails before it starts (no process, no log).
            export LD_LIBRARY_PATH="${pkgs.libkrun}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          '';
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
