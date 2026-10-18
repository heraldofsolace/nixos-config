# The CI signal, as a module -- not imported from here.
#
# `just ci` copies this file into a throwaway checkout as `modules/ci-runtime.nix` and runs
# `nix flake check` there, so `_module.args.CI` is set for exactly that evaluation and the
# tracked tree is never written to. `modules/` is auto-imported by import-tree, which is why
# the copy lands there.
#
# It lives outside `modules/` on purpose: a checked-in `modules/ci-runtime.nix` would be
# imported by every evaluation and silently flag local builds as CI. The old workflow instead
# generated that file into the checkout with a heredoc -- but a file written into a git
# checkout is untracked, and flake evaluation never sees untracked files, so the signal never
# actually arrived. A tracked template copied into a scratch tree is seen, and leaves no trace.
#
# Consumers test for the attribute's presence rather than its value
# (`config ? _module.args.CI`): `modules/aspects/defaults.nix` and `modules/ci-no-boot.nix`.
{
  _module.args.CI = true;
}
