{ inputs, ... }:
{
  blazar.firefox.homeManager =
    {
      pkgs,
      config,
      ...
    }:
    let
      # librewolf links against the same *stable* mesa/libva as every other
      # app hitting this today (cage, wezterm-gui, lian-li-linux, polymath):
      # hardware.graphics.package overrides the runtime driver
      # (/run/opengl-driver) with mesa from the unstable snapshot, and the
      # two aren't ABI-compatible. Here it surfaces as a VA-API version
      # mismatch ("has no function __vaDriverInit_1_0"), silently falling
      # back to full software video decode instead of erroring loudly.
      pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      # This is the actually-used daily browser (the "firefox" launcher) -
      # same unstable-sourced fix as librewolf below, for the same reason.
      home.packages = [
        pkgs-unstable.firefox
        pkgs.ungoogled-chromium
      ];
      stylix.targets.firefox.profileNames = [ "default" ];
      programs.firefox = {
        enable = true;
        package = pkgs-unstable.librewolf;
        nativeMessagingHosts = with pkgs; [
          tridactyl-native
        ];

        configPath = "${config.xdg.configHome}/mozilla/firefox";

        profiles.default = {
          id = 0;
          name = "Default";
          isDefault = true;
          settings = {
            "browser.startup.homepage" = "https://google.com";
          };
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            addy_io
            buster-captcha-solver
            consent-o-matic
            darkreader
            decentraleyes
            enhanced-github
            forget_me_not
            grammarly
            multi-account-containers
            onepassword-password-manager
            peertubeify
            plasma-integration
            sourcegraph
            sponsorblock
            ublock-origin
            umatrix
            # enhancer-for-youtube
            firenvim
            furiganaize
            gesturefy
            greasemonkey
            # hover-zoom-plus
            image-search-options
            js-search-extension
            link-gopher
            mullvad
            octolinker
            promnesia
            return-youtube-dislikes
            stylus
            to-deepl
            video-downloadhelper
            youtube-nonstop
            private-relay
            pronoundb
          ];
        };
      };
    };
}
