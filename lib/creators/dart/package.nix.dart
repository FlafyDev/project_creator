const packageNix = """
{ lib
, buildDartApp
}:

buildDartApp rec {
  pname = "<<projectName>>";
  version = "1.0.0";

  src = ../.;

  meta = with lib; {
    description = "<<description>>";
    homepage = "https://github.com/<<repoFullname>>";
    maintainers = [ ];
    license = licenses.<<license>>;
    platforms = platforms.linux;
  };
}
""";
