# comin: GitOps agent that polls a git remote and rebuilds the host when it moves.
#
# Declared here, wired in the comin aspect under modules/aspects. Not included by
# any host: enabling it makes a machine rebuild itself unattended, which is the
# user's call, not a ticket's.
{
  flake-file.inputs.comin = {
    url = "github:nix-community/comin";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
