#!/usr/bin/perl

sub hashValueAscendingNum {
    $fileHash{$a} <=> $fileHash{$b};
}

my $inFile;
my $line;

my $inFileName = $ARGV[0];

my %pidToArray;
my %fileHash;
my @dependencyList;
my %pidToIndex;
my %writeToDepArray;
my %packageToPID;

my %uniqPrintHash;

my $fileIndex = 0;
my $currentDepIndex = 0;
my $pidIndex = 0;
my $count = 0;
my $key;
my $currentVforkPID;
my $numDependencies = 0;

my $currentPID;
my $currentPackage;
open($inFile, "$inFileName");

while($line = <$inFile>){
    if($line =~ /execve\|([^\|]*)\|([^\|]*)\|(\d*)\|([^\n]*)\n/){
	# $1 is the path
	# $2 is the md5 hash
	# $3 is the processID
	# $4 is the arglist
	$currentPID = $3;
	$currentPackage = $1;

	if(!exists($pidToArray{$currentPID})){
	    $pidToArray{$currentPID} = $pidIndex;
	    $pidIndex++;
	}

	if(!exists($pidToIndex{$currentPID})){
	    $pidToIndex{$currentPID} = 0;
	}

	if(!exists($fileHash{$currentPackage})){	
	    $fileHash{$currentPackage} = $fileIndex;
	    $fileIndex++;
	}
	if(!(grep {$_ eq $fileHash{$currentPackage} } @dependencyList)){
	    $dependencyList[$pidToArray{$currentPID}][$pidToIndex{$currentPID}] = $fileHash{$currentPackage};
	    $pidToIndex{$currentPID}++;
	}
    }
    elsif($line =~ /read\|([^\|]*)\|([^\|]*)\|.*/){
	# $1 is the file/package
	if($1 eq '-'){
	    $currentPackage = $2;
	}
	else{
	    $currentPackage = $1;
	}
	if(exists($writeToDepArray{$currentPackage})){
	    for($count = 0; $count < $pidToIndex{$packageToPID{$currentPackage}}; ++$count){
		$dependencyList[$pidToArray{$currentPID}][$pidToIndex{$currentPID}] = $dependencyList[$pidToArray{$packageToPID{$currentPackage}}][$count];
		$pidToIndex{$currentPID}++;
	    }
	}
	if(!exists($fileHash{$currentPackage})){	
	    $fileHash{$currentPackage} = $fileIndex;
	    $fileIndex++;
	}
	if(!(grep {$_ eq $fileHash{$currentPackage} } @dependencyList)){
	    $dependencyList[$pidToArray{$currentPID}][$pidToIndex{$currentPID}] = $fileHash{$currentPackage};
	    $pidToIndex{$currentPID}++;
	}
    }
    elsif($line =~ /write\|([^\|]*)\|.*/){
	# $1 is the file/package being written to

	if(!exists($fileHash{$currentPackage})){	
	    $fileHash{$currentPackage} = $fileIndex;
	    $fileIndex++;
	}

	if($1 ne "STDOUT" && $1 ne "STDERR" && $1 ne "STDIN"){
	    $writeToDepArray{$1} = $pidToArray{$currentPID};
	    $packageToPID{$1} = $currentPID;
	    print "$1";
	    for($count = 0; $count < $pidToIndex{$currentPID}; ++$count){
		if(!(exists($uniqPrintHash{$dependencyList[$pidToArray{$currentPID}][$count]}))){
		    print "\t$dependencyList[$pidToArray{$currentPID}][$count]";
		    $uniqPrintHash{$dependencyList[$pidToArray{$currentPID}][$count]} = 1;
		}
		$numDependencies++;
	    }
	    print "\n";
	    %uniqPrintHash = {};
	}
    }
    elsif($line =~ /vfork\|([^\n]*)\n/){
	# $1 is the vfork PID
	$currentVforkPID = $1;

	if(!exists($pidToArray{$currentVforkPID})){
	    $pidToArray{$currentVforkPID} = $pidIndex;
	    $pidIndex++;
	}

	if(!exists($pidToIndex{$currentVforkPID})){
	    $pidToIndex{$currentVforkPID} = 0;
	}

	for($count = 0; $count < $pidToIndex{$currentPID}; ++$count){
	    $dependencyList[$pidToArray{$currentVforkPID}][$pidToIndex{$currentVforkPID}] = $dependencyList[$pidToArray{$currentPID}][$count];
	    $pidToIndex{$currentVforkPID}++;
	}
    }
    else{
	print $line;
    }
}



open(MYFILE, ">tableLegend.txt");

foreach $key (sort {$fileHash{$a} <=> $fileHash{$b}} keys %fileHash){
    print MYFILE "$key\t$fileHash{$key}\n";
}

print MYFILE "Total dependencies: $numDependencies\n";
