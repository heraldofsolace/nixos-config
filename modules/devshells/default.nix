{
  inputs,
  config,
  ...
}: {
  flake-file.inputs.make-shell = {
    url = "github:nicknovitski/make-shell";
    inputs.flake-compat.follows = "flake-compat";
  };

  imports = [
    inputs.make-shell.flakeModules.default
  ];

  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    files.file.".envrc" = {
      generateWarningMessage = false;
      # ${config.files.generateWarningMessage.textFormatted}
      text = ''
        #!/usr/bin/env sh
        # shellcheck shell=bash

        ${lib.concatMapStringsSep "\n" (line: "# ${line}") (
          lib.splitString "\n" config.files.generatedWarningMessage.text
        )}

        use flake
        #use flake path:. --impure

        dotenv_if_exists .env.private
        source_env_if_exists .envrc.private
      '';
    };

    make-shells.default = {
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
      ];
    };

    make-shells.latex = {
      packages = with pkgs; [
        tex-fmt
        coreutils
        (pkgs.texlive.combine {inherit (pkgs.texlive) scheme-full latex-bin latexmk;})
        texlive.combined.scheme-full
        texlab
        tectonic
        rubber
        gnumake
      ];
    };
  };
}
