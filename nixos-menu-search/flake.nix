{
  description = "Python application managed with poetry2nix";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ poetry2nix.overlay
          (self: super: {
            mypy = super.python310Packages.toPythonApplication (super.python310Packages.mypy.overridePythonAttrs(old: rec {
              version = "unstable-2022-01-19";
              src = super.fetchFromGitHub {
                owner = "python";
                repo = "mypy";
                rev = "bb4b5346dd5d1a6f8e1642024bb04d5250118b50";
                sha256 = "sha256-79+HB7mZZleaE+aZ858HrRY2+om3KgrgB86F+V2U6J4=";
              };
            }));
          })
          ];
        };

        python = pkgs.python310;
        projectDir = ./.;
        overrides = pkgs.poetry2nix.overrides.withDefaults (self: super: {
          # Python dependency overrides go here
        });

        packageName = "nixos-menu-search";
      in
      {

        packages."${packageName}-poetry" = pkgs.poetry2nix.mkPoetryApplication {
          inherit python projectDir overrides;
          preBuild = ''
          '';
          # Non-Python runtime dependencies go here
          buildInputs = with pkgs; [ ];
          propagatedBuildInputs = with pkgs; [ ];
          checkInputs = with pkgs; [ mypy ];

          checkPhase = ''
            export MYPYPATH=$PWD/src
            mypy --strict src/nixos_menu_search
            #mypy --strict tests
            #pytest -sv
          '';
        };
        packages.${packageName} = python.pkgs.buildPythonApplication rec {
          pname = packageName;
          version = "0.1.0";
          format = "pyproject";
          nativeBuildInputs = with python.pkgs; [ poetry-core ];
          propagatedBuildInputs = with python.pkgs; [ PyGithub icecream ];
          src = ./.;
          checkInputs = with pkgs; [ mypy ];
          checkPhase = ''
            export MYPYPATH=$PWD/src
            mypy --strict src/nixos_menu_search
            #mypy --strict tests
            #pytest -sv
          '';
        };


        defaultPackage = self.packages.${system}.${packageName};

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.pyright
            pkgs.mypy
            (pkgs.poetry.override { python = python; })
            (pkgs.poetry2nix.mkPoetryEnv {
              inherit python projectDir overrides;
              editablePackageSources = {
                packageName = ./src;
              };
              extraPackages = (ps: with ps; [
              ]);
            })
          ] ++ (with python.pkgs; [
            black
            pylint
          ]);
          shellHook = ''
            export MYPYPATH=$PWD/src
            exec zsh
          '';
        };

      });
}
