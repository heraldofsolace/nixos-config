{ inputs, ... }:
{
  # Oh My Pi (https://github.com/can1357/oh-my-pi) - terminal coding agent,
  # invoked as `omp`.
  flake-file.inputs.oh-my-pi = {
    url = "github:can1357/oh-my-pi";
    # Deliberately does NOT follow our nixpkgs: upstream's flake pins
    # nixos-unstable and resolves its bun2nix / crane / rust-overlay stack
    # against that pin, so overriding it is asking for a build that upstream
    # never tested. Cost is a second nixpkgs in flake.lock (eval-time only).
    #
    # Note that despite the nix-community.cachix.org substituter in upstream's
    # nixConfig, nothing is actually published there for x86_64-linux - HEAD
    # and v18.20.3/v18.21.0/v18.22.0 all 404 on their .narinfo, as does
    # cache.nixos.org. omp therefore builds locally (~45 min: the Rust core is
    # compiled with fat LTO at codegen-units=1), and will again on each bump.
  };

  blazar.ai._.omp.homeManager = {
    imports = [ inputs.oh-my-pi.homeManagerModules.default ];

    # `settings` is left unset on purpose. The upstream module copies declared
    # settings over ~/.omp/agent/config.yml on every activation, so anything
    # changed at runtime via `/settings` or onboarding would be reverted on the
    # next switch - omp keeps ownership of its own config instead.
    programs.omp.enable = true;
  };
}
