#!/usr/bin/perl

my $inFile;
my $line;

my $inFileName = $ARGV[0];

my $currentGID = -1;
my $currentPID;

my %gidHash;
my %vforkHash;

open($inFile, "$inFileName");

while($line = <$inFile>){
    if($line =~ /execve\|([^\|]*)\|([^\|]*)\|(\d*)\|([^\n]*)\n/){
	# $1 is the path
	# $2 is the md5 hash
	# $3 is the processID
	# $4 is the arglist

	$currentPID = $3;

	if($currentGID != -1){
	    $gidHash{$currentPID} = $currentGID;	
	}
	elsif($gidHash{$vforkHash{$currentPID}} != -1){
	    $gidHash{$currentPID} = $gidHash{$vforkHash{$currentPID}};
	}
	else{
	    $gidHash{$currentPID} = -1;
	}

	if($gidHash{$currentPID} != -1){
	    print "execve|$1|$2-0" . "$gidHash{$currentPID}|$3|$4\n";
	}
	else{
	    print $line;
	}
    }
    elsif($line =~ /setpgid\|([^\n]*)\n/){
	$currentGID = $1;
    }
    elsif($line =~ /vfork\|([^\n]*)\n/){
	$vforkHash{$1} = $currentPID;
	print $line;
    }
    elsif($line =~ /Entry*/){
	$currentGID = -1;
    }
    else{
	print $line;
    }
}
