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
      # Declared here too (not just jellyfin.nix) so this aspect doesn't
      # depend on jellyfin.nix also being active to actually create the
      # group extraGroups above references.
      users.groups.music = { };
    };
  };
}
