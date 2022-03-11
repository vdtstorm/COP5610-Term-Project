#!/usr/bin/perl

my $filename = $ARGV[0];
my $inFH;
my $line;

my $currentDepth;
my $currentPID;

my %depthHash;


open($inFH, $filename);

while($line = <$inFH>){
    if($line =~ /execve\|.*\|.*\|(.*)\|.*/){
	$currentPID = $1;

    	if(exists($depthHash{$currentPID})){
    	    $currentDepth = $depthHash{$currentPID};
    	}
    	else{
    	    $currentDepth = 0;
    	}
	print $line;
    }
    elsif($line =~ /clone\|(.*)/ || $line =~ /vfork\|(.*)/){
    	$depthHash{$1} = $currentDepth + 1;
	print $line;
    }
    elsif($line =~ /End/){
    	print "depth|$currentDepth\n";
    	print "End\n\n";
	$currentPID = 0;
	$currentDepth = 0;
    }
    else{
    	print $line;
    }
}
