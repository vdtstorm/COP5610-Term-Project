#!/usr/bin/perl

my %cacheHash;

### Build Cache ###
sub buildCache{
    my $someLine;
    my $inCache;
    my $currentPackage;
    open($inCache, "cache.txt");

    while($someLine = <$inCache>){
	chomp($someLine);
	if($someLine =~ /([^\:]*)\:/){
	    $currentPackage = $1;
	}
	else{
	    $cacheHash{$someLine} = $currentPackage;
	}
    }
}

### Begin buildGraph ###
sub buildGraph{
    my ($inFH) = @_;
    my $currentProcess;
    my $currentProcessID;
    my $currentProcessHash;
    my $currentDepHash;
    my %readDedupHash;
    my %writeDedupHash;
    my %forkHash;
    my $filePath;
    my @packages;
    my $myPackage;
    my $dedupeMode = 0;


    while($line = <$inFH>){
	$myPackage = "";

	if($line =~ /execve\|([^\|]*)\|([^\|]*)\|(\d*)\|([^\n]*)\n/){
	    # $1 is the path
	    # $2 is the md5 hash
	    # $3 is the processID
	    # $4 is the arglist
	    $currentProcessID = $3;
	    $currentProcess = $1;
	    $currentProcessHash = $2;
	    print "\n\n$line";

	    #clear hash for each process
	    if($dedupeMode){
		%readDedupHash = ();
		%writeDedupHash = ();
	    }
	}
	elsif($line =~ /read\|([^\|]*)\|([^\n]*)/){
	    # $1 is the path
	    # $2 is the md5 hash
	    $filePath = $1;
	    $currentDepHash = $2;
	    
	    #resolve symbolic links as canonical links
	    #my $tempFilePath = `readlink -f $filePath`;
	    #clean-up newline chars
	    #$tempFilePath =~ s/\n//g;
	    
	    $tempFilePath = $filePath;
	    #$tempFilePath =~ s/\.\.\///g;
	    my $counter =()= $tempFilePath =~ /\//g;
	    $counter = $counter + 2; #check this; this ensures it goes to ""
	    $fullPath = $1;
	    #Temporary to shorten process time
	    $counter = 1;
	    if(exists($cacheHash{$filePath})){
		$myPackage = $cacheHash{$filePath};
	    }
	    else{
		if(!($filePath =~ /\/tmp\/.*/) && !($filePath =~ /\.\/.*/) && !($filePath =~ /\/home\/.*/)){
		    while(($myPackage eq "") && ($tempFilePath ne "") && $counter > 0){
			#future: check number of results from dpkg --search
			@packages = `dpkg --search $tempFilePath | cut -f1 -d":"`;
			$myPackage = fix_string($myPackages[0]);	    
			$tempFilePath =~ s/([^\/]*)\/(.*)/$2/;
			--$counter;
			$fullPath = 0;
		    }
		}
	    }
	    if(!($myPackage eq "") && !($myPackage eq "-")){
		print STDERR "Doing something1\n";
		open(my $cacheFile, ">>", "cache.txt");
		print $cacheFile "$filePath|$myPackage\n";
		$cacheHash{$filePath} = $myPackage;
	    }
	    elsif($myPackage eq ""){
		$myPackage = "-";
		$cacheHash{$filePath} = "-";
	    }
	    if($dedupeMode){
		if(!(exists($readDedupHash{$myPackage}))){
		    print "read|$myPackage|$filePath|$currentDepHash\n";
		    $readDedupHash{$myPackage} = 1;
		}
	    }
	    else{
		print "read|$myPackage|$filePath|$currentDepHash\n";
	    }
	}

	elsif($line =~ /write\|([^\|]*)\|([^\n]*)/){
	    # $1 is the path
	    # $2 is the md5 hash
	    if($dedupeMode){
		if(!(exists($writeDedupHash{$filePath}))){
		    print "$line";
		    $writeDedupHash{$filePath} = 1;
		}	    
	    }
	    else{
		print "$line";
	    }
	}
	elsif($line =~ /mmap\|([^\|]*)\|([^\n]*)/){
	    # $1 is the path
	    # $2 is the md5 hash
	    $filePath = $1;
	    $currentDepHash = $2;
	    
	    #resolve symbolic links as canonical links
	    #my $tempFilePath = `readlink -f $filePath`;
	    #clean-up newline chars
	    #$tempFilePath =~ s/\n//g;
	    
	    $tempFilePath = $filePath;
	    #$tempFilePath =~ s/\.\.\///g;
	    my $counter =()= $tempFilePath =~ /\//g;
	    $counter = $counter + 2; #check this; this ensures it goes to ""
	    $fullPath = $1;
	    #temporary to shorten process time
	    $counter = 1;
	    if(exists($cacheHash{$filePath})){
		$myPackage = $cacheHash{$filePath};
	    }
	    else{
		if(!($filePath =~ /\/tmp\/.*/) && !($filePath =~ /\.\/.*/) && !($filePath =~ /\/home\/.*/)){
		    while(($myPackage eq "") && ($tempFilePath ne "") && $counter > 0){
			#future: check number of results from dpkg --search
			@packages = `dpkg --search $tempFilePath | cut -f1 -d":"`;
			$myPackage = fix_string($myPackages[0]);	    
			$tempFilePath =~ s/([^\/]*)\/(.*)/$2/;
			--$counter;
			$fullPath = 0;
		    }
		}
	    }
	    if(!($myPackage eq "")){
		print STDERR "Doing something1\n";
		open(my $cacheFile, ">>", "cache.txt");
		print $cacheFile "$filePath|$myPackage\n";
		$cacheHash{$filePath} = $myPackage;
	    }
	    elsif($myPackage eq ""){
		$myPackage = "-";
		$cacheHash{$filePath} = "-";
	    }
	    if($dedupeMode){
		if(!(exists($readDedupHash{$myPackage}))){
		    print "mmap|$myPackage|$filePath|$currentDepHash\n";
		    $readDedupHash{$myPackage} = 1;
		}
	    }
	    else{
		print "mmap|$myPackage|$filePath|$currentDepHash\n";
	    }
	}
	elsif($line =~ /vfork\|([^\n]*)/){
	    print "$line";
	}
	else{
	    print "$line";
	}
    }
}
### Begin fix_string ###
#Removes whitespace and dashes
sub fix_string($){

    my $string = shift;
    $string =~ s/^\s+//g;
    $string =~ s/\s+$//g;
    $string =~ s/\n//g;
    #$string =~ s/-/_/g;
    #$string =~ s/\./_/g;
    return $string;
}

### Begin main ###

my $filename;

$filename = $ARGV[0];

open(my $inFH, $filename);

print STDERR "Building cache\n";

buildCache();

print STDERR "Finished building cache\n";

buildGraph($inFH);

undef %cacheHash;
