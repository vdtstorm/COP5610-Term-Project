#!//usr/bin/perl

use Digest::MD5::File qw(file_md5_hex);
use Digest::MD5 qw(md5_hex);

my $inFileName = $ARGV[0];
my $inFile;
my $outFile;
my $line;

my $path;
my @splitPath;
my $splitPathSize = 0;
my $hashPath;
my $hashValue;

my $hashArgument;

my $command;
my $hashCommand;

my $readData;
my $hashReadData;

my $writeData;
my $hashWriteData;

my $execveArgs;
my @execveSplit;
my $execveSplitSize = 0;

my @attributeSplit;

my $passwordBool;
my $passwordString;

$outFileName = $inFileName . ".hashed";


open($inFile, $inFileName);
open($outFile, ">$outFileName");

$passwordString = md5_hex("password");

while($line = <$inFile>){
    if($line =~ /execve\(\"([^\"]*)\", \[\"([^\"]*)\", (.*)\).*/){
	#$1 = path
	#$2 = command
	#$3 execve args

	$path = $1;
	$command = $2;
	$execveArgs = $3;

	$hashPath = $path;
	@splitPath = split('\/', $path);
	$splitPathSize = @splitPath;
	for(my $i = 1; $i < $splitPathSize; ++$i){
	    $hashValue = $passwordString ^ $splitPath[$i];
	    $hashValue = md5_hex($hashValue);
	    $hashPath =~ s/$splitPath[$i]/$hashValue/;
	}
	$hashCommand = $passwordString ^ $command;
	$hashCommand = md5_hex($hashCommand);

	$line =~ s/$path/$hashPath/;
	$line =~ s/$command/$hashCommand/;

	@execveSplit = split(',', $execveArgs);	
	$execveSplitSize = @execveSplit;

	#i is set to 1 to ignore initial empty entry from split
	for(my $i = 1; $i < $execveSplitSize; ++$i){
	    if($execveSplit[$i] =~ /.*\=.*/){
		#eliminate quotations for now
		$execveSplit[$1] =~ s/\"//g;
		#grab attribute
		@attributeSplit = split('=', $execveSplit[$i], 2);
		#$hashArgument will hold on to the original attribute/value pair
		$hashArgument = $execveSplit[$i];
		#assume anything with a '/' is a pathname
		if($attributeSplit[1] =~ /.*\/.*/){
		    @splitPath = split('\/', $attributeSplit[1]);
		    $splitPathSize = @splitPath;
		    $hashPath = $attributeSplit[1]; 
		    for(my $j = 1; $j < $splitPathSize; ++$j){
			$hashValue = $passwordString ^ $splitPath[$j];
			$hashValue = md5_hex($hashValue);
			$hashPath =~ s/\Q$splitPath[$j]\E/$hashValue/g;
		    }
		    $hashArgument =~ s/\Q$attributeSplit[1]\E/$hashPath/g;
		    $line =~ s/\Q$execveSplit[$i]\E/$hashArgument/g;
		}
	    }
	}
	print $outFile $line;
    }
    elsif($line =~ /read\(.*, \"(.*)\"\.\.\., \d*\) \= \d*/){
	#$1 = read data
	$readData = $1;

	$hashReadData = $readData ^ $passwordString;
	$hashReadData = md5_hex($hashReadData);
	$line =~ s/\Q$readData\E/\Q$hashReadData\E/g;
	print $outFile $line;
    }
    elsif($line =~ /write\(.*, \"(.*)\".*/){
	#$1 = write data
	$writeData = $1;

	$hashWriteData = $writeData ^ $passwordString;
	$hashWriteData = md5_hex($writeData);
	$line =~ s/\Q$writeData\E/\Q$hashWriteData\E/g;
	print $outFile $line;
    }
    elsif($line =~ /access\(\"(.*)\", .*/){
	#$1 is the pathname
	$path = $1;

	@splitPath = split('\/', $path);
	$splitPathSize = @splitPath;
	$hashPath = $path;

	for(my $i = 1; $i < $splitPathSize; ++$i){
	    $hashValue = $passwordString ^ $splitPath[$i];
	    $hashValue = md5_hex($hashValue);
	    $hashPath =~ s/\Q$splitPath[$i]\E/$hashValue/;
	}
	if($splitPathSize == 1){
	    $hashValue = $path ^ $passwordString;
	    $hashPath = md5_hex($hashValue);
	}
	$line =~ s/\Q$path\E/$hashPath/g;

	print $outFile $line;

    }
    elsif($line =~ /stat\(\"(.*)\", .*/){
	#$1 is the pathname
	$path = $1;

	@splitPath = split('\/', $path);
	$splitPathSize = @splitPath;
	$hashPath = $path;

	for(my $i = 1; $i < $splitPathSize; ++$i){
	    $hashValue = $passwordString ^ $splitPath[$i];
	    $hashValue = md5_hex($hashValue);
	    $hashPath =~ s/\Q$splitPath[$i]\E/$hashValue/;
	}
	if($splitPathSize == 1){
	    $hashValue = $passwordString ^ $path;
	    $hashPath = md5_hex($hashValue);
	}
	$line =~ s/\Q$path\E/$hashPath/g;

	print $outFile $line;

    }
    elsif($line =~ /open\(\"(.*)\", .*/){
	#$1 is the pathname
	$path = $1;

	@splitPath = split('\/', $path);
	$splitPathSize = @splitPath;
	$hashPath = $path;

	for(my $i = 1; $i < $splitPathSize; ++$i){
	    $hashValue = $passwordString ^ $splitPath[$i];
	    $hashValue = md5_hex($hashValue);
	    $hashPath =~ s/\Q$splitPath[$i]\E/$hashValue/;
	}
	if($splitPathSize == 1){
	    $hashValue = $passwordString ^ $path;
	    $hashPath = md5_hex($hashValue);
	}
	$line =~ s/\Q$path\E/$hashPath/g;

	print $outFile $line;

    }
    else{
	print $outFile $line;
    }
}
