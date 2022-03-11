#!/usr/bin/perl

my $outFile;
my $i;

for($i = 10; $i < 26; $i += 2){
    $outfile = "simTest" . $i . "\.out";
    system("./simTest.pl $i 3 10 1 y y session6-27_trace test/out.dot");
}

for($i = 10; $i < 26; $i += 2){
    $outfile = "simTest" . $i . "\.out";
    system("./simTest.pl $i 3 10 1 y y rashad_test test/rashad_test/out.dot");
}

for($i = 10; $i < 26; $i += 2){
    $outfile = "simTest" . $i . "\.out";
    system("./simTest.pl $i 3 10 1 y y pipeline_trace test/pipeline_trace/out.dot");
}

#for($i = 10; $i < 26; $i += 2){
#    $outfile = "simTest" . $i . "\.out";
#    system("./simTest.pl $i 3 10 1 y y mark_trace test/mark_test/out.dot");
#}

for($i = 3; $i < 10; $i += 1){
    $outfile = "simTest" . $i . "\.out";
    system("./simTest.pl 12 $i 10 1 y y session6-27_trace test/out.dot");
}

for($i = 3; $i < 10; $i += 1){
    $outfile = "simTest" . $i . "\.out";
    system("./simTest.pl 12 $i 10 1 y y rashad_test test/rashad_test/out.dot");
}

for($i = 3; $i < 10; $i += 1){
    $outfile = "simTest" . $i . "\.out";
    system("./simTest.pl 12 $i 10 1 y y pipeline_trace test/pipeline_trace/out.dot");
}

#for($i = 3; $i < 10; $i += 1){
#    $outfile = "simTest" . $i . "\.out";
#    system("./simTest.pl 12 $i 10 1 y y mark_trace test/mark_test/out.dot");
#}
