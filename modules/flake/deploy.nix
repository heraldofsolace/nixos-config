{
  self,
  lib',
  ...
}:
{
  flake-file.inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
  };

  flake = {
    deploy = lib'.mkDeploy {
      inherit self;
    };
  };
}
