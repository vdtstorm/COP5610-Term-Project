#!/usr/bin/perl
use Time::Piece;

my $inFile;
my $total = 0;
my $avg = 0;
my $avgCompletable = 0;
my $simVersion;
my $numDeps;
my $numProcs;
my $numGenerated = 0;
my $totalPercentCompletable = 0;
my $numDisks = $ARGV[0];
my $numFailed = $ARGV[1];
my $numTests = $ARGV[2];
my $replication = $ARGV[3];
my $selective = $ARGV[4];
my $coLocation = $ARGV[5];
my $echoPrint = $ARGV[6];
my $dotFileName = $ARGV[7];

for($count = 0; $count < $numTests; ++$count){
    $fileName = "outFile" . $count;
    system("./simulator.pl $dotFileName $numDisks $fileName $numFailed $replication $selective $coLocation n");
}

for($count = 0; $count < $numTests; ++$count){
    $fileName = "outFile" . $count;
    open($inFile, $fileName);
    while($line = <$inFile>){
	if($line =~ /Percentage recoverable\:\s(\d*)/){
	    $total += $1;
	}
	elsif($line =~ /Total number of dependencies\:\s(\d*)/){
	    $numDeps = $1;
	}
	elsif($line =~ /Total executables\:\s(\d*)/){
	    $numProcs = $1;
	}
	elsif($line =~ /Total generated files:\s(\d*)/){
	    $numGenerated = $1;
	}
	elsif($line =~ /simversion:\s(.*)/){
	    $simVersion = $1;
	}
	elsif($line =~ /Percent completable:\s(.*)/){
	    $totalPercentCompletable += $1;
	}
    }
}

for($count = 0; $count < $numTests; ++$count){
    $fileName = "outFile" . $count;
    system("rm $fileName");
}

$avg = ($total / $numTests);
$avgCompletable = ($totalPercentCompletable / $numTests);


print "Current version: $simVersion\n"; 
#print $outFile "Current date: $dt->datetime\n"; 
print "Average number of regenerable files we can recover: $avg\n";
print "Average number of processes that can complete: $avgCompletable\n";
print "Number of generated files $numGenerated\n";
print "Number of dependencies: $numDeps\n";
print "Number of processes: $numProcs\n";
print "Number of tests: $numTests\n";
print "Number of disks: $numDisks\n";
print "Number of broken disks: $numFailed\n";
print "Degree of replication: $replication";
if($selective eq "y"){
    print " with selective replication\n";
}
else{
    print "\n";
}
if($coLocation eq "y"){
    print "Co-location rules applied\n";
}

my $outFile;
open($outFile, ">>testResults.txt");
print $outFile localtime->strftime('%Y-%m-%d');
print $outFile ",$simVersion,$avg,$numGenerated,$numDeps,$numProcs,$numTests,$numDisks,$numFailed,$replication,$avgCompletable,$echoPrint";

if($selective eq "y"){
    print $outFile ",y,";
}
else{
    print $outFile ",n,";
}
if($coLocation eq "y"){
    print $outFile "y\n";
}
else{
    print $outFile "n\n";
}
