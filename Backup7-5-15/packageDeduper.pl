#!/usr/bin/perl

### Begin main ###
my %packageDedupHash;
my %fileDedupHash;
my %vforkDedupHash;

my $inFile;
my $outFile;
my $line;

my $inFileName = $ARGV[0];
my $outFileName = $ARGV[1];

open($inFile, "$inFileName");
open($outFile, ">$outFileName");

while($line = <$inFile>){
	if(!($line =~ /read\|\//) && $line =~  /read\|([^\|]*)\|([^\|]*)\|([^\n]*)/){
	    #$1 = package
	    #$2 = file_path
	    #$3 = file_hash
	    if($1 eq "-"){
		if(!(exists($fileDedupHash{$2}))){
		    print $line;	
		    $fileDedupHash{$2} = 1;
		}
	    }
	    elsif(!(exists($packageDedupHash{$1}))){
		print $line;
		$packageDedupHash{$1} = 1;
	    }
	}
	elsif($line =~ /execve.*/){
	    %packageDedupHash = ();
	    %fileDedupHash = ();
#	    %vforkDedupHash = ();
	    print $line;
	}
	elsif($line =~ /vfork.*/ || $line =~ /clone.*/){
	    if(!(exists($vforkDedupHash{$line}))){
		$vforkDedupHash{$line} = 1;
		print $line;
	    }
	}
	else{
	    print $line;
	}
}

