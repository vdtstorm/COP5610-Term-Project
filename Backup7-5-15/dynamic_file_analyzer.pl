#!/usr/bin/perl

#takes table.txt as input
#table.txt corresponds to first output from the pipeline
#produced by tabler.pl

my $filename = $ARGV[0];
my $inFile;
my $line;
my $fullpath;

my %fileHash;

my @system_dirs = ["usr", "bin", "boot", "var", "media", "lib", "lib32", "lib64", "libx32", "proc", "root", "sys", "etc", "dev", "sbin", "opt", "cdrom"];
my @user_dirs = ["home", "tmp"];
my @media_files = ['JPG', 'JPEG', 'PNG', 'XML', 'HTML', 'MP3', 'MP4', 'AVI', 'MKV', 'TIFF'];
my @user_document = ["DOC", "DOCX", "TXT", "PPT", "ODP", "XLS", "ODT", "LOG", "TTF"];
my @generated_document = ['PS', 'PDF', 'GZ', 'TAR'];
my @user_code = ["C", "C++", "CPP", "RB", "PL", "PY", "LISP", "H", "H++", "HPP", "SH"];
my @generated_code = ['O', 'X', 'EXE', 'KO'];

#execve files
my $numExecveReinstallFiles = 0;
my $numExecveUserFiles = 0;
my $numExecveMediaFiles = 0;
my $numExecveUserDocumentFiles = 0;
my $numExecveGeneratedDocumentFiles = 0;
my $numExecveUserCodeFiles = 0;
my $numExecveGeneratedCodeFiles = 0;
my $numExecveMiscFiles = 0;

#read files
my $numReadReinstallFiles = 0;
my $numReadUserFiles = 0;
my $numReadMediaFiles = 0;
my $numReadUserDocumentFiles = 0;
my $numReadGeneratedDocumentFiles = 0;
my $numReadUserCodeFiles = 0;
my $numReadGeneratedCodeFiles = 0;
my $numReadMiscFiles = 0;

#write files
my $numWriteReinstallFiles = 0;
my $numWriteUserFiles = 0;
my $numWriteMediaFiles = 0;
my $numWriteUserDocumentFiles = 0;
my $numWriteGeneratedDocumentFiles = 0;
my $numWriteUserCodeFiles = 0;
my $numWriteGeneratedCodeFiles = 0;
my $numWriteMiscFiles = 0;

#mmap files
my $numMMAPReinstallFiles = 0;
my $numMMAPUserFiles = 0;
my $numMMAPMediaFiles = 0;
my $numMMAPUserDocumentFiles = 0;
my $numMMAPGeneratedDocumentFiles = 0;
my $numMMAPUserCodeFiles = 0;
my $numMMAPGeneratedCodeFiles = 0;
my $numMMAPMiscFiles = 0;

my $numReinstallFiles = 0;
my $numUserFiles = 0;
my $numMiscFiles = 0;
my $numTotalFiles = 0;

open($inFile, $filename);

