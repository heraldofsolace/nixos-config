{
  blazar.utils._.vivoOfficeKit.homeManager =
    { self', ... }:
    {
      home.packages = [ self'.packages.vivo-office-kit ];
    };
}
