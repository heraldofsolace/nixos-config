_: {
  blazar.astronomy.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      siril
      kstars
      stellarium
      blazar.sirilic
      indi-full
      phd2
    ];
  };
}
