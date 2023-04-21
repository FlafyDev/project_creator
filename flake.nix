{
  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    # dart-flutter = {
    #   url = "github:flafydev/dart-flutter-nix";
    #   # url = "path:/mnt/general/repos/flafydev/dart-flutter-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    dart-flutter,
  }:
    flake-utils.lib.eachDefaultSystem
    (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          dart-flutter.overlays.default
        ];
      };
    in {
      packages = {
        inherit (pkgs) project-creator;
        default = pkgs.project-creator;
      };
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          dart
          pubspec-nix
        ];
      };
    })
    // {
      overlays.default = _final: prev: let
        pkgs = import nixpkgs {
          inherit (prev) system;
          overlays = [dart-flutter.overlays.default];
        };
      in {
        project-creator = pkgs.callPackage ./nix/package.nix {};
      };
    };
}
