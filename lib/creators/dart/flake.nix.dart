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

  outputs = { self, nixpkgs, flake-utils, dart-flutter }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
              dart-flutter.overlays.default
            ];
          };
        in
        {
          packages = {
            inherit (pkgs) <<projectName>>;
            default = pkgs.<<projectName>>;
          };
          devShell = pkgs.mkShell {
            packages = with pkgs; [
              dart
              deps2nix
            ];
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
