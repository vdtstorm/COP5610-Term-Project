#!/usr/bin/perl

#todo: diskcontents should track copies not a separate hash
#copies are being handled incorrectly at the moment
#

sub checkRegenerability{
    my %md5ToGenerated = %{shift()};
    my %md5ToDependencies = %{shift()};
    my %md5ToRegenerable = %{shift()};
    my %md5ToCopies = %{shift()};
    my %md5ToExecutable = %{shift()};
    my %md5ToLabel = %{shift()};
    my %md5ToRegenSeen = %{shift()};
    my $file = shift();

    $md5ToRegenSeen{$file} = 1;

    if(exists($md5ToExecutable{$file})){
	if($md5ToCopies{$file} == 0){
	    if($debugFlag eq "y"){
		print STDERR "Broken1 due to $md5ToLabel{$file}\n";
	    }
	    return 0;
	}
    }
    else{
	if($md5ToCopies{$file} == 0){
	    if(!(exists($md5ToGenerated{$file}))){
		if($debugFlag eq "y"){
		    print STDERR "Broken2 due to $md5ToLabel{$file}\n";
		}
		return 0;
	    }
	}
    }
    foreach my $key1 (keys %{$md5ToDependencies{$file}}){
	if(!(exists($md5ToRegenSeen{$key1}))){
	    if(!(checkRegenerability(\%md5ToGenerated, \%md5ToDependencies, \%md5ToRegenerable, \%md5ToCopies, \%md5ToExecutable, \%md5ToLabel, 
				     \%md5ToRegenSeen, $key1))){
		if($debugFlag eq "y"){
		    print STDERR "Broken3 due to $md5ToLabel{$key1}\n";
		}
		return 0;
	    }
	}
    }
    return 1;
}

my $filename = $ARGV[0];
my $numDisks = $ARGV[1];
my $outFileName = $ARGV[2];
my $numLostDisks = $ARGV[3];
my $inFile;
my $outFile;
my $line;
my $numDeps = 0;
my $numProcs = 0;
my $simVersion = "4.0";
my $replication = $ARGV[4];
my $selective = $ARGV[5];
my $coLocation = $ARGV[6];
my $debugFlag = $ARGV[7];
my $temp;
my $totalNumExecutables = 0;

my %md5ToDepth;
my %md5ToLabel;
my %md5ToDependencies;
my %md5ToExecutable;
my %md5ToCopies; 

my %md5ToGenerated;
my %md5ToRegenerable;
my %md5ToRegenSeen;


my %lostDisks;
my %diskContents;
my %fileToBroken;
my %individualFiles;

my %eliminatedDisks;
my %alreadyAllocated;

my %md5ToHistogram;

open($inFile, $filename);

