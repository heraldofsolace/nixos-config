{
  blazar.utils._.obsidian = {
    homeManager =
      { pkgs, ... }:
      {
        stylix.targets.obsidian.vaultNames = [ "nextcloud-notes" ];
        programs.obsidian = {
          enable = true;
          package = pkgs.obsidian; # Set to null if managing your binary via Homebrew Cask

          vaults = {
            "nextcloud-notes" =
              let
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
              in
              {
                enable = true;
                target = "Obsidian"; # Target path relative to your $HOME folder

                settings = {
                  # Core app JSON definitions
                  app = {
                    theme = "obsidian";
                    useMarkdownLinks = true;
                  };

                  # Native management of Core plugins
                  corePlugins = map (name: {
                    inherit name;
                    enable = true;
                  }) allCorePlugins;

                  # Native community plugin declarations with automatic data.json generation
                  communityPlugins =
                    let
                      nextcloudSyncPlugin = pkgs.stdenv.mkDerivation rec {
                        pname = "obsidian-nextcloud-sync";
                        version = "0.7.37"; # Match the version you need

                        # Download the required files exactly as Obsidian expects them
                        srcs = [
                          (pkgs.fetchurl {
                            url = "https://github.com/siosig/obsidian-nextcloudsync/releases/download/${version}/main.js";
                            sha256 = "sha256-Znkxy3sDkD8KHR2/KuT+XfDDEbxrFDxoZndYds5XD+w="; # Replace with actual hash if mismatch occurs
                          })
                          (pkgs.fetchurl {
                            url = "https://github.com/siosig/obsidian-nextcloudsync/releases/download/${version}/manifest.json";
                            sha256 = "sha256-Gl+5avL/kdhrAwTzAFCOjYwWgziOBMj7RJVBLL1hqPU="; # Replace with actual hash if mismatch occurs
                          })
                          (pkgs.fetchurl {
                            url = "https://github.com/siosig/obsidian-nextcloudsync/releases/download/${version}/styles.css";
                            sha256 = "sha256-AI5y06XJcxgBj8IZ1PUrEn0XRVVeEL6boiO1E/prc1U="; # Replace with actual hash if mismatch occurs
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

                        # Required by the Home Manager module to uniquely identify the folder name
                        # inside .obsidian/plugins/
                        manifestId = "nextcloud-sync";
                      };
                      smartConnectionsPlugin = pkgs.stdenv.mkDerivation rec {
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
                            sha256 = "sha256-ARkzdIh0b+cFL3+YQbkt9xUPTi9ky8joJEP6iBKjL+A=";
                          })
                        ];
                        dontUnpack = true;
                        dontBuild = true;
                        installPhase = "mkdir -p $out; for src in $srcs; do cp $src $out/$(stripHash $src); done";
                        manifestId = "smart-connections";
                      };

                      # 3. Obsidian Importer Plugin Derivation (Includes styles.css)
                      obsidianImporterPlugin = pkgs.stdenv.mkDerivation rec {
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
                        manifestId = "obsidian-importer";
                      };
                    in
                    [
                      {
                        pkg = nextcloudSyncPlugin;
                        enable = true;

                        # Feeds parameters straight into nextcloud-sync/data.json via Home Manager
                        settings = {
                          serverUrl = "https://miranda.dorper-ghost.ts.net/remote.php/dav/files/Aniket/"; # Replace with your actual Nextcloud instance
                          syncFolder = "Obsidian"; # Target folder name on the server side
                          syncInterval = 15; # Sync check intervals in minutes
                          syncOnWatch = true; # Pushes files immediately on saving (Desktop only)
                          autoMergeFileStrategy = "Merge"; # Default conflict strategy for markdown files
                          otherFileStrategy = "Latest modified"; # Default strategy for binary data / images
                        };
                      }
                      {
                        pkg = smartConnectionsPlugin;
                        enable = true;
                        # Add custom settings for smart-connections data.json here if desired
                        settings = { };
                      }
                      {
                        pkg = obsidianImporterPlugin;
                        enable = true;
                        # Add custom settings for obsidian-importer data.json here if desired
                        settings = { };
                      }
                    ];
                };
              };
          };
        };
      };
  };
}
