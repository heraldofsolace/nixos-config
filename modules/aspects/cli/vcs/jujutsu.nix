{
  flake-file.inputs = {
    jjui = {
      url = "github:idursun/jjui/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  blazar.vcs.nixos = {inputs', ...}: {
    nixpkgs.overlays = [(_final: _prev: {jjui = inputs'.jjui.packages.default;})];
  };

  blazar.vcs.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      lazyjj # Jujutsu TUI.
      # gg-jj # Jujutsu GUI.
      # jj-fzf # Jujutsu TUI.
    ];

    # programs.mergiraf.enableJujutsuIntegration = true;

    # jj.
    programs.jujutsu = {
      enable = true;
      ediff = false;
      settings = {
        user = {
          name = "Aniket Bhattacharyea";
          email = "aniket@abhattacharyea.dev";
        };
        ui = {
          color = "auto"; # "always"
          #default-command = ["log", "--reversed"]
          # default-command = ["log"]

          # At this time, there is basically no reason to use the native backend. It is intented for eventual implementation of
          #  operations not possible in Git itself.
          #allow-init-native = true

          diff-formatter = [
            "difft"
            "--color=always"
            "$left"
            "$right"
          ];
          # diff-formatter = ["delta" "$left" "$right"];
          # diff-formatter = "delta";

          # merge-editor = "meld"; # Using mergiraf.
          merge-tools.meld = {
            merge-args = [
              "$left"
              "$base"
              "$right"
              "-o"
              "$output"
              "--auto-merge"
            ];
            program = lib.getExe pkgs.meld;
          };

          merge-args = [
            "$left"
            "$right"
          ];
          conflict-marker-style = "git";
        };
        signing = {
          behavior = "own";
          backend = "gpg";
          key = "chocholaty.david@protonmail.com";
          # key = "22146EBAB4684AE2907DDC228FC8E68432148DCA";
        };
        git = {
          auto-local-bookmark = false;
          # Prevent pushing work in progress or anything explicitly labeled "private".
          private-commits = ''
            description(glob:'wip:*') |
            description(glob:'[wW][iI][pP]') |
            description(glob:'private:*') |
            description(glob:'todo:*') |
            description(glob:'[tT][oO][dD][oO]')
          '';
        };
        revset-aliases = {
          # Github pages.
          # ghp = 'ancestors(bookmarks(gh-pages) | remote_bookmarks(gh-pages))'
          "wip" = "description(regex:\"^\\[(wip|WIP|todo|TODO)\\]|(wip|WIP|todo|TODO):?\")";

          # "immutable_heads()" = "builtin_immutable_heads() | ghp"

          # 'HEAD' = '@-'
          "user()" = "user(\"chocholaty.david@protonmail.com\")";
          "user(x)" = "author(x) | committer(x)";
        };
        template-aliases = {
          # "format_short_id(id)" = "id.shortest()";
          "format_short_id(id)" = "id.shortest().upper()";
          # "format_short_change_id(id)" = "format_short_id(id)"
        };
        aliases = {
          # Move all bookmarks from the ancestors of the current change to the parrent of the current change.
          tug = [
            "bookmark"
            "move"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
          ];
          n = ["new"];
          e = ["edit"];
          d = ["describe"];
          a = ["abandon"];
          fu = [
            "git"
            "fetch"
            "--remote"
            "upstream"
            "--branch"
            "master"
            "--branch"
            "main"
          ];
          # l = ["log"]
          # l = ["log", "-r", "@ | ancestors(immutable_heads().., 2) | trunk()"]
          # l = ["log", "-r", "@ | ancestors(immutable_heads().., 2) ~ ghp | trunk()"]
          # la = ["log", "-r", "..all() ~ ghp"]
        };
      };
    };

    # Jujutsu TUI.
    programs.jjui = {
      enable = true;
      settings = {
        preview = {
          show_at_start = true;
          extra_args = [
            "--config"
            "ui.diff.tool=['difft', '--color=always', '--width=150', '$left', '$right']"
          ];
        };
        ui = {
          auto_refresh_interval = 10; # In seconds.
          tracer.enabled = true;
        };
        suggest.exec.mode = "fuzzy";
        actions = [
          {
            name = "show-diff";
            lua =
              /*
              lua
              */
              ''
                jj_diff("diff", "--revision", context.change_id(), "--color", "always")
                revisions.refresh()
              '';
          }
          {
            name = "show-oplog-diff";
            lua =
              /*
              lua
              */
              ''
                jj_diff("op", "show", context.operation_id(), "--color", "always")
              '';
          }
          {
            name = "show-after-revisions";
            lua =
              /*
              lua
              */
              ''
                revset.set("::" .. context.change_id())
              '';
          }
          {
            name = "resolve-with-meld";
            lua =
              /*
              lua
              */
              ''
                jj_interactive("resolve", "--tool", "meld")
              '';
          }
          {
            name = "resolve-with-vscodium";
            lua =
              /*
              lua
              */
              ''
                jj_interactive("resolve", "--tool", "vscodium")
              '';
          }
          {
            name = "tug";
            lua =
              /*
              lua
              */
              ''
                jj_async("bookmark", "move", "--from", closest_bookmark(context.change_id()), "--to", closest_pushable(context.change_id()))
              '';
          }
        ];
        bindings = [
          {
            action = "show-diff";
            key = "U";
            scope = "revisions";
            desc = "show diff";
          }
          {
            action = "show-after-revisions";
            key = "M";
            scope = "revisions";
            desc = "show after revisions";
          }
          {
            action = "show-oplog-diff";
            key = "ctrl+o";
            scope = "revisions";
            desc = "show oplog diff";
          }
          {
            action = "resolve-with-meld";
            key = "R";
            scope = "revisions";
            desc = "resolve with Meld";
          }
          {
            action = "tug";
            key = "ctrl+t";
            scope = "revisions";
            desc = "tug the closest bookmarks to the closest pushable change";
          }
          # {
          #   action = "resolve-with-vscodium";
          #   key = "R";
          #   scope = "revisions";
          #   desc = "resolve with VSCodium";
          # }
        ];
        # custom_commands = {
        #   "new master" = {
        #     args = [
        #       "new"
        #       "master"
        #     ];
        #   };
        #};
      };
    };

    programs.television.channels.jj-log = {
      metadata = {
        name = "jj-log";
        description = "A channel to select a change from jj log entries";
        requirements = ["jj"];
      };
      source = {
        command = "${lib.getExe pkgs.jujutsu} log --template builtin_log_oneline --no-graph";
        output = "{split: :0}";
      };
      preview = {
        command = "${lib.getExe pkgs.jujutsu} show '{0}'";
      };
    };
  };
}
