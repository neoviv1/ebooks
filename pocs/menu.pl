#!/opt/lampp/bin/perl -w

use warnings;

my $date = localtime(time); 

$HOME = "/home/archbuild"; 		#for payments; it maybe /home/paybld

$REP = "ARCH";			# for payments; it maybe PAYMENTS 

$rep_name = "${HOME}\/${REP}";


sub remove_duplicates(\@)
{
    my $ar = shift;
    my %seen;
    for ( my $i = 0; $i <= $#{$ar} ; )
    {
        splice @$ar, --$i, 1
            if $seen{$ar->[$i++]}++;
    }
}


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
	print "\t\t\t2.  Copy from wip to StableJars and Auto-Tag \n";
	print "\t\t\t3.  Date Wise Patch \n";
	print "\t\t\t4.  Testing the menu \n";
	print "\t\t\t5.  Defect Patch \n";
	print "\t\t\t6.  testing auto \n";
      	print "\t\t\tq.  Quit \n";
	print "\n";

	print "\t\t\t    Your Selection -> ";
	chomp ($opt = <STDIN>);
	last if ($opt =~ /^q$/i);
	print "\t\t ----------------------------------------------------------------------\n\n";

	if ($opt eq 1){
		$return = &fullBuild();
	}
	elsif ($opt eq 2){
		$return = &copy();
	}

	elsif ($opt eq 3){
		$return = &rollPatch();
	}
	elsif ($opt eq 4) {
		printf "\t\tThe system time is \t %-s\n", $date; 
		system("tput smso");
		print "Press enter to return main menu.";
		system("tput rmso");
                my $x = <STDIN>;
	} 
	elsif ($opt eq 5) {
		$return = &shaDiff();

	} 

	elsif ($opt eq 6) {
		$return = &autoTagging();

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
	print "\n\n\n\ ****************\n\n\n";
	my $aa = `ls -l`;
	print $aa;
	print "\n\n\n\ ----------------****************\n\n\n";
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
	$stat=`git status`;
	print $stat;
       # print "Please enter SHA Identification or Tag Name: ";
       # my $shID = <STDIN>;
       # chomp $shID;
       #	$return = &autoTag();
	chdir "$HOME";
	print "Ant script runs for full build\n\n";

	`ant -f archbuild.xml`;
	print "Build Over .....\n\n";
#	`git tag -l`;
#	`ls -l`;
		system("tput smso");
	print "\n\nPress Enter to go back to main menu .....  ";
		system("tput rmso");
        my $x = <STDIN>;           ## Use this to exit the flow and come back to the main menu
}

sub copy {
	`cp $HOME/wip/*.jar /home/archbuild/ARCH/StableJars/.`;
	my @excl = ('ARCH.jar','AN.jar','RP.jar');
	foreach (@excl) 
		{
			print $_;
			`mv $rep_name/StableJars/$_ $rep_name/StableJars/bancs-libs/$_`;
		}

	
	print "\n\ntesting copy   ...";
	chdir $rep_name;
	my $brn = &branchName();
	print "\n\n\n This is my current branch name   $brn .........\n\n\n\n";
	

	my $date_tst = `date`;
	print "\n\n $date_tst..............";	

	`git add .`;
	`git commit -a -m "Stable jars => $brn...$date_tst"`;
    
	
	system("tput smso");
	print "\n\nPress Enter to go back to main menu .....  ";
	system("tput rmso");
       my $x = <STDIN>;           ## Use this to exit the flow and come back to the main menu

}

sub branchName {
	my $brname = `git log --pretty=format:%d --simplify-by-decoration --decorate| head -1|cut -d"," -f2 | cut -d")" -f1 | cut -d"(" -f2`;
	chomp $brname;
	return $brname;
	
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
	my @mod_jar;					#To store all the modified jars during patch creation
	my @lines = <FILE>;				#Stores each line from file fulpat in this array
	#print @lines;
	close FILE;

	open FILE, "+>patch" or die $!;
	foreach (@lines) {
        if(($_ =~ /^A\t/)||($_ =~ /^M\t/)){
        print FILE substr("$_", 2);}
#        print "substr("$_", 2)";
        elsif($_ =~ /^From/) { print substr("$_", 5);  print FILE substr("$_", 5);}
      

	if ($_ =~ m/workspace\/(.*?)\/src/)
	#	{print $1;print "\n";}
		{push(@mod_jar,$1);}
	

        }                                       #end foreach
        close FILE;
	
	remove_duplicates(@mod_jar);
	print "\n\n\nSet of jars to copy to WIP: @mod_jar\n\n\n";

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

########  Adding my changes
=pod
	open FILE, "<patch" or die $!;
        my @check = <FILE>;
        print @check;
	foreach (@check) {
		if ( %workspace/(.*?)/% ) { print "got <$1>\n"; }
	}
        close FILE;



=cut

###################### Testing closed


	
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

sub shaDiff {
	print "Starting to build Defect Patch ....\n\n";
SHA:	print "Please enter the [Current SHA-ID / Current Tag Name]: ";
        my $cur = <STDIN>;
	print "Please enter the [Parent SHA-ID / Parent Tag Name]: ";
	my $par = <STDIN>;
	chomp $cur;
	chomp $par;
	print "$cur..$par";

	chdir $rep_name;
	`git diff --name-status $cur..$par > fulpat`;	

	if ($? eq 32768)
	  {
            	system("tput smso");
                print STDERR "\n\t\tPlease enter a proper SHA-Id or a Valid Tag name ... \n\n";
                system("tput rmso");
                goto SHA;
        }

	open FILE, "<fulpat" or die $!;
	my @mod_jar;					#To store all the modified jars during patch creation
	my @lines = <FILE>;				#Stores each line from file fulpat in this array
	#print @lines;
	close FILE;

	open FILE, "+>patch" or die $!;
	foreach (@lines) {
        if(($_ =~ /^A\t/)||($_ =~ /^M\t/)){
        print FILE substr("$_", 2);}
#        print "substr("$_", 2)";
        elsif($_ =~ /^From/) { print substr("$_", 5);  print FILE substr("$_", 5);}
      

	if ($_ =~ m/workspace\/(.*?)\/src/)
	#	{print $1;print "\n";}
		{push(@mod_jar,$1);}
        }
	print "@mod_jar ...........  ";
                                       #end foreach
        close FILE;
	
	remove_duplicates(@mod_jar);
	print "\n\n\nSet of jars to copy to WIP: @mod_jar\n\n\n";

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

########  Adding my changes
=pod
	open FILE, "<patch" or die $!;
        my @check = <FILE>;
        print @check;
	foreach (@check) {
		if ( %workspace/(.*?)/% ) { print "got <$1>\n"; }
	}
        close FILE;



=cut

###################### Testing closed


	
	print "Changing fulpat attributes";
	`perl -p -i.bak -e 's/^D\t/Delete\t\t/g' '${rep_name}\/fulpat'`;
	`perl -p -i.bak -e 's/^A\t/Added\t\t/g' '${rep_name}\/fulpat'`;
	`perl -p -i.bak -e 's/^M\t/Modified\t/g' '${rep_name}\/fulpat'`;


#	`ant -f /home/archbuild/masterbld.xml`;	
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
	$headloc="$rep_name\/.git\/refs\/heads";
  	print "$headloc\n\n\n";

#open(PFILE, "<", $tagloc\/master) or die "open master failed:$!\n";
  	open PFILE, "<$headloc\/master" or die "open master failed:$!\n";
  	my @plines = <PFILE>;
  	print @plines;
  	close(PFILE);
  	`git tag $abc.$d.$e`;
}



sub autoTagging {

	my ($abc, $d, $e);
	my $foo='100';
	chdir "$rep_name";

	my $brn = &branchName();

	print "\n\n\n This is my current branch name   $brn .........\n\n\n\n";

	my $vpfile = ".verprop";
	open(INF, "<", $vpfile) or die "open $vpfile failed:$!\n";
	my @version = <INF>;
	close(INF);

	print "\n\n\n this is a test of perl \n\n\n";

	print "\n\n\nthis is my halwa @version ..........";
	
	foreach (@version) { 
	 if (($_ =~ /^$brn/)) {							#some error in this line ; works if brn repld with master
	 	($abc, $d, $e) = $_ =~ /(\d+\.\d+\.\d+)\.(\d+)\.(\d+)/;
		print "\n\n\n alalala \n\n";
	 print "\n\n fofoo $_"; 


		  }
	}
	print "\n\nhello mr. $foo \n\n\n";
	print "$abc.$d.$e\n";
	print "\n\nthis is a test  ...........$abc ";
	my $g = "$abc.$d.$e";
	print "\n\n\n this is $g ";
	++$e;
	my $f = "$abc.$d.$e";

	print "\n\n$f \n\n\n";

	`perl -p -i.bak -e "s/$brn=$g/$brn=$f/" $rep_name\/$vpfile`;

	print "\n\nPress Enter to go back to main menu";
        my $x = <STDIN>;           ## Use this to exit the flow and come back to the main menu
}
