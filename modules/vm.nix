# enables `nix run .#vm`. it is very useful to have a VM
# you can edit your config and launch the VM to test stuff
# instead of having to reboot each time.
{
  inputs,
  den,
  ...
}: {
  den.aspects.andromeda.includes = [
    (den._.tty-autologin "aniket")
    # eg.vm._.tui
  ];

  perSystem = {pkgs, ...}: let
    hosts = builtins.attrNames inputs.self.nixosConfigurations;
    vms =
      map (
        hostName: let
          vmName = "vm-${hostName}";
          host = inputs.self.nixosConfigurations.${hostName}.config;
        in {
          name = vmName;
          value = {
            meta.description = "Run aniket@${vmName} in a VM for testing before applying changes.";
            program = pkgs.writeShellApplication {
              name = vmName;
              text = ''
                ${host.system.build.vm}/bin/run-${hostName}-vm "$@"
              '';
            };
          };
        }
      )
      hosts;
  in {
    apps = builtins.listToAttrs vms;
  };
}
