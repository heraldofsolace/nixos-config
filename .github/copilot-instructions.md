<!--
Short, actionable guidance for AI coding agents working on this repo.
The canonical, detailed guide is CLAUDE.md at the repository root — read it first.
Keep this file ~20-50 lines: orientation only, no duplicated detail.
-->

# Copilot / AI agent instructions — Aniket's NixOS config

**`CLAUDE.md` at the repository root is the canonical guide** for this repo: hosts,
architecture, commands, CI, secrets, formatter, and the iii agent stack. Read it
before making changes; this file only orients you.

Minimum facts to get started:

- Dendritic-pattern NixOS flake (`den` + `flake-parts`) for three hosts
  (`andromeda`, `miranda`, `horologium`), plus a local iii agent/worker stack.
- **Never hand-edit `flake.nix`** — it is generated. Edit `flake-file` declarations
  under `modules/`, then run `nix run .#write-flake`.
- `just` is the task runner (`just switch`, `just fmt`, `just ci`, …). CI is exactly
  `just ci` and requires a clean, committed tree.
- Validate with `nix fmt` and `just ci`; there is no test suite beyond flake
  evaluation.
- `secrets/` is SOPS-encrypted: never print secret values. If a change needs a new
  secret, name it without including its contents.
- Keep changes minimal and focused; feature config belongs in `modules/aspects/`,
  local packages in `packages/`.
