{
  flake.templates = {
    typst = {
      path = ../../templates/typst;
      description = "Typst document with a devenv-based dev shell (typst, typstyle, tinymist LSP)";
    };

    rails = {
      path = ../../templates/rails;
      description = "Ruby on Rails devenv-based dev shell (ruby, bundler, solargraph LSP, PostgreSQL service)";
    };
  };
}
