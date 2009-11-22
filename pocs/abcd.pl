#!/usr/bin/perl
use warnings;

sub trim($);
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}


my $returncode = `git status`;
print $returncode;


`git format-patch --name-status origin`;


open FILE, "<*.patch" or die $!;
my @lines = <FILE>;
#print @lines;
close FILE;

open FILE, ">patch" or die $!;
foreach (@lines) {
	if(($_ =~ /^A/)||($_ =~ /^M/)){
	print substr("$_", 2);
	print FILE substr("$_", 2);}
	elsif($_ =~ /^From/) {
	print substr("$_", 5);
	print FILE substr("$_", 5);}
	

}

close FILE;


