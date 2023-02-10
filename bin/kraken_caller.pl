#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
#use Getopt::Long;
use Getopt::Std;
use File::Basename;

sub checkOptions {
    my %opts;
    getopts('hf:', \%opts);
    my ($help, $krakenFile);

    if($opts{h}) {
        $help = $opts{h};
        help();
    }

    if($opts{f}) {
        $krakenFile = $opts{f};
        if (-e $krakenFile) {
            print "File containing the Kraken report: $krakenFile\n";
        } else {
            print "The location given for the Kraken report is not in the correct format or doesn't exist. Make sure you provide the full path (/root/path/Kraken_report).\n";
	    print "ERROR,NA,NA,NA,NA,NA,NA,NA,NA\n";
            #help();
        }
    } else {
        print "The location of the Kraken report (including full path) has not been given.\n";
	print "ERROR,NA,NA,NA,NA,NA,NA,NA,NA\n";
        #help();
    }

    return ($help, $krakenFile);
}

sub help
{

die <<EOF

USAGE
kraken_caller.pl -f <alignment seq: fasta>

    -h   print usage
    -f   Kraken report (including full path)

EOF
}

my ($help, $krakenFile) = checkOptions( @ARGV);


###Start Doing Stuff###

my @kLine_arr;
open ( my $kFile, "<", $krakenFile ) or die "Could not open file '$krakenFile': $!";
while ( my $line = <$kFile> ) {
    chomp($line);
    #print "Line: $line\n";
    my @kLine = split(/\t/,$line);
    push(@kLine_arr,\@kLine);
}

my @unclass = shift(@kLine_arr);
my $maxCliff = -1000000000000;
my $bestID = "ERROR,NA,NA,NA,NA,NA,NA,NA,NA";
for (my $i = 0; $i < $#kLine_arr; $i++) {
    my $kraknID = $kLine_arr[$i][-1];
    chomp($kraknID);
    my $kraknRead1 = $kLine_arr[$i][0];
    my $kraknRead2 = $kLine_arr[$i+1][0];
    my $kraknReadC = $kLine_arr[$i][1];
    my $kraknReadT = $kLine_arr[$i][2];
    my $kraknCode = $kLine_arr[$i][3];
    my $kraknNCBI = $kLine_arr[$i][4];
    my $cliff_dif = $kLine_arr[$i][0] - $kLine_arr[$i+1][0];
    my $cliff_mult;
    if ($kraknRead2 > 0) {
	$cliff_mult = $kLine_arr[$i][0]/$kLine_arr[$i+1][0];
    } else {
	$cliff_mult = $kLine_arr[$i][0];
    }

    $kraknID=~s/^\s+//g; $kraknRead1=~s/^\s+//g; $kraknRead2=~s/^\s+//g; $kraknReadC=~s/^\s+//g; $kraknReadT=~s/^\s+//g; $kraknCode=~s/^\s+//g; $kraknNCBI=~s/^\s+//g; $unclass[0][0]=~s/^\s+//g;
    #print "$kraknRead1 | $kraknRead2 | $cliff_dif | $cliff_mult | $kraknID\n";

    if ($cliff_dif >= $maxCliff && $kraknRead1 >= 50 && $unclass[0][0] <= 5.00) {
	$maxCliff = $cliff_dif;
	$bestID = "$kraknID,$kraknRead1,$kraknRead2,$cliff_dif,$cliff_mult,$kraknReadC,$kraknReadT,$kraknCode,$kraknNCBI,$unclass[0][0],GOOD";
    } elsif ($cliff_dif >= $maxCliff && ($kraknRead1 < 50 || $unclass[0][0] > 5.00)) {
	$maxCliff = $cliff_dif;
	$bestID = "$kraknID,$kraknRead1,$kraknRead2,$cliff_dif,$cliff_mult,$kraknReadC,$kraknReadT,$kraknCode,$kraknNCBI,$unclass[0][0],FLAG";
    }
}

print "$bestID";
