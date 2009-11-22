#!/opt/lampp/bin/perl -w
use strict;



use IO::File;
my $date = localtime(time); 

my $HOME = "/home/archbuild";
my $rep_name = "${HOME}\/base_rep";
my $return;
my $opti;

while (1) {
	system("clear");

	print "\n";
	print "\t\t############################################################\n";
	print "\t\t#                                                          #\n";
	print "\t\t#        GIT environment for Patch Creation                #\n";
	print "\t\t#                                                          #\n";
	print "\t\t############################################################\n";

	print "\n";
	print "\t\t\t    Please Select one of the following\n";
	print "\n";
	print "\t\t\t1.  Full Build \n";
	print "\t\t\t2.  Rolling Patch \n";
	print "\t\t\t3.  Single Defect Patch \n";
	print "\t\t\t4.  Multiple Defect Patch \n";
       	print "\t\t\tq.  Quit \n";
	print "\n";

	print "\t\t\t    Your Selection -> ";
	chomp (my $opt = <STDIN>);
	last if ($opt =~ /^q$/i);
	print "\t\t ----------------------------------------------------------------------\n\n";

	if ($opt eq 1){
		$return = &fullBuild();
	}
	elsif ($opt eq 2){
		$return = &rollPatch();
	}
	elsif ($opt eq 3) {
		printf "\t\tThe system time is \t %-s\n", $date; 
		system("tput smso");
		print "Press enter to return main menu.";
		system("tput rmso");
                my $x = <STDIN>;

	} 
	elsif ($opt eq 'q'){
		print "\n Try Again \n";
		system("clear");
	}
	else {
		system("tput smso");
                print "incorrect value entered. press enter to return main menu.";
		system("tput rmso");
                my $x = <STDIN>;
              }
}

sub fullBuild {
        #system("clear");
	print "Starting Full Build ..........\n";
	print "Changing directory to the path  $rep_name \n";
	chdir "$rep_name";
BRN:	print "Enter the branch you want to checkout : ";
	my $branch = <STDIN>;
	chomp $branch;
	if ($branch eq ''){
	goto ERR;}
	print `git checkout $branch`;
	print "\n";
	if (($? == '32768') || ($? == '256'))
	{
ERR:		system("tput smso");
		print STDERR "\n\t\tPlease enter a proper branch name ... \n\n"; 
		system("tput rmso");
		goto BRN;
	}
	
	# Code for auto pull from Staging server
AUTPUL:	print "Do you want to execute auto-pull from Staging server (y/n) : ";
	chomp ($opti = <STDIN>);
	if ($opti eq 'y') { 		
	`git pull origin $branch`; }
	elsif ($opti eq 'n'){
	print "Continue building with existing commit\n\n"; sleep 1;}
	else { print "\n\n\t\tInvalid Option !\n\n"; goto AUTPUL; }
	my $stat=`git status`;
	print $stat;
       # print "Please enter SHA Identification or Tag Name: ";
       # my $shID = <STDIN>;
       # chomp $shID;
       #	$return = &autoTag();
	print "Ant script runs for full build\n\n";
	print "Build Over .....\n\n";
	`git tag -l`;
	`ls -l`;
		system("tput smso");
	print "\n\nPress Enter to go back to main menu .....  ";
		system("tput rmso");
        my $x = <STDIN>;           ## Use this to exit the flow and come back to the main menu
}
sub rollPatch {
	print "Starting to build Rolling Patch ....\n\n";
	print "Please enter the start date (yyyy-mm-dd): ";
        my $sdt = <STDIN>;
	print "Please enter the end date (yyyy-mm-dd): ";
	my $edt = <STDIN>;
	chomp $sdt;
	chomp $edt;
	my $l1 = "master\@{$sdt}";
	my $l2 = "master\@{$edt}";
	chomp $l1; chomp $l2;
	print "$l1..$l2";
	`git log --name-status -p master\@{$sdt}..master\@{$edt} > fulpat`;	

	open FILE, "<fulpat" or die $!;
	my @lines = <FILE>;
	print @lines;
	close FILE;

	open FILE, "+>patch" or die $!;
	foreach (@lines) {
        if(($_ =~ /^A\t/)||($_ =~ /^M\t/)){
        print FILE substr("$_", 2);}
        elsif($_ =~ /^From/) { print substr("$_", 5);  print FILE substr("$_", 5);}
      
        }                                       #end foreach
        close FILE;


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
	`perl -p -i.bak -e 's/^D\t/Delete\t\t/g' '${rep_name}\/fulpat'`;
	`perl -p -i.bak -e 's/^A\t/Added\t\t/g' '${rep_name}\/fulpat'`;
	`perl -p -i.bak -e 's/^M\t/Modified\t/g' '${rep_name}\/fulpat'`;


	`ant -f /home/archbuild/masterbld.xml`;
	print "\n\t\t Build Complete ..... \n";
	`rm *.bak`;
	`rm patch.bac`;

	print "\n\nPress Enter to go back to main menu";
        my $x = <STDIN>;           ## Use this to exit the flow and come back to the main menu

}


=pod
	else ($op eq 4){
	#	&database_disconnect();
	#		system("clear");
	#		exit(0);
		print "test";
	} 
	else ($op eq "Q") {
	#	&database_disconnect();
		system("clear");
		exit(0);
	}
=cut

sub autoTag {
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
	my $headloc="\/home\/archbuild\/base_rep\/.git\/refs\/heads";
  	print "$headloc\n\n\n";

#open(PFILE, "<", $tagloc\/master) or die "open master failed:$!\n";
  	open PFILE, "<$headloc\/master" or die "open master failed:$!\n";
  	my @plines = <PFILE>;
  	print @plines;
  	close(PFILE);
  	`git tag $abc.$d.$e`;
}
