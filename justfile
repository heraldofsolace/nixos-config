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

# TODO: Implement.
ci:
  {{ error("Unimplemented") }}

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
