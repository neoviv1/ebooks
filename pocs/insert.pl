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

#my @files=`ls -t /home/git/repositories/base_rep.git/refs/tags | awk {'print $9'}`;
my @files=`ls -t /home/archbuild/base_rep/.git/refs/tags | awk {'print $9'}`;

#$path = "/home/git/repositories/base_rep.git/refs/tags";
$path = "/home/archbuild/base_rep/refs/tags";

print  @files;
open FILE, "<$path/$files[0]";
@lines = <FILE>;
print  @lines;
      

# PERL MYSQL CONNECT()
$connect = Mysql->connect($host, $database, $user, $pw);

# SELECT DB
$connect->selectdb($database);

# DEFINE A MySQL QUERY
#for ($i=0;$i<=@files;$i++) {
#print "$files[$i]";
#$myquery = "INSERT INTO 
#$tablename (SHA1, tags) 
#VALUES ('absssa','$files[0]')"; }


$files[0]=~ s/\n/ /g;
$myquery = "INSERT INTO
$tablename (SHA1, tags)
VALUES ('$lines[0]','$files[0]')";


# EXECUTE THE QUERY FUNCTION
$execute = $connect->query($myquery);

# AFFECTED ROWS
$affectedrows = $execute->affectedrows($myquery);

# ID OF LAST INSERT
$lastid = $execute->insertid($myquery);

print $affectedrows."<br />";
print $lastid."<br />";
