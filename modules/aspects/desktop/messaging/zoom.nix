_: {
  blazar.desktop._.messaging._.zoom.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      zoom-us
    ];
  };
}
