#!/usr/bin/perl

sub calculateProbabilities{
    my %md5ToLabel = %{shift()};
    my %md5ToGenerated = %{shift()};
    my %md5ToDependencies = %{shift()};
    my %md5ToDurability = %{shift()};
    my %md5ToExecutable = %{shift()};
    my %calculateProbabilitySeen = %{shift()};
    my $file = shift();
    my $durability = shift();
    my $defaultDurabilityValue = $durability;

    my $dependencyValue;

    $calculateProbabilitySeen{$file} = 1;

#    print STDERR " $md5ToLabel{$file} ($durability) ";

    foreach my $key2 (keys %{$md5ToDependencies{$file}}){
#	print STDERR " * ( $md5ToLabel{$key2} ($md5ToDurability{$key2}) ";
	$dependencyValue = (1 - $md5ToDurability{$key2});
	foreach my $key3 (keys %{$md5ToDependencies{$key2}}){
	    if(!(exists($calculateProbabilitySeen{$key3}))){
		if(!(exists($md5ToGenerated{$key3})) && !(exists($md5ToExecutable{$key3}))){
#		    print STDERR " * (1 - $md5ToLabel{$key3}) (1 - $md5ToDurability{$key3}) ";
		    $dependencyValue *= (1 - $md5ToDurability{$key3});
		}
		elsif(exists($md5ToGenerated{$key3})){
#		    print STDERR " * (1 - ";
		    $dependencyValue *= (1 - calculateProbabilities(\%md5ToLabel, \%md5ToGenerated, \%md5ToDependencies, 
							  \%md5ToDurability, \%md5ToExecutable, \%calculateProbabilitySeen, $key3, $defaultDurabilityValue));
#		    print STDERR " ) ";
		}
	    }
#	    print STDERR " ) ";
	}
	$durability *= (1 - $dependencyValue);
    }
    $md5ToDurability{$file} = $durability;
    return $durability;
}

my $inFile;
my $line;

my $filename = $ARGV[0];
my $numDisks = $ARGV[1];
my $numDisksLost = $ARGV[2];
my $selectiveReplication = $ARGV[3];
my $coLocation = $ARGV[4];

my $numFiles = 0;
my $numGeneratedFiles = 0;

my %md5ToLabel;
my %md5ToDependencies;
my %md5ToGenerated;
my %md5ToExecutable;
my %md5ToDurability;
my %calculateProbabilitySeen;

open($inFile, $filename);

while($line = <$inFile>){
    if($line =~ /([^-^\s]*).*\s\[label\=\"([^\"]*)\"/){
	if(!(exists($md5ToLabel{$1}))){
	    $numFiles++;
	}
	$md5ToLabel{$1} = $2;
    }
    elsif($line =~ /([^-^\s]*).*\s\-\>\s([^;^-]*)/){
	$md5ToDependencies{$2}{$1} = 1;
	$md5ToGenerated{$2} = 1; #provisionally add file to md5ToGenerated
    }
    elsif($line =~ /([^-^\s]*).*\s\[shape\=box\].*\<b\>(.*)\<\/b\>.*/){
	if(!(exists($md5ToLabel{$1}))){
	    $numFiles++;
	}
	$md5ToLabel{$1} = $2;
	$md5ToExecutable{$1} = 1;
    }
}

#remove files in md5ToGenerated that are also executables
foreach my $key1 (keys %md5ToGenerated){
    if(exists($md5ToExecutable{$key1})){
	delete $md5ToGenerated{$key1};	
    }
}

#the standard value of a file being lost, this assumes
#no factors beyond the number of disks available and the
#number of disks being eliminated
my $defaultDurabilityValue = ($numDisksLost / $numDisks); 

foreach my $key1 (keys %md5ToLabel){
    if(!(exists($md5ToGenerated{$key1})) && $selectiveReplication ne 'y' && $coLocation ne 'y'){
	$md5ToDurability{$key1} = $defaultDurabilityValue;
    }
    elsif(!(exists($md5ToGenerated{$key1})) && ($selectiveReplication ne 'y' || $coLocation ne 'y')){
	$md5ToDurability{$key1} = (($numDisksLost - 1) / $numDisks);
    }
    elsif(!(exists($md5ToGenerated{$key1}))){
	$md5ToDurability{$key1} = (($numDisksLost - 2) / $numDisks);
	if($md5ToDurability{$key1} < 0){
	    $md5ToDurability{$key1} = 0;
	}
    }
}

foreach my $key1 (keys %md5ToGenerated){
    $numGeneratedFiles++;
    if(!(exists($md5ToDurability{$key1}))){
	$md5ToDurability{$key1} = calculateProbabilities(\%md5ToLabel, \%md5ToGenerated, \%md5ToDependencies, 
							 \%md5ToDurability, \%md5ToExecutable, \%calculateProbabilitySeen, $key1, $defaultDurabilityValue);
    }
    %calculateProbabilitySeen = ();
#    print STDERR "\n\n";
}

print "Durability Report:\n";
foreach my $key1 (keys %md5ToDurability){
    if(exists($md5ToGenerated{$key1})){
	my $durability = 1 - $md5ToDurability{$key1};
	print "Generated File | $md5ToLabel{$key1} | $durability\n";
    }
}
print "Number of files total: $numFiles\n";
print "Number of generated files $numGeneratedFiles\n";
