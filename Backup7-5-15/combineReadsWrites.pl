#!/usr/bin/perl

my $inFile;
my $outFile;
my $line;

my %readHash;
my %writeHash;

my @splitArray;

my $inFileName = $ARGV[0];

my $package;
my $md5;
my $path;

open($inFile, "$inFileName");

while($line = <$inFile>){
    if($line =~ /execve.*/){
	%readHash  =  ();
	%writeHash =  ();
	print $line;
    }
    elsif($line =~  /read\|([^\|]*)\|([^\|]*)\|([^\n]*)/){
	#$1 = package
	#$2 = file_path
	#$3 = file_hash
	$package = $1;
	$path = $2;
	$md5 = $3;
	if($package eq "-"){
	    @splitArray = split(/\/([^\/]+)$/, $path);
	    if(!(exists($readHash{$splitArray[0]}))){
		$readHash{$splitArray[0]} = 1;
		print $line;
	    }
	    elsif($readHash{$splitArray[0]} < 3){
		++$readHash{$splitArray[0]};
		print $line;
	    }
	}
	else{
	    print $line;
	}
    }
    elsif($line =~  /write\|([^\|]*)\|([^\|]*)\|([^\n]*)/){
	#$1 = package
	#$2 = file_path
	#$3 = file_hash
	$package = $1;
	$path = $2;
	$md5 = $3;
	if($package eq "-"){
	    @splitArray = split(/\/([^\/]+)$/, $path);
	    if(!(exists($writeHash{$splitArray[0]}))){
		$writeHash{$splitArray[0]} = 1;
		print $line;
	    }
	    elsif($writeHash{$splitArray[0]} < 3){
		++$writeHash{$splitArray[0]};
		print $line;
	    }
	}
	else{
	    print $line;
	}
    }
    else{
	print $line;
    }
}
