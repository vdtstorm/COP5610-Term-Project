#!/usr/bin/perl

my $dir = $ARGV[0];

system("./depcheck.pl $dir/betterTable.txt $dir/deps.log");
