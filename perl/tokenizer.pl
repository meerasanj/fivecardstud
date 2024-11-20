# This file was from an in-class assignment. Please ignore it for the grading of perl.

#!/usr/bin/perl
use strict;
use warnings;

# Grab the name of the file from the command line, exit if no name given
my $filename = $ARGV[0] or die "Need to get file name on the  command line\n";

open(DATA, "<$filename") or die "Couldn't open file $filename, $!";

my @all_lines = <DATA>;

foreach my $line (@all_lines) {
   my @tokens = split(',', $line);
   chomp(@tokens);  
   foreach my $token (@tokens) {
     print "$token\n";
   }
}
