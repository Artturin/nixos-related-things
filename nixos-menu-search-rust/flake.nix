{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    naersk = {
      url = "github:nmattia/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    octerm = {
      url = "github:sudormrfbin/octerm";
      flake = false;
    };
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk, fenix, octerm }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ fenix.overlay ]; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      rec {

        defaultPackage = (naersk.lib.${system}.override {
          inherit (fenix.packages.${system}.minimal) cargo rustc;
        }).buildPackage {
          src = ./.;
          #copyLibs = true;
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          buildInputs = with pkgs; [ openssl pkgconfig ];
          overrideMain = _: {
            postInstall = ''
              wrapProgram $out/bin/nixos-menu-search \
                --prefix PATH : ${pkgs.lib.makeBinPath [ packages.octerm ]}
            '';
          };
        };

        defaultApp = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };

        packages = utils.lib.flattenTree {
          octerm = (naersk.lib.${system}.override {
            inherit (fenix.packages.${system}.minimal) cargo rustc;
          }).buildPackage {
            src = octerm;
            #copyLibs = true;
            buildInputs = with pkgs; [ openssl pkgconfig ];
          };
        };


        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            openssl
            pkgconfig
            (fenix.packages.${system}.latest.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
            ])
            rust-analyzer-nightly
            packages.octerm
            lldb

          ];
          #RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          RUST_SRC_PATH = "${fenix.packages.${system}.latest.rust-src}/bin/rust-lib/src";
          shellHook = ''
            exec zsh
          '';
        };

      });

}
