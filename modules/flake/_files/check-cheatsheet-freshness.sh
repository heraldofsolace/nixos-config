#!/usr/bin/env bash
set -euo pipefail

cheatsheet="modules/aspects/desktop/_files/cheatsheet.html"

sources=(
  "modules/aspects/desktop/_files/hyprland.lua"
  "modules/aspects/cli/shells/fish.nix"
  "modules/aspects/cli/shells/bash.nix"
  "modules/aspects/cli/default.nix"
  "modules/aspects/cli/tmux/default.nix"
  "modules/aspects/cli/tmux/_files/tmux.conf"
  "modules/aspects/developement/editors/_anivim/lua/core/keys.lua"
  "modules/aspects/developement/editors/_anivim/lua/plugins/general.lua"
  "modules/aspects/developement/editors/_anivim/lua/plugins/nvim_lsp.lua"
  "modules/aspects/developement/editors/_anivim/lua/plugins/gitsigns.lua"
  "modules/aspects/cli/vcs/git.nix"
  "modules/aspects/cli/vcs/jujutsu.nix"
  "modules/aspects/cli/vcs/lazygit.nix"
)
mini_dir="modules/aspects/developement/editors/_anivim/lua/plugins/mini"

staged=$(git diff --cached --name-only)

changed=()
for f in "${sources[@]}"; do
  if grep -qxF "$f" <<<"$staged"; then
    changed+=("$f")
  fi
done
if grep -q "^${mini_dir}/" <<<"$staged"; then
  changed+=("$mini_dir/*")
fi

if [ "${#changed[@]}" -eq 0 ]; then
  exit 0
fi

if grep -qxF "$cheatsheet" <<<"$staged"; then
  exit 0
fi

{
  echo "Keybind/alias source file(s) changed but $cheatsheet wasn't updated in this commit:"
  printf '  - %s\n' "${changed[@]}"
  echo
  echo "Ask Claude to regenerate the cheatsheet, or 'git commit --no-verify' if this is intentional."
} >&2
exit 1
