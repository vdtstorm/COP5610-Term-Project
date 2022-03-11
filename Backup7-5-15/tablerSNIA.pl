#!/usr/bin/perl

use Digest::MD5::File qw(file_md5_hex);
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep
  	          clock_gettime clock_getres clock_nanosleep clock
                  stat );

sub buildCache{
    my (%fileToMd5, $md5File) = @_;

    my $md5Line;

    while($md5Line = <$md5File>){
	if($md5Line = /(.*)\:(.*)/){
	    $fileToMd5{$1} = $2;
	}
    }
}

sub newProcess{
##805,514
    my ($inFH, $processID) = @_;
    my $filePath;
    my $fileMD5;
    my %lineDeduper;
    my %fdToFilepath;
    my %fileToMD5;
    my %depthHash;
    my $argList;
    my $fd;
    my $writeString;
    my $lines = 0;
    my $percentage;
    my $originalTime = [gettimeofday];
    my $seconds;
    my $intervalLines = 0;
    my $md5File;
    my $currentDepth = 0;
    my $firstFlag = 0;

    my $bytesRead;
    my $bytesWritten;
    my $bytesMmaped;

#    open($md5File, ">md5File");

#    buildCache(%fileToMD5, $md5File);

    while($line = <$inFH>){
	$lines++;
	$intervalLines++;
	$seconds = tv_interval($originalTime, [gettimeofday]);
	if($seconds > 300){
	    $percentage = $lines/4519200 * 100;
	    print STDERR "Percentage complete: $percentage\n";
	    print STDERR "Lines processed: $lines\n";
	    print STDERR "Lines processed this interval: $intervalLines\n";
	    my $temp = keys %fdToFilepath;
	    print STDERR "Number of FDs in hash: $temp\n";
	    $originalTime = [gettimeofday];
	    $intervalLines = 0;
	}
	#won't ever be entered
        if($line =~ /execve.*\"(.*)\".*\[(.*)\]\,\s\[\".*PWD=([^\"]*)(.*)=\s(.*)\s/){
            # $1 is the path
	    # $2 is the argument list
            # $4 is the fd
	    $fd = $5;
	    $argList = $2;
	    $fd =~ s/\s//g;
	    $fd =~ s/\n//g;
	    $PWD = $3;
	    if($fd != -1){
		$filePath = $1;
		$cleanFilePath = $filePath;
		#try to resolve symbolic links as canonical links
		 if($filePath ne ""){
		     $cleanFilePath = `readlink -f $filePath > /dev/null`;
		 }
		if($cleanFilePath ne "")
		{
		    #clean-up newline chars
		    $cleanFilePath =~ s/\n//g;
		    $filePath = $cleanFilePath;
		}

		$argList =~ s/\"//g;
		$argList =~ s/\,//g;

		

		$fileMD5 = file_md5_hex($filePath);		
		if(!(exists $lineDeduper{"execve|$filePath|$fileMD5|$processID|$argList\n"})){
		    print "execve|$filePath|$fileMD5|$processID|$argList\n";
		    print "regen|$argList\n";
		    print "PWD|$PWD\n";
		    $lineDeduper{"execve|$filePath|$fileMD5|$processID|$argList\n"} = 1;
		}
	    }
	}
	elsif($line =~ /setpgid\((.*),\s([^\)]*)\).*/){
	    if($1 == $processID){
		print "setpgid|$2\n";
	    }
	}
        elsif($line =~ /\[\d*\]; \[\d*\]; \[entry\]; \[open\]; \[([^\]]*)\]; \[\d*\]; \[([^\]]*)\]; .* \[-?(\d*)\];/){
            #$1 is the filepath
            #$2 is the mode
            #$3 is the descriptor
	    $fd = $3;
	    $fd =~ s/\s//g;
	    $fd =~ s/\n//g;
	    $filePath = $1;
	    $cleanFilePath = $filePath;

	    if($cleanFilePath ne "")
	    {
		#clean-up newline chars
		$cleanFilePath =~ s/\n//g;
		$filePath = $cleanFilePath;
	    }

	    if($fd != -1){
		$fd =~ s/\s//g;
		$fdToFilepath{$fd} = $filePath;
	    }
	}
	elsif($line =~ /\[\d*\]; \[\d*\]; \[entry\]; \[read\]; \[(\d*)\]; .* \[(\d*)\];/){
	    #$1 is the fd
            #$2 is bytes read
	    $fd = $1;
	    $bytesRead  = $2;
	    $fd =~ s/\s//g;
	    $fd =~ s/\n//g;
	    if(!(exists($fileToMD5{$fdToFilepath{$fd}}))){
		if(-f $fdToFilepath{$fd}){
		    $fileMD5 = file_md5_hex($fdToFilepath{$fd});
		}
		else{
		    $fileMD5 = md5_hex($fdToFilepath{$fd});
		}
		$fileToMD5{$fdToFilepath{$fd}} = $fileMD5;
	    }
	    else{
		$fileMD5 = $fileToMD5{$fdToFilepath{$fd}};
	    }
	    if(exists($depthHash{$fileMD5}) && $currentDepth < $depthHash{$fileMD5}){
		$currentDepth = $depthHash{$fileMD5};
	    }
	    if(!(exists $lineDeduper{"read|$fdToFilepath{$fd}|$fileMD5"})){
		if($fd eq 0){
		    print "read|STDIN|$fileMD5\n";		    
		}
		elsif($fd eq 1){
		    print "read|STDOUT|$fileMD5\n";		    
		}
		elsif($fd eq 2){
		    print "read|STDERR|$fileMD5\n";		    
		}
		else{
		    print "read|$fdToFilepath{$fd}|$fileMD5|$bytesRead\n";
		}
		$lineDeduper{"read|$fdToFilepath{$fd}|$fileMD5"} = 1;
	    }
	}
	elsif($line =~ /\[\d*\]; \[\d*\]; \[entry\]; \[write\]; \[(\d*)\]; (.*) \[(\d*)\];/){
	    #$1 is the fd
	    #$2 is the string being written
	    #$3 is the number of bytes written
	    $fd = $1;
	    $writeString = $2;
	    $bytesWritten = $3;
	    $fd =~ s/\s//g;
	    $fd =~ s/\n//g;
	    if(!(exists($fileToMD5{$fdToFilepath{$fd}}))){
		if(-f $fdToFilepath{$fd}){
		    $fileMD5 = file_md5_hex($fdToFilepath{$fd});
		}
		else{
		    $fileMD5 = md5_hex($fdToFilepath{$fd});
		}
		$fileToMD5{$fdToFilepath{$fd}} = $fileMD5;
		$depthHash{$fileMD5} = $currentDepth + 1;
	    }
	    else{
		$fileMD5 = $fileToMD5{$fdToFilepath{$fd}};
	    }
	    if(!(exists $lineDeduper{"write|$fdToFilepath{$fd}|$fileMD5"})){
		if($fd eq 0){
		    print "write|STDIN|$fileMD5\n";		    
		}
		elsif($fd eq 1){
		    print "write|STDOUT|$fileMD5\n";		    
		}
		elsif($fd eq 2){
		    print "write|STDERR|$fileMD5\n";		    
		}
		else{
		    print "write|$fdToFilepath{$fd}|$fileMD5|$bytesWritten\n";
		    if($fdToFilepath{$fd} =~ /.*downloads\.json.*/){
			print "download|$writeString\n"
		    }
		}
		$lineDeduper{"write|$fdToFilepath{$fd}|$fileMD5"} = 1;
	    }
	}
	#currently not used
        elsif($line =~ /mmap\(([^,]*)\,([^,]*)\,([^,]*)\,([^,]*)\,([^,]*)\,/){
	    #$5 is the fd

	    $fd = $5;
	    $fd =~ s/^\s+//;

	    if($fd != -1){
		if(-e $fdToFilepath{$fd}){
		    $fileMD5 = file_md5_hex($fdToFilepath{$fd});
		}
		else{
		    $fileMD5 = md5_hex($fdToFilepath{$fd})
		}

		if(!(exists $lineDeduper{"mmap|$fdToFilepath{$fd}|$fileMD5"})){
		    print "mmap|$fdToFilepath{$fd}|$fileMD5\n";
		    $lineDeduper{"mmap|$fdToFilepath{$fd}|$fileMD5"} = 1;
		}
	    }
	}
 	#currently not used
        elsif($line =~ /vfork(.*)=\s(.*)\n/){
	    #$2 is the forked PID
	    print "vfork|$2\n";
	}
 	#currently not used
	elsif($line =~ /clone\((.*)\)\s=\s(.*)\n/){
	    print "clone|$2\n";
	}
    }
    print "depth|$currentDepth\n\n";
}

### Begin main ###

my $filename = $ARGV[0];
my $processID = 0;

open(my $inFH, $filename);

#$filename =~ s/(.*)\.(.*)/$1/;
#$processID = $2;
#chomp($inFH);

newProcess($inFH, $processID);

print "\n\n";
