#!/usr/bin/perl

use Mysql;

print "Content-type: text/html \n\n";

# MYSQL CONFIG VARIABLES
$host = "localhost";
$database = "git";
$tablename = "profile";
$user = "root";
$pw = "";
#"echo ls /home/git/repositories/base_rep.git/refs/tags";

# PERL MYSQL CONNECT()
$connect = Mysql->connect($host, $database, $user, $pw);

# SELECT DB
$connect->selectdb($database);


# DEFINE A MySQL QUERY
$myquery = "SELECT tags FROM $tablename ORDER BY TimeStamp DESC";

# EXECUTE THE QUERY FUNCTION
$execute = $connect->query($myquery);

# FETCHROW ARRAY

#while (@results = $execute->fetchrow()) {
@results = $execute->fetchrow(); 
	print "the latest tag in the table $tablename ==>  $results[0]\n\n";

#@tgs=`git log --pretty=format:%d --simplify-by-decoration --decorate | grep tag | sed -e 's_.*refs/tags/\([^,)]*\).*_\1_' | head -1`;
@tag_list = `git log --pretty=format:%d --simplify-by-decoration --decorate | grep tag |cut -d "(" -f2 |cut -d "," -f1|cut -d")" -f1 |cut -d "/" -f3`;

print "\nThe current tag fetched from remote repository is => $tag_list[0]";		#Current tag name
print "\n";

## List of all tags that are not present in the table
foreach $item(@tag_list) {
	if ("${item}" =~ "$results[0]") {
		last;
	}
	chomp $item;
	push(@newtag,${item});
}
print "\n\n";
print "@newtag";
print "\n\n";
		

if ($tag_list[0] eq $results[0])
 {print "The table $tablename is updated with the latest tags fetched";}
else { print "Please build with the latest tags => @newtag\n\n";}


$HOME = "/home/archbuild";     			 #This is for Unix path
$rep_name = "${HOME}\/base_rep";
$tagloc = "${rep_name}\/.git\/refs\/tags";
=pod
$tagloc = "C:\/GITREPOS\/MyRepos\/.git\/refs\/tags";         #This is for Windows path
=cut
print "$tagloc\n";
`ls $taglog`;

#Code to extract SHA Id of the current tag and the tag present in the release build table
open PFILE, "<$tagloc\/$results[0]";
open CFILE, "<$tagloc\/$tag_list[0]";
@plines = <PFILE>;
@clines = <CFILE>;
print  "SHA of current commit $tag_list[0] = @clines \n";
print  "SHA of parent commit $results[0] = @plines";
close PFILE;
close CFILE;

chomp $plines[0];
chomp $clines[0];
chomp $tag_list[0];
chomp $results[0];

`git format-patch --name-status $results[0]..$tag_list[0]`;
`cat *.patch > fulpat`;

open FILE, "<fulpat" or die $!;
my @lines = <FILE>;
print @lines;
close FILE;




open FILE, "+>patch" or die $!;
foreach (@lines) {
	if(($_ =~ /^A/)||($_ =~ /^M/)){
	print FILE substr("$_", 2);}
	#elsif($_ =~ /^From/) {	print substr("$_", 5);	print FILE substr("$_", 5);}
		
			}					#end foreach
			close FILE;

			`rm *.patch`;			# remove the patch files created

my $file = 'patch';              #remove duplicate file names
my %seen = ();
{
   local @ARGV = ($file);
   local $^I = '.bac';
   print "$^I \n\n";
   while(<>){
      $seen{$_}++;
      next if $seen{$_} > 1;
      print;
   }
}
print "finished processing file. \n";

print "Changing fulpat attributes";
`perl -p -i.bak -e 's/^D	/Delete		/g' '${rep_name}\/fulpat'`;
`perl -p -i.bak -e 's/^A/Added	/g' '${rep_name}\/fulpat'`;
`perl -p -i.bak -e 's/^M/Modified/g' '${rep_name}\/fulpat'`;


if ($plines[0] eq $clines[0])
 	{print "Equal SHA";}
else
	{print "Unequal SHA";
	`ant -f /home/archbuild/masterbld.xml`;	#Uncomment for unix
	#`ant -f C:/GITREPOS/masterbld.xml`;	#Uncomment for windows	
	print "$?";        #For STDOUT
	print "\n\n";

=pod
#This is another way to get the STDOUT
	@pidlist = <STDOUT>;
	 $proc_count = @pidlist;
	print "..............$proc_count........";
=cut

	if ($? eq 256) {print "Build f\n\n\n";}
	else {print "Build Successfully ; Can proceed with insert of tags to the tables!!! \n"; print "\n\n\n";}
	}

