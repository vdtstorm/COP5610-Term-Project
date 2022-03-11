#!/usr/bin/perl

my $execCounter = 0;
my $readFileCounter = 0;
my $writeFileCounter = 0;
my $avg;

my $line;
my $inFile;

open($inFile, "table.txt");

while($line = <$inFile>){
    if($line =~ /execv*/){
	$execCounter += 1;
    }
    elsif($line =~ /read*/){
	$readFileCounter += 1;
    }
    elsif($line =~ /write*/){
	$writeFileCounter += 1;
    }
}

print "Total number of execs: $execCounter\n";
print "Total number of reads: $readFileCounter\n";
print "Total number of writes: $writeFileCounter\n";
$avg = ($readFileCounter / $execCounter);
print "Reads per executable: $avg\n";
$avg = ($writeFileCounter / $execCounter);
print "Writes per executable: $avg\n";
