#!/usr/bin/perl

my $inFile = $ARGV[0];
my $fh1;
my $dpkgReturn;
my @spltLine;

open($fh1, $inFile);

while($line = <$fh1>){

    @splitLine = split(' ', $line);
    
    $dpkgReturn = `dpkg -L $splitLine[0]`;

    print "$splitLine[0]:\n";
    print "$dpkgReturn\n";
}
