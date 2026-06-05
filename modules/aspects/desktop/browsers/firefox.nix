_: {
  blazar.firefox.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      firefox
      ungoogled-chromium
    ];

    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;
      nativeMessagingHosts = with pkgs; [
        tridactyl-native
      ];

      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        settings = {"browser.startup.homepage" = "https://google.com";};
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
          hover-zoom-plus
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
