_: {
  blazar.keyboard.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = with pkgs; [
        wally-cli
        via
        vial
        bazecor
        kanata
      ];

      systemd.user.services.kanata =
        let
          configFile = pkgs.writeText "kanata.cfg" (builtins.readFile ./_files/kanata.kbd);
        in
        {
          Unit = {
            Description = "Kanata keyboard remapper";
            Documentation = "https://github.com/jtroo/kanata";
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${configFile}";
            Restart = "no";
            Environment = [
              "PATH=${
                lib.makeBinPath [
                  pkgs.coreutils
                  pkgs.kanata
                ]
              }"
              "DISPLAY=:0"
            ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
    };
}
