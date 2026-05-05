{lib, ...}: {
  blazar.astronomy.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: {
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
