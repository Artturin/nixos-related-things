{ stdenv, writeScriptBin, makeWrapper, lib, bash, git, ripgrep, findutils, curl, less, bat, git-repo-updater, coreutils }:

let
  view-doc-file = (writeScriptBin "view-doc-file" ''
    #!/usr/bin/env bash
    $EDITOR "$HOME/code/documentation-dotfiles/$@"
  '');

  view-doc-dir = (writeScriptBin "view-doc-dir" ''
    #!/usr/bin/env bash
    if [ -f "$HOME/code/documentation-dotfiles/$@" ]; then
      cd "$HOME/code/documentation-dotfiles/$(${coreutils}/bin/dirname $@)"
    else
      cd "$HOME/code/documentation-dotfiles/$@"
    fi
  '');

in

stdenv.mkDerivation rec {
  pname = "doc-repos";
  version = "0.1";

  src = ./.;

  buildInputs = [ makeWrapper ];
  runtimeDeps = [ git ripgrep findutils curl less bat git-repo-updater ];

  installPhase = ''
    mkdir -p $out/bin
    cp * $out/bin
    cp ${view-doc-dir}/bin/view-doc-dir $out/bin
    cp ${view-doc-file}/bin/view-doc-file $out/bin
    wrapProgram $out/bin/doc-repos \
      --prefix PATH : "${lib.makeBinPath runtimeDeps}"
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/Artturin/nixos-related-things";
    description = "a script for searching dotfile repos";
    platforms = platforms.linux;
    maintainers = with maintainers; [ artturin ];
  };
}
