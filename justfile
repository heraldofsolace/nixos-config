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
  nh os switch

alias b := boot
boot:
  nh os boot

alias bd := build
build:
  nh os build

alias t := test
test:
  nh os test

alias f := fmt
fmt:
  nix fmt

# TODO: Implement.
ci:
  @ error make "Unimplemented"

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
