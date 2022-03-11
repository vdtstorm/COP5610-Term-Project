#!/usr/bin/perl

#!/usr/bin/perl

### Begin main ###
my %packageDedupHash;
my %vforkDedupHash;

my $inFile1;
my $inFile2;
my $line;
my $fd;
my $filePath;

my $inFileName1 = $ARGV[0];
my $inFileName2 = $ARGV[0];

my %readHash;
my %writeHash;
my %fdToFilePath;

open($inFile1, "$inFileName1");
open($inFile2, "$inFileName2");

while($line = <$inFile1>){
    if($line =~ /open\(\"(.*)\"(.*)\=\s(.*)/){
	$fd = $3;
	$fd =~ s/\s//g;
	$fd =~ s/\n//g;
	$filePath = $1;

	if($fd != -1){
	    $fd =~ s/\s//g;
	    $fdToFilepath{$fd} = $filePath;
	}
    }
    elsif($line =~ /read\((\d*)\,/){
	$fd = $1;
	$fd =~ s/\s//g;
	$fd =~ s/\n//g;
	$readHash{$fdToFilePath{$fd}} = 1;
    }
    elsif($line =~ /write\((\d*)\,/){
	$fd = $1;
	$fd =~ s/\s//g;
	$fd =~ s/\n//g;
	$writeHash{$fdToFilePath{$fd}} = 1;
    }
}

while($line = <$inFile2>){
    if($line =~ /read\|([^\|]*)\|([^\n]*)/){
	# $1 is the path
	# $2 is the md5 hash
	$filePath = $1;
	$readHash{$filePath} = 0;
    }
	elsif($line =~ /write\|([^\|]*)\|([^\n]*)/){
	# $1 is the path
	# $2 is the md5 hash
	$filePath = $1;
	$writeHash{$filePath} = 0;
    }
}

print STDERR "Printing missed reads and writes\n";
print STDERR "--------------------------------\n";

foreach $key (keys %readHash){
    if($readHash{$key} == 1){
	print STDERR "Missed read: $key\n";
    }
}

foreach $key (keys %writeHash){
    if($writeHash{$key} == 1){
	print STDERR "Missed write: $key\n";
    }
}

print STDERR "Finished printing misses\n";