while($line = <$inFile>){
    if($line =~ /execve\|([^\|]*)\|*/){
	$fullpath = $1;
	my @splitPath;
	my $splitPathSize;

	@splitPath = split("\/", $fullpath); 
	$splitPathSize = @splitPath;
	if($fileHash{$splitPath[$splitPathSize - 1]} != 1){
	    $fileHash{$splitPath[$splitPathSize - 1]} = 1;
	    if($splitPath[1] ~~ @system_dirs){
		++$numReinstallFiles;
	    }
	    elsif($splitPath[1] ~~ @user_dirs || $splitPathSize == 1){
		++$numUserFiles;
		my @splitFile;
		my $splitFileSize;

		@splitFile = split('\.', $splitPath[$splitPathSize - 1]);
		$splitFileSize = @splitFile;

		$splitFile[$splitFileSize - 1] = uc($splitFile[$splitFileSize - 1]);

		if($splitFile[$splitFileSize - 1] ~~ @media_files){
		    ++$numExecveMediaFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @user_document){
		    ++$numExecveUserDocumentFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @generated_document){
		    ++$numExecveGeneratedDocumentFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @user_code){
		    ++$numExecveUserCodeFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @generated_code){
		    ++$numExecveGeneratedCodeFiles;
		}
		else{
		    ++$numExecveMiscFiles;
		}
	    }
	    else{
		    ++$numMiscFiles;
		    ++$numExecveMiscFiles;
	    }
	}
    }
    elsif($line =~ /read\|([^\|]*)\|*/){
	$fullpath = $1;
	my @splitPath;
	my $splitPathSize;

	@splitPath = split("\/", $fullpath); 
	$splitPathSize = @splitPath;
	if($fileHash{$splitPath[$splitPathSize - 1]} != 1){
	    $fileHash{$splitPath[$splitPathSize - 1]} = 1;
	    if($splitPath[1] ~~ @system_dirs){
		++$numReinstallFiles;
	    }
	    elsif($splitPath[1] ~~ @user_dirs || $splitPathSize == 1){
		++$numUserFiles;
		my @splitFile;
		my $splitFileSize;

		@splitFile = split('\.', $splitPath[$splitPathSize - 1]);
		$splitFileSize = @splitFile;

		$splitFile[$splitFileSize - 1] = uc($splitFile[$splitFileSize - 1]);

		if($splitFile[$splitFileSize - 1] ~~ @media_files){
		    ++$numReadMediaFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @user_document){
		    ++$numReadUserDocumentFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @generated_document){
		    ++$numReadGeneratedDocumentFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @user_code){
		    ++$numReadUserCodeFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @generated_code){
		    ++$numReadGeneratedCodeFiles;
		    print "Generated code: $splitPath[$splitPathSize - 1]\n";
		}
		else{
		    ++$numReadMiscFiles;
		}
	    }
	    else{
		++$numMiscFiles;
		++$numReadMiscFiles;
	    }
	}
    }
    elsif($line =~ /write\|([^\|]*)\|*/){
	$fullpath = $1;
	my @splitPath;
	my $splitPathSize;

	@splitPath = split("\/", $fullpath); 
	$splitPathSize = @splitPath;
	if($fileHash{$splitPath[$splitPathSize - 1]} != 1){
	    $fileHash{$splitPath[$splitPathSize - 1]} = 1;
	    if($splitPath[1] ~~ @system_dirs){
		++$numReinstallFiles;
	    }
	    elsif($splitPath[1] ~~ @user_dirs || $splitPathSize == 1){
		++$numUserFiles;
		my @splitFile;
		my $splitFileSize;

		@splitFile = split('\.', $splitPath[$splitPathSize - 1]);
		$splitFileSize = @splitFile;

		$splitFile[$splitFileSize - 1] = uc($splitFile[$splitFileSize - 1]);

		if($splitFile[$splitFileSize - 1] ~~ @media_files){
		    ++$numWriteMediaFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @user_document){
		    ++$numWriteUserDocumentFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @generated_document){
		    ++$numWriteGeneratedDocumentFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @user_code){
		    ++$numWriteUserCodeFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @generated_code){
		    ++$numWriteGeneratedCodeFiles;
		}
		else{
		    ++$numWriteMiscFiles;
		}
	    }
	    else{
		++$numMiscFiles;
		++$numWriteMiscFiles;
	    }
	}
    }
    elsif($line =~ /mmap\|([^\|]*)\|*/){
	$fullpath = $1;
	my @splitPath;
	my $splitPathSize;

	@splitPath = split("\/", $fullpath); 
	$splitPathSize = @splitPath;
	if($fileHash{$splitPath[$splitPathSize - 1]} != 1){
	    $fileHash{$splitPath[$splitPathSize - 1]} = 1;
	    if($splitPath[1] ~~ @system_dirs){
		++$numReinstallFiles;
	    }
	    elsif($splitPath[1] ~~ @user_dirs || $splitPathSize == 1){
		++$numUserFiles;
		my @splitFile;
		my $splitFileSize;

		@splitFile = split('\.', $splitPath[$splitPathSize - 1]);
		$splitFileSize = @splitFile;

		$splitFile[$splitFileSize - 1] = uc($splitFile[$splitFileSize - 1]);

		if($splitFile[$splitFileSize - 1] ~~ @media_files){
		    ++$numMMAPMediaFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @user_document){
		    ++$numMMAPUserDocumentFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @generated_document){
		    ++$numMMAPGeneratedDocumentFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @user_code){
		    ++$numMMAPUserCodeFiles;
		}
		elsif($splitFile[$splitFileSize - 1] ~~ @generated_code){
		    ++$numMMAPGeneratedCodeFiles;
		}
		else{
		    ++$numMMAPMiscFiles;
		}
	    }
	    else{
		++$numMiscFiles;
		++$numMMAPMiscFiles;
	    }
	}
    }
}


