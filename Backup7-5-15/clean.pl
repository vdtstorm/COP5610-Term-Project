#!/usr/bin/perl

my $dir = $ARGV[0];

system("rm $dir/table.txt");
system("rm $dir/betterTable.txt");
system("rm $dir/out*");
system("rm $dir/*~");
system("rm $dir/*.dot*");
system("rm $dir/dedupTable.txt");
system("rm $dir/firstCombineTable.txt");
system("rm $dir/matrix.txt");
