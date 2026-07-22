{
  blazar.utils._.samba = {
    nixos =
      _:
      {
        services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
        networking.firewall.allowedTCPPorts = [
          5357 # wsdd
        ];
        networking.firewall.allowedUDPPorts = [
          3702 # wsdd
        ];
        networking.firewall.extraCommands = "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";
        services.samba = {
          enable = true;
          openFirewall = true;
          settings = {
            global = {
              "workgroup" = "WORKGROUP";
              "server string" = "smbnix";
              "netbios name" = "smbnix";
              "security" = "user";
              #"use sendfile" = "yes";
              #"max protocol" = "smb2";
              # note: localhost is the ipv6 localhost ::1
              "hosts allow" = "192.168.0. 127.0.0.1 localhost";
              "hosts deny" = "0.0.0.0/0";
              "guest account" = "nobody";
              "map to guest" = "bad user";
            };
            "myhome" = {
              "path" = "/home/aniket";
              "browseable" = "yes";
              "read only" = "yes";
              "guest ok" = "no";
              "force user" = "aniket";
            };
            "tmp" = {
              "path" = "/tmp";
              "browseable" = "yes";
              "read only" = "yes";
              "guest ok" = "no";
              "force user" = "aniket";
            };
          };
        };
        networking.firewall.allowPing = true;
      };
  };
}
