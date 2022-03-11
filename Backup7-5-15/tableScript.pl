#!/usr/bin/perl

# example usage $ ./tableScript.pl ./testdirectory/\*Log\*
# note you need to escape the wildcards as bash will expand them

@files = <$ARGV[0]>;

foreach $file (@files)
{
    print "Entry:\n";
    print $file . "\n";
    system("./tabler.pl $file");
}
