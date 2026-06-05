{
  config,
  lib,
  flake-parts-lib,
  ...
}: let
  outerCfg = config.files;
in {
  # imports = [
  #   "${inputs.files}/flake-module.nix"
  # ];

  # https://github.com/vidhanio/vidhanix/blob/62305aa1a355b2519ab4449a3cf38334ccafbc89/modules/files/options.nix
  options = {
    files.generatedWarningMessage = {
      text = lib.mkOption {
        type = lib.types.str;
        description = "Text to include in the generated comment at the top of generated files.";
        default = ''
          DO-NOT-EDIT.
          This file was auto-generated using github:mightyiam/files.
          Use `nix run .#write-files` to regenerate it.'';
      };
      formatters = lib.mkOption {
        type = lib.types.attrsOf (lib.types.functionTo lib.types.str);
        description = "Functions to format comments for different file types.";
        default = let
          hashSign = text: lib.concatMapStringsSep "\n" (line: "# ${line}") (lib.splitString "\n" text);
        in {
          md = text: "<!-- ${text} -->";
          sh = hashSign;
          envrc = hashSign;
          gitignore = hashSign;
          toml = hashSign;
          license = _: "";
        };
        readOnly = true;
      };
      # textFormatted =
      #   fileType:
      #   lib.mkOption {
      #     type = lib.types.str;
      #     description = "Warning message test formatted for the fiven file type.";
      #     default =
      #       config.files.generatedWarningMessage.formatters.${fileType}
      #         config.files.generatedWarningMessage.text;
      #   };
    };

    perSystem = flake-parts-lib.mkPerSystemOption (
      {
        config,
        pkgs,
        ...
      }: let
        cfg = config.files;
      in {
        options.files = {
          file = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                {
                  name,
                  config,
                  ...
                }: {
                  options = {
                    fileType = lib.mkOption {
                      type = lib.types.enum (lib.attrNames outerCfg.generatedWarningMessage.formatters);
                      description = "Type of the file, used to determine comment style.";
                      default = lib.toLower (lib.last (lib.splitString "." name));
                    };
                    generateWarningMessage = lib.mkEnableOption "Whether to generate warning message at the top of the file";
                    text = lib.mkOption {
                      type = lib.types.nullOr lib.types.lines;
                      description = "Text content of the file.";
                      default = null;
                    };
                    source = lib.mkOption {
                      type = lib.types.path;
                      description = "Path to a source file to use as the content of the file.";
                    };
                  };

                  config = {
                    source = lib.mkIf (config.text != null) (pkgs.writeText "file-${name}" config.text);
                  };
                }
              )
            );
          };
        };

        config = {
          files.files =
            lib.mapAttrsToList (
              name: {
                fileType,
                source,
                generateWarningMessage,
                ...
              }: {
                path = name;
                drv =
                  pkgs.runCommandLocal "files-${name}"
                  {
                    comment =
                      # outerCfg.generatedWarningMessage.textFormatted fileType;
                      let
                        mkComment = outerCfg.generatedWarningMessage.formatters.${fileType};
                      in
                        if generateWarningMessage && outerCfg.mkComment != null
                        then mkComment outerCfg.generatedWarningMessage.text
                        else "";
                    inherit source;
                  }
                  ''
                    mkdir -p "$(dirname "${name}")"
                    touch "${name}"
                    if [ -n "$comment" ]; then
                      echo "$comment" >> "${name}"
                    fi
                    cat "${source}" >> "${name}"
                    # ensure that it uses correct exclusion rules by naming the file properly
                    ${lib.getExe config.treefmt.build.wrapper} --no-cache --tree-root-file "${name}" "${name}"
                    mv "${name}" $out
                  '';
              }
            )
            cfg.file;
        };
      }
    );
  };
  config.flake-file.inputs.files = {
    # FIXME: Unpin when compatibility with warning message is restored.
    url = "github:mightyiam/files/bec7bba1cfd70a6305c8a690b33dac5771812a28";
    flake = false;
  };
  config.perSystem = {
    config,
    pkgs,
    self',
    ...
  }: {
    apps.write-files = {
      program = config.files.writer.drv;
      meta.description = "Generate files using github:mightyiam/files.";
    };

    # https://github.com/vidhanio/vidhanix/blob/62305aa1a355b2519ab4449a3cf38334ccafbc89/modules/files/default.nix
    apps.generate-files = let
      description = "Generate all automatically generated files for this repository";
    in {
      meta.decription = description;
      program = pkgs.writeShellApplication {
        name = "generate-files";
        meta.description = description;
        text = ''
          # github:mightyiam/files.
          ${self'.apps.write-files.program}

          lock_bck=$(mktemp)
          cp -p flake.lock "$lock_bck"

          ${lib.getExe self'.packages.write-flake}

          # If flake.lock remains unchanged, restore mtime.
          if cmp -s flake.lock "$lock_bck"; then
            touch -r "$lock_bck" flake.lock
          fi
        '';
      };
    };

    # https://github.com/vidhanio/vidhanix/blob/62305aa1a355b2519ab4449a3cf38334ccafbc89/modules/files/default.nix
    pre-commit.settings.hooks.generate-files = {
      enable = true;
      package = config.packages.generate-files;
      entry = self'.apps.generate-files.program;
      pass_filenames = false;
    };

    # files.readme.content.generated-files.content = ''
    #   most of the non-nix files in this repository (including this very readme) are generated via [`nix run .#generate-files`](modules/files/default.nix).
    #   the generated files are:

    #   ${config.files.readme.lib.renderList (
    #     map (p: "[`${p}`](${p})") (lib.sortOn (p: p) (map ({ path_, ... }: path_) config.files.files))
    #   )}
    # '';
  };
}
