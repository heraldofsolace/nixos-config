{
  den.default.nixos =
    {
      lib,
      pkgs,
      config,
      host,
      ...
    }:
    let
      # miranda doesn't pair with a phone or need LAN service discovery.
      isMiranda = host.name == "miranda";
    in
    {
      networking = {
        dhcpcd.wait = "background";
        dhcpcd.extraConfig = "noarp";
        useDHCP = lib.mkDefault true;
        wireless.iwd.enable = true;
        networkmanager.wifi.backend = "iwd";
        networkmanager.enable = true;
        firewall = {
          enable = true;

          # Open ports in the firewall.
          allowedTCPPorts = [
            5555
            22
          ]
          ++ lib.optional (!isMiranda) 5353;
          allowedUDPPorts = [ 9 ];
          #allowedUDPPortRanges = [
          # { from = 4000; to = 4007; }
          # { from = 8000; to = 8010; }
          #];

          # KDE-Connect's own module (programs.kdeconnect) already opens
          # 1714-1764 TCP+UDP itself when enabled below.
        };
      };
      programs.kdeconnect.enable = !isMiranda;

      services.avahi = lib.mkIf (!isMiranda) {
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
        authKeyFile = config.sops.secrets.tailscale-key.path;
        extraUpFlags = [
          "--ssh"
        ];

        # Use for containers where one cannot create tunnel networking TUN.
        # interfaceName = "userspace-networking";
      };

      # tailscaled-autoconnect is Type=notify and doesn't report ready
      # until `tailscale up` finishes a real network handshake with the
      # coordination server (measured ~7.7s on andromeda). Because it's
      # WantedBy=multi-user.target, systemd auto-adds Before=multi-user.target,
      # so the whole boot waits on that round-trip even though nothing here
      # orders After=tailscaled-autoconnect.service. It still starts and
      # connects in the background; it just no longer blocks boot.
      systemd.services.tailscaled-autoconnect.before = lib.mkForce [ "shutdown.target" ];

      networking = {
        nameservers = [
          "192.168.0.1"
          "100.100.100.100"
          "1.1.1.1"
          "1.0.0.1"
        ];
        search = [ "dorper-ghost.ts.net" ];
      };

      services.resolved = {
        enable = true;
        # settings.Resolve = {
        #   DNSSEC = "true";
        #   Domains = [ "~." ];
        #   DNSOverTLS = "true";
        #   FallbackDNS = [
        #     "1.1.1.1"
        #     "1.0.0.1"
        #   ];
        # };
      };
      services.ivpn.enable = true;
      environment.systemPackages = with pkgs; [
        openvpn
        wireguard-tools
        ivpn-ui
      ];
    };
}
