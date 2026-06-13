alias u := update
update *ARGS:
  nix flake update {{ARGS}}

alias c := check
[default]
check:
  nix flake check

alias s := show
show:
  nix flake show
