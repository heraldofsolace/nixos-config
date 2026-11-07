{ inputs, ... }: {
  flake-file.inputs = {
    prismnix = {
      url = "github:qacow37/prismnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  blazar.games.homeManager = { pkgs, ... }: {
    imports = [
      inputs.prismnix.homeModules.prismnix
    ];
    programs.prismnix = {
      enable = true;
      instances = {
        "My Instance" = {
          minecraft = {
            enable = true;

            version = "1.21.11";
            mod-loader = {
              enable = true;
              loader = "fabric";
            };
            shader-loader = {
              enable = true;
              loader = "iris";
              version = "fabric-1.21.11";
            };

            mods = {
              fabric-api = {
                enable = true;
              };
              sound-controller = {
                enable = true;
                settings = {
                  sounds = {
                    "minecraft:entity.enderman.ambient" = 0.3;
                    "minecraft:entity.enderman.death" = 0.3;
                  };
                };
              };
            };

            # prismnix's own `packages.<system>` are instantiated from
            # `nixpkgs.legacyPackages`, which carries no unfree allowance, so
            # forcing these Modrinth packages aborts evaluation (`sodium` is
            # Polyform Shield). Its overlay builds the same expressions from the
            # pkgs it is applied to — this home-manager's pkgs, whose NixOS-scope
            # config already allows unfree. KAN-2.
            packages = with (pkgs.extend inputs.prismnix.overlays.default).prismnix; [
              modmenu
              midnightcontrols
              (sodium.override {
                version = "pkg-mc1.21.11-0.8.7-fabric";
              })

              # Resourcepack
              default-dark-mode
              # complementary-reimagined
            ];

            allowed-symlinks = {
              enable = true;
            };
          };
        };
      };
    };
    home.packages = with pkgs; [
      # (inputs.nur.repos.username.package)

      protonup-qt
      protonup-ng
      protonplus
      wineWow64Packages.unstableFull
      # wineWow64Packages.waylandFull
      winetricks

      heroic
      bottles

      umu-launcher
      # umu-launcher-unwrapped
      nero-umu

      # (rimsort.overrideAttrs (prevAttrs: {
      #   version = "latest";
      #   src = inputs.rimsort;
      #   # pkgs.fetchFromGitHub {
      #   #   owner = "RimSort";
      #   #   repo = "RimSort";
      #   #   rev = "refs/heads/main";
      #   #   hash = "sha256-Mh0RkLWuFkqsb9cxc1TGhtgdY2VeulCOaa4aZxRxKJU=";
      #   # };
      # }))
      # inputs'.nixpkgs-local.legacyPackages.rimsort
    ];
  };

  blazar.games.nixos =
    { pkgs, ... }:
    let
      # Same nixpkgs snapshot hardware.graphics.package (hyprland.nix) pulls
      # mesa from. Steam's own client (the outer launcher UI, not the
      # pressure-vessel-sandboxed games) is built against the main nixpkgs
      # pin's mesa/libGL/libvulkan-loader - mismatched against the unstable
      # mesa actually served at /run/opengl-driver. Surfaced as
      # "glXChooseVisual failed" / "CVulkanTopology: failed to get physical
      # device count" followed by a fatal assert, crashing the client
      # outright (confirmed via `journalctl --since today | grep steam`).
      # Same fix as librewolf/firefox: pull the whole package from the same
      # unstable snapshot instead of patching individual libs.
      pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      programs.steam = {
        enable = true;
        package = pkgs-unstable.steam;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
        gamescopeSession.enable = true;
      };

      programs.gamescope = {
        enable = true;
        capSysNice = false;
      };
      environment.systemPackages = [
        pkgs.mangohud
        pkgs.steamcmd
        pkgs.lact
      ];
      programs.gamemode.enable = true;
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          vulkan-loader
          vulkan-validation-layers
          vulkan-extension-layer
        ];
      };

      systemd.packages = with pkgs; [ lact ];
      systemd.services.lactd.wantedBy = [ "multi-user.target" ];
    };

  # GPU overdrive/overclocking is only safe on hosts with a proper
  # desktop-class GPU and cooling (andromeda, miranda) - not horologium, a
  # laptop. A global default (independent of whether the games aspect
  # itself is included) so it still applies on miranda, which doesn't.
  den.default.nixos =
    { host, lib, ... }:
    {
      hardware.amdgpu.overdrive.enable = lib.mkIf (builtins.elem host.name [
        "andromeda"
        "miranda"
      ]) true;
    };
}
