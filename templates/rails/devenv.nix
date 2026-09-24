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
