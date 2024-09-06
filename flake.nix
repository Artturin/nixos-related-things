{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: {

    overlays.default = (self: super: rec {
      doc-repos = super.callPackage ./doc-repos { };
    });

  };
}
