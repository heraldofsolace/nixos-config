# comin: GitOps agent that polls a git remote and rebuilds the host when it moves.
# https://github.com/nlewo/comin - upstream URL confirmed against the GitHub API
# (`nix-community/comin` is not the repo, and comin is not in nixpkgs).
#
# Declared here, wired in this same file once the input is locked and the upstream
# option names can be read off the fetched source. Not included by any host: enabling
# it makes a machine rebuild itself unattended, which is the user's call.
{
  flake-file.inputs.comin = {
    url = "github:nlewo/comin";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
