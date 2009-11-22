#!/opt/lampp/bin/perl

    open (CMD, 
      "(cmd args | sed 's/^/STDOUT:/') 2>&1 |");

    while () {
      if (s/^STDOUT://)  {
          print "line from stdout: ", $_;
      } else {
          print "line from stderr: ", $_;
      }
    }

