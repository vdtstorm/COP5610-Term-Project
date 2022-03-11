#!/usr/bin/perl

use Digest::MD5::File qw(file_md5_hex);

#Outputs number of failues. Currently keeps these in an array.
sub checkDependencies{
    my ($inFH, $logFH) = @_;
    my @failedPackages;
    my @failedFiles;
    my $currPackage;

    #reads from the betterTable format
    while($line = <$inFH>){
        #we only check for reads
	if(!($line =~ /read\|\//) && $line =~  /read\|([^\|]*)\|([^\|]*)\|([^\n]*)/){
	    #$1 = package
	    #$2 = file_path
	    #$3 = file_hash
	    $filePath = $2;
	    $fileHash = $3;
	    $currPackage = $1;
	    if($currPackage ne "-"){
		#if pacakge not found

		if(system("dpkg -s $currPackage") != 0){
		    #if file exists
		    if(system("stat $filePath") == 0){
			$localHash = file_md5_hex($filePath);
			#if hashes are equal
			if($localHash eq $fileHash){
			    print $logFH "success-pkgnotfound|$currPackage|$filePath|$fileHash|$localHash\n";
			}
			#else fail
			else{
			    push(@failedFiles,$currPackage);
			    print $logFH "failed-hashmismatch|$currPackage|$filePath|$fileHash|$localHash\n";
			}
		    }
		    #else file doesn't exist and fail
		    else{
			push(@failedPackages,$currPackage);
			print $logFH "failed-filenotfound|$currPackage|$filePath|$fileHash|$localHash\n";
		    }
		}

		#else package found
		else {
		    #if file exists
		    if(system("stat $filePath") == 0){
			$localHash = file_md5_hex($filePath);
			#if hashes match
			if($localHash eq $fileHash){
			    print $logFH "success-pkgfound|$currPackage|$filePath|$fileHash|$localHash\n";
			}
			#else hashes don't match and fail
			else{
			    push(@failedPackages,$currPackage);
			    print $logFH "failed-pkgfound-hashmismatch|$currPackage|$filePath|$fileHash|$localHash\n";
			}
		    }
		    #else file doesn't exist and fail
		    else{
			push(@failedPackages,$currPackage);
			print $logFH "failed-pkgfound-filenotfound|$currPackage|$filePath|$fileHash|$localHash\n";
		    }
		}
	    }
	    #else stat the file
	}
    }
    $totalFailed = @failedPackages;
    print $logFH "totalpkgfail|$totalFailed\n";
    print "Attempting reanimation of file!\n";
    system("perl reanimator.pl betterTable.txt");
    print "Reanimation finished\n";
    return $totalFailed;
}

### End subroutine checkDependencies ###

### Begin main ###

my $inFile;

$inFile = $ARGV[0];
$logFile = $ARGV[1];

open (my $inFH, $inFile);
open (my $logFH, ">$logFile");

checkDependencies($inFH, $logFH);
