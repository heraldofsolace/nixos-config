{stdenvNoCC}:
stdenvNoCC.mkDerivation {
  pname = "hornet-cursor-theme";
  version = "1.3";

  src = ./.;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    mv xcursor $out/share/icons/Hornet

    runHook postInstall
  '';
}
