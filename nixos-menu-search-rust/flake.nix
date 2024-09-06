{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    naersk = {
      url = "github:nmattia/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    octerm = {
      url = "github:sudormrfbin/octerm";
      flake = false;
    };
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      naersk,
      octerm,
      flake-compat,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {

        defaultApp = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };

        packages = utils.lib.flattenTree {
          default = naersk.lib.${system}.buildPackage {
            src = ./.;
            #copyLibs = true;
            nativeBuildInputs = with pkgs; [ makeWrapper ];
            buildInputs = with pkgs; [
              openssl
              pkg-config
            ];
            overrideMain = _: {
              postInstall = ''
                wrapProgram $out/bin/nixos-menu-search \
                  --prefix PATH : ${pkgs.lib.makeBinPath [ packages.octerm ]}
              '';
            };
          };

          octerm = naersk.lib.${system}.buildPackage {
            src = octerm;
            #copyLibs = true;
            buildInputs = with pkgs; [
              openssl
              pkg-config
            ];
          };
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            openssl
            pkg-config
            rust-analyzer-nightly
            packages.octerm
            lldb

          ];
          RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          shellHook = ''
            exec zsh
          '';
        };

      }
    );

}
