#!/usr/bin/perl

#!/usr/bin/perl

### Begin main ###
my %lineDedupHash;

my $inFile;
my $line;

my $inFileName = $ARGV[0];
my $outFileName = $ARGV[1];

open($inFile, "$inFileName");

while($line = <$inFile>){
    if(!(exists($lineDedupHash{$line}))){
	$lineDedupHash{$line} = 1;
	print $line;
    }
}
