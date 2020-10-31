# nixos-related-things
scripts for nixos and nix


To use add this to your config

```nix
  nixpkgs.overlays =
  let
    revAr = "f8c23d744d4e7b7c9772ce6ca5e28ab5460f9277";
    urlMy = "https://github.com/Artturin/nixos-related-things/archive/${revAr}.tar.gz";
    arOverlay = (import (builtins.fetchTarball urlMy));
  in [
    arOverlay
  ];
```


