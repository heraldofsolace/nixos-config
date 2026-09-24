{
  perSystem =
    { config, ... }:
    {
      # Runs the same treefmt config `just fmt`/`nix fmt` uses (nixfmt,
      # deadnix, statix, shellcheck, ruff, taplo, toml-sort, mdformat - see
      # formatter.nix) as a pre-commit check, so unformatted/lint-flagged
      # changes can't land silently.
      pre-commit.settings.hooks.treefmt = {
        enable = true;
        packageOverrides.treefmt = config.treefmt.build.wrapper;
      };
    };
}
