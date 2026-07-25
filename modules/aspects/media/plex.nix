_: {
  blazar.media._.plex = {
    nixos = _: {
      services.plex = {
        enable = true;
        openFirewall = true;
      };
      users.users.plex = {
        extraGroups = [
          "music"
        ];
      };
    };
  };
}
