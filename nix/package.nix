{
  lib,
  buildDartApp,
  makeWrapper,
  dart,
  flutter,
}:
buildDartApp rec {
  pname = "project-creator";
  version = "0.0.1";

  src = ../.;

  nativeBuildInputs = [makeWrapper];

  postFixup = ''
    wrapProgram $out/bin/project-creator --suffix PATH : ${lib.makeBinPath [dart flutter]} --set PCREATORASSETS ${../assets}
  '';

  meta = with lib; {
    description = "Quickly creator projects.";
    homepage = "https://github.com/FlafyDev/project-creator";
    maintainers = [];
    license = licenses.mit;
  };
}
