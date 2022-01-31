#!/usr/bin/env bash
set -e
# Usage: prefix the search term with either pkg, opt, pr, iss

# Wofi is rofi for wayland
MENUCOMMAND="wofi --show dmenu -W 250 -L 10"

CHOICE=$(echo -e "pkg\nopt\niss\npr" | $MENUCOMMAND)
CHOICE1=$(echo $CHOICE | tr ' ' '+' | cut -d "+" -f 2-10)
CHOICE2=$(echo $CHOICE | cut -d " " -f 2-10)

if [[ -z $CHOICE ]]; then
    exit
elif [[ $CHOICE =~ ^pkg* ]]; then
    xdg-open "https://search.nixos.org/packages?query=$CHOICE2&channel=unstable"
elif [[ $CHOICE =~ ^opt* ]]; then
    xdg-open "https://search.nixos.org/options?query=$CHOICE2&channel=unstable"
elif [[ $CHOICE =~ ^pr* ]]; then
    xdg-open "https://github.com/NixOS/nixpkgs/pulls?q=is%3Apr+$CHOICE1"
elif [[ $CHOICE =~ ^iss* ]]; then
    xdg-open "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+$CHOICE1"
fi
