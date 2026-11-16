{
  blazar.utils._.obsidian = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        vaultTarget = "Obsidian"; # Target path relative to your $HOME folder
        vaultDir = "${config.home.homeDirectory}/${vaultTarget}/.obsidian";

        jsonFormat = pkgs.formats.json { };
        jq = lib.getExe pkgs.jq;

        # List containing all 31 requested core plugin names
        allCorePlugins = [
          "audio-recorder"
          "backlink"
          "bases"
          "bookmarks"
          "canvas"
          "command-palette"
          "daily-notes"
          "editor-status"
          "file-explorer"
          "file-recovery"
          "footnotes"
          "global-search"
          "graph"
          "markdown-importer"
          "note-composer"
          "outgoing-link"
          "outline"
          "page-preview"
          "properties"
          "publish"
          "random-note"
          "slash-command"
          "slides"
          "switcher"
          "sync"
          "tag-pane"
          "templates"
          "webviewer"
          "word-count"
          "workspaces"
          "zk-prefixer"
        ];

        # Community plugins, keyed by the plugin id Obsidian expects as the
        # directory name under .obsidian/plugins/. The payload
        # (main.js/manifest.json/styles.css) is immutable and linked straight
        # from the store; `settings` are only the keys we insist on - the
        # plugin stays free to write anything else into its own data.json.
        plugins = {
          "nextcloud-sync" = {
            pkg = pkgs.stdenv.mkDerivation rec {
              pname = "obsidian-nextcloud-sync";
              version = "0.7.37"; # Match the version you need

              # Download the required files exactly as Obsidian expects them
              srcs = [
                (pkgs.fetchurl {
                  url = "https://github.com/siosig/obsidian-nextcloudsync/releases/download/${version}/main.js";
                  sha256 = "sha256-Znkxy3sDkD8KHR2/KuT+XfDDEbxrFDxoZndYds5XD+w=";
                })
                (pkgs.fetchurl {
                  url = "https://github.com/siosig/obsidian-nextcloudsync/releases/download/${version}/manifest.json";
                  sha256 = "sha256-Gl+5avL/kdhrAwTzAFCOjYwWgziOBMj7RJVBLL1hqPU=";
                })
                (pkgs.fetchurl {
                  url = "https://github.com/siosig/obsidian-nextcloudsync/releases/download/${version}/styles.css";
                  sha256 = "sha256-AI5y06XJcxgBj8IZ1PUrEn0XRVVeEL6boiO1E/prc1U=";
                })
              ];

              # Disable standard build phases since we are just moving compiled assets
              dontUnpack = true;
              dontBuild = true;

              installPhase = ''
                mkdir -p $out
                # Loop through the downloaded sources and place them into the output directory
                for src in $srcs; do
                  # Extract the original clean file name from the Nix store path
                  name=$(stripHash "$src")
                  cp "$src" "$out/$name"
                done
              '';
            };

            settings = {
              serverUrl = "https://miranda.dorper-ghost.ts.net/remote.php/dav/files/Aniket/";
              syncFolder = "Obsidian"; # Target folder name on the server side
              syncInterval = 15; # Sync check intervals in minutes
              syncOnWatch = true; # Pushes files immediately on saving (Desktop only)
              autoMergeFileStrategy = "Merge"; # Default conflict strategy for markdown files
              otherFileStrategy = "Latest modified"; # Default strategy for binary data / images
            };
          };

          "smart-connections".pkg = pkgs.stdenv.mkDerivation rec {
            pname = "obsidian-smart-connections";
            version = "4.5.3"; # Tracked from GitHub release versions
            srcs = [
              (pkgs.fetchurl {
                url = "https://github.com/brianpetro/obsidian-smart-connections/releases/download/${version}/main.js";
                sha256 = "sha256-EcQisXVTuaCcnSVpX/qRAAhFkgQV1qMuWwwqPbxB4B8=";
              })
              (pkgs.fetchurl {
                url = "https://github.com/brianpetro/obsidian-smart-connections/releases/download/${version}/manifest.json";
                sha256 = "sha256-ayTD+fR9/BLml5RmB7GX0OSTGny9eh1EWpK0d7TxLtI=";
              })
              (pkgs.fetchurl {
                url = "https://github.com/brianpetro/obsidian-smart-connections/releases/download/${version}/styles.css";
                sha256 = "sha256-chk2ZA5gjEp0AkvSKjVFiaz/Zo2caI6IN4FVMFbIj9c=";
              })
            ];
            dontUnpack = true;
            dontBuild = true;
            installPhase = "mkdir -p $out; for src in $srcs; do cp $src $out/$(stripHash $src); done";
          };

          "obsidian-importer".pkg = pkgs.stdenv.mkDerivation rec {
            pname = "obsidian-importer";
            version = "1.8.12";
            srcs = [
              (pkgs.fetchurl {
                url = "https://github.com/obsidianmd/obsidian-importer/releases/download/${version}/main.js";
                sha256 = "sha256-b9spVnNifBbTsgRxxYULwboHPjMqC7QjBHeBtb5cbhI=";
              })
              (pkgs.fetchurl {
                url = "https://github.com/obsidianmd/obsidian-importer/releases/download/${version}/manifest.json";
                sha256 = "sha256-UJVB7h/eb/VEukCSiZzP9zzFJc1Qf60ZI9ZS8S3KiKQ=";
              })
              (pkgs.fetchurl {
                url = "https://github.com/obsidianmd/obsidian-importer/releases/download/${version}/styles.css";
                sha256 = "sha256-ARkzdIh0b+cFL3+YQbkt9xUPTi9ky8joJEP6iBKjL+A=";
              })
            ];
            dontUnpack = true;
            dontBuild = true;
            installPhase = "mkdir -p $out; for src in $srcs; do cp $src $out/$(stripHash $src); done";
          };
        };

        # Stylix still computes the fonts/colours for us via `defaultSettings`;
        # we just don't let it (or the Obsidian module) link them into the
        # vault - see the comment on `mutableSettings` below.
        stylixAppearance = config.programs.obsidian.defaultSettings.appearance;
        stylixSnippets = lib.optionals (
          config.programs.obsidian.defaultSettings.cssSnippets != null
        ) config.programs.obsidian.defaultSettings.cssSnippets;

        # Every file in here is one Obsidian itself rewrites whenever a setting
        # changes in the UI. They must NOT be home.file symlinks: the store copy
        # is read-only, so Obsidian's write fails outright and the change is
        # lost the next time the app (or the machine) restarts. Instead these
        # values are merged *into* the live file on each activation - Nix wins
        # for the keys it declares, the UI keeps everything else it wrote.
        mutableSettings = {
          "app.json" = {
            theme = "obsidian";
            useMarkdownLinks = true;
          };
          "appearance.json" = lib.optionalAttrs (stylixAppearance != null) stylixAppearance;
          "core-plugins.json" = lib.genAttrs allCorePlugins (_: true);
        }
        // lib.mapAttrs' (id: plugin: lib.nameValuePair "plugins/${id}/data.json" plugin.settings) (
          lib.filterAttrs (_: plugin: plugin ? settings) plugins
        );

        generate = rel: value: jsonFormat.generate (baseNameOf rel) value;

        # Enabled-plugin / enabled-snippet lists are JSON arrays, so they get
        # unioned rather than object-merged: what we declare is always on, and
        # anything enabled by hand survives.
        enabledPlugins = jsonFormat.generate "community-plugins.json" (builtins.attrNames plugins);
        enabledSnippets = map (snippet: snippet.name) stylixSnippets;
      in
      {
        # Stylix populates `programs.obsidian.defaultSettings` regardless; an
        # empty vaultNames keeps it from writing appearance.json and the
        # snippet into the vault as read-only symlinks. We re-apply the exact
        # same values ourselves, mutably, below.
        stylix.targets.obsidian.vaultNames = [ ];

        programs.obsidian = {
          enable = true;
          package = pkgs.obsidian; # Set to null if managing your binary via Homebrew Cask

          # The vault entry exists only to register the vault in
          # ~/.config/obsidian/obsidian.json. Settings are deliberately left
          # unmanaged (null, overriding the stylix-provided defaults) so the
          # module links nothing into .obsidian/.
          vaults."nextcloud-notes" = {
            enable = true;
            target = vaultTarget;
            settings = {
              appearance = null;
              cssSnippets = null;
            };
          };
        };

        # Immutable assets: plugin payloads and generated CSS. Obsidian only
        # ever reads these, so store symlinks are exactly right here.
        home.file =
          lib.mapAttrs' (
            id: plugin:
            lib.nameValuePair "${vaultTarget}/.obsidian/plugins/${id}" {
              source = plugin.pkg;
              recursive = true;
            }
          ) plugins
          // builtins.listToAttrs (
            map (snippet: {
              name = "${vaultTarget}/.obsidian/snippets/${snippet.name}.css";
              value =
                if snippet.source != null then { inherit (snippet) source; } else { inherit (snippet) text; };
            }) stylixSnippets
          );

        home.activation.obsidianSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          # Merge a declared JSON object into the live file, declared keys
          # winning. A leftover symlink from an older generation (when these
          # files were still store-linked) is dropped first.
          obsidianMergeObject() {
            local target="${vaultDir}/$1" declared="$2" tmp
            if [[ -L "$target" ]]; then
              run rm -f "$target"
            fi
            if [[ -f "$target" ]]; then
              tmp="$(mktemp)"
              run ${jq} -s '(.[0] // {}) * (.[1] // {})' "$target" "$declared" > "$tmp"
              run install -m644 "$tmp" "$target"
              rm -f "$tmp"
            else
              verboseEcho "Seeding $target"
              run install -D -m644 "$declared" "$target"
            fi
          }

          # Union a declared JSON array into the live file.
          obsidianMergeArray() {
            local target="${vaultDir}/$1" declared="$2" tmp
            if [[ -L "$target" ]]; then
              run rm -f "$target"
            fi
            if [[ -f "$target" ]]; then
              tmp="$(mktemp)"
              run ${jq} -s '((.[0] // []) + .[1]) | unique' "$target" "$declared" > "$tmp"
              run install -m644 "$tmp" "$target"
              rm -f "$tmp"
            else
              verboseEcho "Seeding $target"
              run install -D -m644 "$declared" "$target"
            fi
          }

          ${lib.concatLines (
            lib.mapAttrsToList (
              rel: value: ''obsidianMergeObject "${rel}" "${generate rel value}"''
            ) mutableSettings
          )}
          obsidianMergeArray "community-plugins.json" "${enabledPlugins}"

          ${lib.optionalString (enabledSnippets != [ ]) ''
            # appearance.json exists by now (merged above); make sure our
            # snippets are listed without dropping any the user enabled.
            snippetsTmp="$(mktemp)"
            run ${jq} --argjson want '${builtins.toJSON enabledSnippets}' \
              '.enabledCssSnippets = (((.enabledCssSnippets // []) + $want) | unique)' \
              "${vaultDir}/appearance.json" > "$snippetsTmp"
            run install -m644 "$snippetsTmp" "${vaultDir}/appearance.json"
            rm -f "$snippetsTmp"
          ''}
        '';
      };
  };
}
