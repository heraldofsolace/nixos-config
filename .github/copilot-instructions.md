<!--
Short, actionable guidance for AI coding agents working on this repo.
Keep this file ~20-50 lines and reference concrete files/commands.
-->

# Copilot / AI agent instructions — Aniket's NixOS config

This repo is a Nix flake-based personal NixOS configuration (Dendritic/den). Below are the essential facts and quick commands an AI coding agent needs to be productive.

- **Big picture**: `flake.nix` (auto-generated) wires the repo using `flake-parts` and `import-tree` to build outputs from `modules/`. The repository composes *aspects* (reusable feature sets) under `modules/aspects/` and host-specific declarations under `hosts/` (e.g. `hosts/andromeda/system.nix`).

- **Key directories**:

  - `modules/` — main composition tree used by the flake.
  - `modules/aspects/` — reusable features (look for `*.nix` files and `_files` conventions).
  - `hosts/` — per-host system definitions (`andromeda/` shown).
  - `packages/` — local package overlays and patches.
  - `devshells/` — predefined developer environments (`nix develop` targets).
  - `secrets/` — sensitive YAML (e.g. `keys.yaml`, `user-passwords.yaml`) — **do not** print secrets in outputs.

- **Conventions & patterns to follow**:

  - Many aspect directories use `_files`, `_defaults`, or leading underscores for internal templates — prefer editing public `default.nix` entrypoints.
  - `flake.nix` contains a comment: use `nix run .#write-flake` to regenerate it. Avoid hand-editing generated sections.
  - This repo relies on multiple flake inputs (see `flake.nix` inputs block). When changing inputs, run `nix flake update` and validate builds.

- **Useful commands (examples)**:

  - Enter a development shell: `nix develop` or `nix develop .#devshells.default`
  - Regenerate the flake file: `nix run .#write-flake` (see top of `flake.nix`).
  - Quick validation: `nix flake check` and `nix build` (e.g. `nix build` or `nix build .#packages`).
  - Deploy a host (flake-style): `sudo nixos-rebuild switch --flake .#andromeda` (adjust host name to the `nixosConfigurations` key in flake outputs).

- **Code & review guidance**:

  - Make minimal, focused changes. Keep patches in `packages/` near the files they modify.
  - Reference `modules/aspects/*` for where to add or modify features (e.g. `modules/aspects/security/op.nix`).
  - Avoid exposing `secrets/` content. If a change requires secrets, describe the required secret names but do not include their values.

- **Testing & CI hints**:

  - There is a `tests.nix` and numerous flake inputs; use `nix flake check` and `nix build` to surface issues.
  - For changes touching packages, run the corresponding `nix build` target in `packages/` or `nix build .#<package>` where available.

If anything here is unclear or you need additional examples (specific host deploy flows, devshell targets, or how `aspects` are wired), ask for the exact file or host to inspect and I'll add targeted guidance.
