{inputs, ...}: {
  flake-file.inputs.zen = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "latest";
  };

  blazar.zen.homeManager = {pkgs, ...}: {
    imports = [
      inputs.zen.homeModules.beta
    ];

    programs.zen-browser.enable = true;
    programs.zen-browser.profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
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
}