while($line = <$inFile>){
    if($line =~ /([^-^\s]*).*\s\[label\=\"([^\"]*)\"/){
	if(!(exists($md5ToLabel{$1}))){
	    $md5ToLabel{$1} = $2;
	    $md5ToCopies{$1} = 0;
	    $diskContents{$1}{$temp} = 0;
	    for(my $i = 0; $i < $replication; ++$i){
	     	$temp = int(rand($numDisks));
	     	while(exists($alreadyAllocated{$1}{$temp})){
	     	    $temp = int(rand($numDisks));
	     	}
	     	$diskContents{$1}{$temp} += 1;
	     	$md5ToCopies{$1} += 1;
	     	$alreadyAllocated{$1}{$temp} = 1;
	    }
	    $numDeps++;
	}
    }
    elsif($line =~ /([^-^\s]*).*\s\-\>\s([^;^-]*)/){
	$md5ToDependencies{$2}{$1} = 1;
	$md5ToGenerated{$2} = 1; #provisionally add file to md5ToGenerated
    }
    elsif($line =~ /([^-^\s]*).*\s\[shape\=box\].*\<b\>(.*)\<\/b\>.*/){
	$totalNumExecutables++;
	$md5ToHistogram{$1} += 1;
	if(!(exists($md5ToLabel{$1}))){
	    $md5ToLabel{$1} = $2;
	    $md5ToExecutable{$1} = $2;
 	    $md5ToCopies{$1} = 0;
	    $diskContents{$1}{$temp} = 0;
 	    for(my $i = 0; $i < $replication; ++$i){
 		$temp = int(rand($numDisks));
		while(exists($alreadyAllocated{$1}{$temp})){
		    $temp = int(rand($numDisks));
		}
 		$diskContents{$1}{$temp} += 1;
 		$md5ToCopies{$1} += 1;
		$alreadyAllocated{$1}{$temp} = 1;
 	    }
	    $numProcs++;
	}
	if(!(exists($md5ToExecutable{$1}))){
	    $md5ToExecutable{$1} = $2;
	    $numProcs++;
	}
    }
}


#remove files in md5ToGenerated that are also executables
foreach my $key1 (keys %md5ToGenerated){
    if(exists($md5ToExecutable{$key1})){
	delete $md5ToGenerated{$key1};	
    }
    elsif($md5ToLabel{$key1} eq "STDOUT"){
	delete $md5ToGenerated{$key1};	
    }
}

open($outFile, ">". $outFileName);

#selectively replicate critical files
if($selective eq "y"){
    foreach my $key1 (keys %md5ToLabel){
	if(!(exists($md5ToGenerated{$key1}))){
	    $temp = int(rand($numDisks));
	    while(exists($alreadyAllocated{$key1}{$temp})){
		$temp = int(rand($numDisks));
	    }
	    $diskContents{$key1}{$temp} += 1;
	    $md5ToCopies{$key1} += 1;
	    $alreadyAllocated{$key1}{$temp} = 1;
	}
    }
    print $outFile "Selective replication used\n";
}

#separate files and their dependencies
if($coLocation eq "y"){
    my $i = 0;
    foreach my $key1 (keys %md5ToGenerated){
	for(my $j = 0; $j < $numDisks; $j++){
	    if(($i % $numDisks) != $j){
		my $pivot = $diskContents{$key1}{$j};
		$diskContents{$key1}{$j} = 0;
		$diskContents{$key1}{$i % $numDisks} += $pivot;
	    }
	    foreach my $key2 (keys %{$md5ToDependencies{$key1}}){
		if(($i % $numDisks) != $j){
		    $pivot = $diskContents{$key2}{$j};
		    $diskContents{$key2}{$j} = 0;
		    $diskContents{$key2}{$i % $numDisks} += $pivot;
		}
		foreach my $key3 (keys %{$md5ToDependencies{$key2}}){
		    if(($i % $numDisks) != $j){
			$pivot = $diskContents{$key3}{$j};
			$diskContents{$key3}{$j} = 0;
			$diskContents{$key3}{$i % $numDisks} += $pivot;
		    }
		}
	    }
	}
	++$i;
    }



    # foreach my $key1 (keys %md5ToGenerated){
    # 	for(my $i = 1; $i < $numDisks; ++$i){
    # 	    if($diskContents{$key1}{$i} > 0){
    # 		my $pivot = $diskContents{$key1}{$i};
    # 		$diskContents{$key1}{$i} = 0;
    # 		$diskContents{$key1}{0} += $pivot;
    # 		if($debugFlag eq "y"){
    # 		    print STDERR "Placing $md5ToLabel{$key1} with $pivot copies on disk 0\n";
    # 		}
    # 	    }
    # 	}
    # }
    # foreach my $key1 (keys %md5ToExecutable){
    # 	$temp = 0;
    # 	while(0 == $temp){
    # 	    $temp = int(rand($numDisks));
    # 	}
    # 	if($diskContents{$key1}{0} > 0){
    # 	    if($debugFlag eq "y"){
    # 		print STDERR "Top loop:\n";
    # 		print STDERR "Found $md5ToLabel{$key1} on disk 0\n";
    # 		print STDERR "Moving all copies of $md5ToLabel{$key1} on disk 0 to disk $temp\n";
    # 	    }
    # 	    my $pivot = $diskContents{$key1}{0};
    # 	    $diskContents{$key1}{0} = 0;
    # 	    $diskContents{$key1}{$temp} = 0;
    # 	    $diskContents{$key1}{$temp} += $pivot;
    # 	}
    # 	foreach my $key2 (keys %{$md5ToDependencies{$key1}}){
    # 	    if($diskContents{$key2}{0} > 0 && (!(exists($md5ToGenerated{$key2})))){
    # 		if($debugFlag eq "y"){
    # 		    print STDERR "Bottom loop:\n";
    # 		    print STDERR "Found $md5ToLabel{$key2} on disk 0\n";
    # 		    print STDERR "Moving all copies of $md5ToLabel{$key2} on disk 0 to disk $temp\n";
    # 		}

    # 		my $pivot = $diskContents{$key2}{0};
    # 		$diskContents{$key2}{0} = 0;
    # 		$diskContents{$key2}{$temp} = 0;
    # 		$diskContents{$key2}{$temp} += $pivot;
    # 	    }
    # 	}
    # }
    print $outFile "Co-location rules used\n";
}


print $outFile "---------------Dependencies---------------\n";

foreach my $key1 (keys %md5ToDependencies){
    print $outFile "$md5ToLabel{$key1}:\n";
    foreach my $key2 (keys %{$md5ToDependencies{$key1}}){
	print $outFile "$md5ToLabel{$key2}\n";
    }
    print $outFile "\n\n";
}

print $outFile "Total number of dependencies: $numDeps\n";
print $outFile "Total number of unique processes: $numProcs\n";
print $outFile "------------------------------------------\n\n";

for($count = 0; $count < $numDisks; ++$count){
    print $outFile "\nDisk $count:\n";
    foreach my $key1 (keys %md5ToLabel){
	if($diskContents{$key1}{$count} > 0){
	    print $outFile "$md5ToLabel{$key1}\n";
	}
    }
}

for(my $i = 0; $i < $numLostDisks; ++$i){
    $temp = int(rand($numDisks));
    while(exists($eliminatedDisks{$temp})){
	$temp = int(rand($numDisks));
    }
    $lostDisk{$i} = $temp;
    $eliminatedDisks{$temp} = 1;
}

for(my $i = 0; $i < $numLostDisks; ++$i){
    print $outFile "\nDisk outage on: $lostDisk{$i}\n";
}

for(my $i = 0; $i < $numLostDisks; ++$i){
    foreach my $key1 (keys %md5ToLabel){
	if(exists($diskContents{$key1}{$lostDisk{$i}}) && $diskContents{$key1}{$lostDisk{$i}} > 0){
	    $fileToBroken{$key1}{$lostDisk{$i}} = 1;
	    $md5ToCopies{$key1} -= $diskContents{$key1}{$lostDisk{$i}};
	    $diskContents{$key1}{$lostDisk{$i}} = 0;
	}
    }
}

print $outFile "simversion: $simVersion\n";
print $outFile "Broken disks: $numLostDisks\n";
print $outFile "Replication: $replication\n";

print $outFile "\n\nIndividual files broken:\n";
    foreach my $key1 (keys %md5ToLabel){
	if($md5ToCopies{$key1} == 0){
	    print $outFile "$md5ToLabel{$key1} | hash $key1\n";
	}
}

print $outFile "Broken generated files:\n";
my $brokenFlag = 0;
foreach my $key1 (keys %md5ToGenerated){
    if($md5ToCopies{$key1} == 0){
	$brokenFlag = 1;
    }
    else{
	foreach my $key2 (keys %{$md5ToDependencies{$key1}}){
	    if($md5ToCopies{$key2} == 0){
		$brokenFlag = 1;
	    }
	}
    }
    if($brokenFlag == 1){
	print $outFile "$md5ToLabel{$key1}\n";
    }
    $brokenFlag = 0;
}


foreach my $key1 (keys %md5ToGenerated){
    if($md5ToCopies{$key1} == 0){
	    if($debugFlag eq "y"){
		print STDERR "Looking at file $md5ToLabel{$key1}:\n";
	    }
	$md5ToRegenerable{$key1} = checkRegenerability(\%md5ToGenerated, \%md5ToDependencies, \%md5ToRegenerable, \%md5ToCopies, 
						       \%md5ToExecutable, \%md5ToLabel, \%md5ToRegenSeen, $key1);
    }
    else{
	$md5ToRegenerable{$key1} = 1;
    }
    %md5ToRegenSeen = ();
}

my $countRecoverable = 0;

print $outFile "\n\nRegeneration report:\n";
foreach my $key1 (keys %md5ToRegenerable){
    if($md5ToRegenerable{$key1} == 0){
	print $outFile "Cannot be regenerated: $md5ToLabel{$key1}\n";
	foreach my $key2 (keys %{$md5ToDependencies{$key1}}){
	    if($md5ToCopies{$key2} == 0){
#		print $outfile "Missing $md5ToLabel{$key2}\n";
	    }
	}
    }
    else{
	print $outFile "Regenerable: $md5ToLabel{$key1}\n";
	$countRecoverable++;
    }
}

my $count = keys %md5ToGenerated;
my $percentRecoverable = $countRecoverable / $count * 100;

print $outFile "Total generated files: $count\n";
print $outFile "Percentage recoverable: $percentRecoverable\n";

my $numCannotComplete = 0;
my $percentCompletable = 0;

foreach my $key1 (keys %md5ToExecutable){
    if($md5ToCopies{$key1} == 0){
	foreach my $key2 (keys %{$md5ToDependencies{$key1}}){
	    if($md5ToRegenerable{$key2} == 0){
		if($md5ToLabel{$key1} =~ /\/bin*/ || $md5ToLabel{$key2} =~ /\/lib*/){
		}
		else{
		    if($md5ToCopies{$key2} == 0){
			$numCannotComplete += $md5ToHistogram{$key1};
			last;
		    }
		}
	    }
	}
    }
}

#$count = 0;
#foreach my $key1 (keys %md5ToCopies){
#    $count += $md5ToCopies{$key1};
#}

$percentCompletable = (1 - ($numCannotComplete / $totalNumExecutables)) * 100;

print $outFile "Total executables: $totalNumExecutables\n";
print $outFile "Percent completable: $percentCompletable\n";

close($outFile);

