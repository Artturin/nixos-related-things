shows a menu with the option to search nixos package, options, issues, pull requests, and show your github notifications


installation

```nix
environment.systemPackages = let
  nixos-menu-search = import "${pkgs.fetchFromGitHub {
      owner = "artturin";
      repo = "nixos-related-things";
      rev = "80f5f2ae0ccde9f5d690e0660510cc8beb5c5ab8";
      sha256 = "sha256-qLym/iWUOoQsURPZPISuYqZ50DRpfT5+R7y+PScrX64=";
  }}/nixos-menu-search";
in with pkgs; [
  nixos-menu-search
]
```