$numTotalFiles = $numUserFiles + $numReinstallFiles + $numMiscFiles;

print "Total reinstallable files: $numReinstallFiles\n";
print "Total user files: $numUserFiles\n";
print "Total misc files: $numMiscFiles\n";
print "\n\n";
print "Media files in EXECVE calls: $numExecveMediaFiles\n";
print "User Document files in EXECVE calls: $numExecveUserDocumentFiles\n";
print "Generated Document files in EXECVE calls: $numExecveGeneratedDocumentFiles\n";
print "User Code files in EXECVE calls: $numExecveUserCodeFiles\n";
print "Generated Code files in EXECVE calls: $numExecveGeneratedCodeFiles\n";
print "Misc. files in EXECVE calls: $numExecveMiscFiles\n";
print "\n\n";
print "Media files in READ calls: $numReadMediaFiles\n";
print "User Document files in READ calls: $numReadUserDocumentFiles\n";
print "Generated Document files in READ calls: $numReadGeneratedDocumentFiles\n";
print "User Code files in READ calls: $numReadUserCodeFiles\n";
print "Generated Code files in READ calls: $numReadGeneratedCodeFiles\n";
print "Misc. files in READ calls: $numReadMiscFiles\n";
print "\n\n";
print "Media files in WRITE calls: $numWriteMediaFiles\n";
print "User Document files in WRITE calls: $numWriteUserDocumentFiles\n";
print "Generated Document files in WRITE calls: $numWriteGeneratedDocumentFiles\n";
print "User Code files in WRITE calls: $numWriteUserCodeFiles\n";
print "Generated Code files in WRITE calls: $numWriteGeneratedCodeFiles\n";
print "Misc. files in WRITE calls: $numWriteMiscFiles\n";
print "\n\n";
print "Media files in MMAP calls: $numMMAPMediaFiles\n";
print "User Document files in MMAP calls: $numMMAPUserDocumentFiles\n";
print "Generated Document files in MMAP calls: $numMMAPGeneratedDocumentFiles\n";
print "User Code files in MMAP calls: $numMMAPUserCodeFiles\n";
print "Generated Code files in MMAP calls: $numMMAPGeneratedCodeFiles\n";
print "Misc. files in MMAP calls: $numMMAPMiscFiles\n";

print "\n\n";
print "Percentage of system files " . $numReinstallFiles / $numTotalFiles * 100 . "\n";
print "Percentage of user files " . $numUserFiles / $numTotalFiles * 100 . "\n";
print "Percentage of misc. files: " . $numMiscFiles / $numTotalFiles * 100 . "\n";
print "-----------\n";
print "Percentage of media files: " . ($numExecveMediaFiles + $numReadMediaFiles + $numWriteMediaFiles + $numMMAPMediaFiles) / $numTotalFiles * 100 . "\n";
print "Percentage of User Document files: " . ($numExecveUserDocumentFiles + $numReadUserDocumentFiles + $numWriteUserDocumentFiles + 
					       $numMMAPUserDocumentFiles) / $numTotalFiles * 100 . "\n";
print "Percentage of Generated Document files: " . ($numExecveGeneratedDocumentFiles + $numReadGeneratedDocumentFiles + $numWriteGeneratedDocumentFiles + 
				       $numMMAPGeneratedDocumentFiles) / $numTotalFiles * 100 . "\n";
print "Percentage of User Code files: " . ($numExecveUserCodeFiles + $numReadUserCodeFiles + $numWriteUserCodeFiles + $numMMAPUserCodeFiles) / $numTotalFiles * 100 . "\n";
print "Percentage of Generated Code files: " . ($numExecveGeneratedCodeFiles + $numReadGeneratedCodeFiles + $numWriteGeneratedCodeFiles + 
				       $numMMAPGeneratedCodeFiles) / $numTotalFiles * 100 . "\n";
print "Percentage of misc user files: " . ($numExecveMiscFiles + $numReadMiscFiles + $numWriteMiscFiles + 
				       $numMMAPMiscFiles) / $numTotalFiles * 100 . "\n";

print "Total files: $numTotalFiles\n";
