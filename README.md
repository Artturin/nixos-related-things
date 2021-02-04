# nixos-related-things

made a hound instance for searching the same repos

https://search.artturin.com


scripts for nixos and nix

doc-repos is for searching dotfile repositories

view-doc-file command which is installed with doc-repos is for viewing the path in your text editor

view-doc-dir command which is installed with doc-repos is for viewing the path in ranger

To use add this to your config

change revAr to the newest commit

```nix
nixpkgs.overlays =
  let
    revAr = "f8c23d744d4e7b7c9772ce6ca5e28ab5460f9277";
    urlAr = "https://github.com/Artturin/nixos-related-things/archive/${revAr}.tar.gz";
    arOverlay = (import (builtins.fetchTarball urlAr));
  in [
    arOverlay
  ];
```
and add `doc-repos` to your packages

then run `doc-repos --clone` to clone the repos to `~/code/documentation-dotfiles`


