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
            # --no-wait: kanata's default "press enter to exit" prompt on
            # exit is meaningless under systemd (no attached terminal), so
            # skip it and exit cleanly instead.
            # --emergency-exit-code 1: the built-in emergency-exit hotkey
            # (LCtrl+Space+Escape) exits 0 by default, which Restart =
            # "on-failure" wouldn't treat as worth restarting.
            ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${configFile} --no-wait --emergency-exit-code 1";
            Restart = "on-failure";
            RestartSec = 2;
            Environment = [
              "PATH=${
                lib.makeBinPath [
                  pkgs.coreutils
                  pkgs.kanata
                ]
              }"
            ];
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
    };
}
