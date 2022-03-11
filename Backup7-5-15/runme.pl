#!/usr/bin/perl

# /bin/bash

#./tableScript > table.txt
#./fileToPackage.pl table.txt > betterTable.txt
#./packageDeduper.pl betterTable.txt > dedupTable.txt
#./grapher.pl dedupTable.txt > out.dot
#dot -Tpng out.dot > out.png

my $dir = $ARGV[0];
my $file = $ARGV[1];
my $fileRegex = $dir . "/\\\*" . $file ."\\\*";

system("./tableScript.pl $fileRegex > $dir/table.txt");
system("./verify.pl $fileRegex");
#system("./groupProcessIDs.pl $dir/table.txt > $dir/secondTable.txt");
#system("./fileToPackage.pl $dir/secondTable.txt > $dir/betterTable.txt");
system("./fileToPackage.pl $dir/table.txt > $dir/betterTable.txt");
system("./packageDeduper.pl $dir/betterTable.txt > $dir/dedupTable.txt");
system("./combineReadsWrites.pl $dir/dedupTable.txt > $dir/firstCombineTable.txt");
system("./addDepth.pl $dir/firstCombineTable.txt > $dir/depthTable.txt");
system("./grapher.pl $dir/depthTable.txt > $dir/first.dot");
system("./pruneDotFile.pl $dir/first.dot > $dir/out.dot");
system("dot -Tpng $dir/out.dot > $dir/out.png");
#system("./matrixBuilder.pl $dir/firstCombineTable.txt > $dir/matrix.txt");


#system("./obfuscater.pl $fileRegex");

