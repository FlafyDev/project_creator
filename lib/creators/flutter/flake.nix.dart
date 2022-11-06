const flakeNix = """
{
  description = "<<description>>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    dart-flutter = {
      url = "github:flafydev/dart-flutter-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, nixpkgs, dart-flutter }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              dart-flutter.overlays.default
              self.overlays.default
            ];
          };
        in
        {
          packages = {
            inherit (pkgs) <<projectName>>;
            default = pkgs.<<projectName>>;
          };
          devShell = pkgs.mkFlutterShell {
            linux = {
              enable = true;
            };
          };
        }) // {
      overlays.default = final: prev:
        let
          pkgs = import nixpkgs {
            inherit (prev) system;
            overlays = [ dart-flutter.overlays.default ];
          };
        in
        {
          <<projectName>> = pkgs.callPackage ./nix/package.nix { };
        };
    };
}

""";
