#!/usr/bin/perl

@files = <*>;

$semiColonCount;
$semiColonTotal;

$semiColonTotal = 0;

foreach $file (@files){
    if($file =~ /.*\.pl/){
	$semiColonCount = `fgrep -o \\; $file | wc -l`;
	$semiColonTotal += $semiColonCount;
	print "$file had $semiColonCount semi-colons\n";    
    }
}

print "Total semi-colon count is $semiColonTotal\n";
