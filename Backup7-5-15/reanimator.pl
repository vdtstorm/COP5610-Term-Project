#!/usr/bin/perl

my $inFileName = $ARGV[0];
my $inFile;
my $line;
my $flag = 0;
open($inFile, "$inFileName");

while(($line = <$inFile>) && ($flag != 1)){
	if($line =~ /execve\|([^\|]*)\|([^\|]*)\|(\d*)\|([^\n]*)\n/){
	    #$1 is the file path to the binary
	    #$2 is the MD5 hash
	    #$3 is the process ID
	    #$4 is the argument list

	    my $ret = system("$4");
	    if($ret == 0){
		print "Reanimation successful!\n";
	    }
	    else{
		print "Reanimation failed\n";
	    }
	    $flag = 1;
	}	
}


