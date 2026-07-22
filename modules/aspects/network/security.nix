{
  den.default.nixos = { lib, pkgs, ... }: {
    networking = {
      dhcpcd.wait = "background";
      dhcpcd.extraConfig = "noarp";
      useDHCP = lib.mkDefault true;
      wireless.iwd.enable = true;
      networkmanager.wifi.backend = "iwd";
      networkmanager.enable = true;
      firewall = rec {
        enable = true;

        # Open ports in the firewall.
        allowedTCPPorts = [
          5555
          27183
          22
          5353
        ];
        #allowedUDPPortRanges = [
        # { from = 4000; to = 4007; }
        # { from = 8000; to = 8010; }
        #];

        # Allow KDE-Connect through system firewall.
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };
    };
    programs.kdeconnect.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    systemd.services.NetworkManager-wait-online.enable = false;
    services.tailscale = {
      enable = true;
      authKeyFile = "/run/secrets/tailscale-key";
      extraUpFlags = [
        "--ssh"
      ];

      # Use for containers where one cannot create tunnel networking TUN.
      # interfaceName = "userspace-networking";
    };

    networking = {
      nameservers = [
        "100.100.100.100"
        "8.8.8.8"
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "true";
        Domains = [ "~." ];
        DNSOverTLS = "true";
        FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
    };
    services.ivpn.enable = true;
    environment.systemPackages = with pkgs; [
      openvpn
      wireguard-tools
      ivpn
    ];
  };
}
