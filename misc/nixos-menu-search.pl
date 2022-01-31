#!/usr/bin/env nix-shell
#!nix-shell -i perl -p perl perlPackages.JSON
# vim:ft=perl
use strict;
use warnings;
use JSON;
use experimental 'switch';
use 5.034;
our $VERSION = 1;

#print("$searchstr");

#print("whole answer ", "@answer", "\n\n");
my $menucommand = 'wofi --show dmenu -W 400 -L 20 2>/dev/null';

sub getnotif {
    my @arg   = @_;
    my @first = `gh api notifications --jq '.[] | .url'`;
    chomp @first;
    my @value;
    my @htmlurls;
    if ("@arg" eq 'count') { push @value, scalar @first; }
    else {
        foreach ( @first ) {
            my $step1 = `gh api "$_" --jq '.subject.url'`; chomp $step1;
            my $step2 = `gh api "$step1" --jq '.html_url'`;
            push @htmlurls, $step2;
        };
        push @value, `echo "@htmlurls" | $menucommand`;
        if (! @value) { exit};
    }
    return("@value");
}

sub returncmd {
    my $choices   = join "\n", split q{ }, 'pkg opt iss pr notif';
    my @answer    = split q{ }, `echo -e "$choices" | $menucommand`;
    if (! @answer)  { exit };
    my $choice    = shift @answer;
    my $searchstr = join q{+}, @answer;
    my @cmd       = qw(xdg-open);
    given ($choice) {
        when (m/^pkg|package/sm)        { push @cmd, ("https://search.nixos.org/packages?query=$searchstr&channel=unstable") };
        when (m/^opt|option/sm)         { push @cmd, ("https://search.nixos.org/options?query=$searchstr&channel=unstable"); };
        when (m/^pr|pull/sm)            { push @cmd, ("https://github.com/NixOS/nixpkgs/pulls?q=is%3Apr+$searchstr"); };
        when (m/^iss|issue/sm)          { push @cmd, ("https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+$searchstr"); };
        when (m/^notif|notification/sm) { push @cmd, getnotif(); }
        default                         { exit 1; }
    }
    return("@cmd");
}

system returncmd() or exit 1;
