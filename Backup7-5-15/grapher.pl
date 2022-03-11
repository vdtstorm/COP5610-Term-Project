#!/usr/bin/perl
#use strict;
#use warnings;

#use Digest::MD5::File qw(file_md5_hex);

### Begin subroutine newProcess ###


sub buildGraph
{
    my ($inFile) = @_;
    my $package;
    my $md5Hash;
    my $pid;
    my %pidToProcessName;
    my $currentProcessMD5;
    my $currentProcessPath;
    my @argList;

    while($currLine = <$inFile>){

	#execve|filepath|hash|processID|arglist
	if($currLine =~ /execve\|([^\|]*)\|([^\|]*)\|(\d*)\|([^\n]*)\n/){
	    $currentProcessPath = $1;
#	    $currentProcessMD5 = "a$2_$3";
	    $currentProcessMD5 = "a$2";
	    $pid = $3;
	    @argList = split /\s/,$4;
	    print  "$currentProcessMD5;\n";
	    print  "$currentProcessMD5 [shape=box] [label=<<TABLE BORDER=\"0\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"4\"><TR><TD COLSPAN=\"1\"><b>$currentProcessPath</b></TD></TR>";
	    $i = 0;
	    foreach (@argList){
		print  "<TR>";
		print  "<TD align=\"left\">ARG $i: $_</TD>";
		print  "</TR>";
		++$i;
	    }
	    print  "</TABLE>>];\n";
	    if(exists($pidToProcessName{$pid})){
		print  "$pidToProcessName{$pid} -> $currentProcessMD5;\n";
	    }
	}

	#read|package|file_path|MD5\n
	elsif ($currLine =~ /read\|([^\|]*)\|([^\|]*)\|([^\n]*)\n/)
	{
	    # grab the regex
	    chomp($1);
	    $package = $1;
	    $filePath = $2;
	    chomp($3);
	    $md5Hash = $3;
	    $md5Hash = "a$md5Hash";
	    # write to the dot file
	    print  "$md5Hash -> $currentProcessMD5;\n";
	    if($package ne '-'){
		print  "$md5Hash [label=\"$package\"];\n";
	    }
	    else{
		print  "$md5Hash [label=\"$filePath\"];\n";
	    }
	}

 	# write|package|MD5\n
	elsif ($currLine =~  /write\|([^\|]*)\|([^\n]*)\n/)
	{
	    # grab the regex
	    chomp($1);
	    $package = $1;
	    chomp($2);
	    $md5Hash = $2;
	    $md5Hash = "a$md5Hash";
	    # write to the dot file
	    print  "$currentProcessMD5 -> $md5Hash;\n";
	    print  "$md5Hash [label=\"$package\"];\n";
	}

	# vfork|pid\n
	elsif ($currLine =~ /vfork\|([^\n]*)\n/)
	{
	    $pid = $1;
	    $pidToProcessName{$pid} = $currentProcessMD5;
	}
    }
}

### End subroutine newProcess ###

### Begin main ###

my $inFile;

my $inFileName = $ARGV[0];

open($inFile, "$inFileName");

print "digraph dependencies {\n";

buildGraph($inFile);

print  "}";

close($inFile);

### End main ###
