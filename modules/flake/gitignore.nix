{ inputs, ... }: {
  flake-file.inputs = {
    github-gitignore = {
      url = "github:github/gitignore";
      flake = false;
    };

    ignoreBoy = {
      url = "github:Ookiiboy/ignoreBoy";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        gitignore-repo.follows = "github-gitignore";
        pre-commit-hooks.follows = "git-hooks-nix";
        systems.follows = "systems";
      };
    };
  };

  perSystem = { system, ... }: {
    files.file.".gitignore".source = inputs.ignoreBoy.lib.${system}.generateGitIgnore {
      # https://github.com/github/gitignore
      # - use this repo, and add the filename and/ or path/filename to the array, drop the extension. Note the
      #  uppercase filenames.
      github.languages = [
        # "community/JavaScript/Vue"
        "Nix"
      ];

      # `curl -sL https://www.toptal.com/developers/gitignore/api/list`
      # - this will give you a list of supported languages.
      # https://www.toptal.com/developers/gitignore/
      gitignoreio.languages = [
        # "node"
      ];

      # GOTCHA: This will fail on first run, you will need to copy the hash into
      #    the attribute. **Everytime** you update the `gitignoreio.languages`, delete
      #    the hash, re-run the shell, and copy the updated hash back into the
      #    attribute after the next fail again. This will force the input to refresh,
      #    and make a new API request. Otherwise it will remain cached.
      # gitignoreio.hash = "";

      # Defaults to `true`, but you can set to false if you don't want OS related
      #    ignores. You don't usually need to specify. It's here for clarity.
      # useSaneDefaults = true;

      # Anything custom you might want in your .gitignore you can place in this
      #    extraConfig.
      extraConfig = ''
        *.qcow2?
        #  .editorconfig
        #  .pre-commit-config.yaml
      '';
    };
  };
}
