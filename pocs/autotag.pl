#!/usr/bin/perl -w

#use strict;

my $vpfile = "version.properties";

open(INF, "<", $vpfile) or die "open $vpfile failed:$!\n";
my $version = <INF>;
close(INF);

my ($abc, $d, $e) = $version =~ /(\d+\.\d+\.\d+)\.(\d+)\.(\d+)/;

$e++;

print "$abc.$d.$e\n";

open(OUTF, ">", $vpfile) or die "open $vpfile failed:$!\n";
print OUTF "ver=$abc.$d.$e\n";
close(OUTF);

#  Paths

$headloc="\/home\/archbuild\/base_rep\/.git\/refs\/heads";
print "$headloc\n\n\n";


#open(PFILE, "<", $tagloc\/master) or die "open master failed:$!\n";
open PFILE, "<$headloc\/master" or die "open master failed:$!\n";
my @plines = <PFILE>;
print @plines; 
close(PFILE);

`git tag $abc.$d.$e`;
