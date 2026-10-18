#!/usr/bin/env just --justfile

# Just running `just` shows the list of recipes.
# FIXME: Uncomment when just v1.52 is installed.
# set default-list := true

set dotenv-load
set lazy
set positional-arguments
set unstable

host := `hostname`

mod flake
alias update := flake::update
alias check := flake::check
alias c := flake::check

mod host

alias s := switch
[default]
switch:
  nh os switch "." -- --impure

alias b := boot
boot:
  nh os boot "." -- --impure

alias bd := build
build:
  nh os build "." -- --impure

alias t := test
test:
  nh os test

alias f := fmt
fmt:
  nix fmt

# The gate `worktree::land` runs as its test_cmd: formatting is already a no-op and
# the tree is fully committed, so the flake evaluates exactly what lands. Cheap, and
# green on any tree that is actually ready to merge.
gate:
  nix fmt
  test -z "$(git status --porcelain)"

# `gate` plus the flake's own checks, evaluated but not built (minutes: the options
# evaluation of three hosts dominates). This is where `nix flake check` belongs once
# the tree is green under it — see the kanban ticket about unfree packages.
gate-full: gate
  nix flake check --no-build --accept-flake-config

# Reproduce what CI runs, exit-code faithful and non-interactive: the flake check, evaluated
# against the committed tree with the CI signal on, with no GitHub dependency and nothing
# written into the checkout. Notes:
# - `--no-build` keeps it to what the check actually verifies here -- the evaluation of three
#   host systems, minutes. The derivations are built by the cachix-push job on push.
# - The signal is `ci/ci-runtime.nix`, copied into a throwaway checkout as
#   `modules/ci-runtime.nix`: `modules/` is auto-imported, so it sets `_module.args.CI` for that
#   evaluation only (a tracked copy there would flag every local build as CI).
# - The copy is `git archive HEAD`, so the tree must be committed: the check tests what lands.
# - just propagates the recipe exit code -- today non-zero on unfree polymath / claude-code,
#   reported rather than hidden.
# Reproduce the flake check CI runs locally, exit-code faithful and non-interactive.
ci:
  #!/usr/bin/env bash
  set -euo pipefail
  if [ -n "$(git status --porcelain)" ]; then
    echo "just ci: the tree is dirty -- commit first so the check tests what lands" >&2
    exit 1
  fi
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  git archive HEAD | tar -x -C "$tmp"
  cp ci/ci-runtime.nix "$tmp/modules/ci-runtime.nix"
  nix flake check --no-build --accept-flake-config "path:$tmp"

alias h := help
help:
  just --list --justfile {{justfile()}}

alias g := generate
generate:
  nix run .#generate-files

alias sou := sops-update
sops-update FILE="secrets/*":
    sops updatekeys --yes {{FILE}}

alias su := system-update
system-update: generate flake::update switch

alias ge := generations
generations:
  nh os info
