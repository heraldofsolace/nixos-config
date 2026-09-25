_: {
  languages.ruby.enable = true;

  services.postgres.enable = true;
  # Once you've run `rails new . --database=postgresql` and know the app
  # name, point Rails at matching dev/test databases, e.g.:
  #   services.postgres.initialDatabases = [
  #     { name = "myapp_development"; }
  #     { name = "myapp_test"; }
  #   ];

  # Only needed if you pick an asset pipeline that requires Node (esbuild,
  # webpacker, tailwindcss-rails' JS mode). Not needed for importmap-rails.
  # languages.javascript.enable = true;

  # Secrets declared in secretspec.toml (SECRET_KEY_BASE, generated on first
  # use). Deliberately NOT wired into `env.*` here - devenv's own guidance is
  # to keep secrets out of the whole-shell environment and load them only
  # into the process that needs them:
  #   secretspec run -- bin/rails server
  #   secretspec run -- bin/rails db:setup
  # `secretspec` ships with devenv, no separate install needed. If a secret
  # genuinely needs to be shell-wide instead, it's available as
  # config.secretspec.secrets.<NAME> here.

  enterShell = ''
    ruby --version
    bundler --version

    if ! command -v rails >/dev/null; then
      echo "No Rails gem yet - bootstrap with:"
      echo "  gem install rails"
      echo "  rails new . --database=postgresql"
    fi
  '';
}
