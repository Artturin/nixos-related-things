{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-menu-search = {
      url = "path:nixos-menu-search-rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {

    overlays.default = (self: super: rec {
      doc-repos = super.callPackage ./doc-repos { };
      nixos-menu-search = inputs.nixos-menu-search.packages.${super.stdenv.hostPlatform.system}.default;
    });

  };
}
