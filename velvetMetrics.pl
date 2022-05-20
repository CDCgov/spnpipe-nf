#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
#use Getopt::Long;
use Getopt::Std;
use File::Basename;

###MODULE LOAD###
#module load ncbi-blast+/2.2.30
#module load BEDTools/2.17.0

sub checkOptions {
    my %opts;
    getopts('hi:', \%opts);
    my ($help, $input);

    if($opts{h}) {
        $help = $opts{h};
        help();
    }

    if($opts{i}) {
        $input = $opts{i};
        if (-e $input) {
            print "Path to the Velvet Logfile: $input\n";
        } else {
            print "Path to the Velvet Logfile is not in the correct format or doesn't exist.\n";
            print "Make sure you provide the full path (/root/path/file).\n";
            help();
        }
    } else {
        print "Path to the Velvet Logfile (including full path) has not been given.\n";
        help();
    }

    return ($help, $input);
}

sub help
{

die <<EOF

USAGE
Velvet_Metrics_Extractr.pl -i <log paths file: txt> -n <output name prefix: string>

    -h   print usage
    -i   Path to the Velvet Logfile (including full path)

EOF
}

my ($help, $input) = checkOptions( @ARGV);

###Subroutines###

###Start Doing Stuff###
my $final_out = "velvet_qual_metrics.txt";
open ( my $finalOUT, ">>", $final_out ) or die "Could not open file $final_out: $!";
#print $finalOUT "Sample,Contig_Num,N50,Longest_Contig,Total_Bases\n";
open ( my $l_path, "<", $input ) or die "Could not open file '$input': $!";
#while ( my $line = <$l_path> ) {
#    chomp($line);
#    my $finName = `echo -n1 "$line" | cut -d"/" -f14`;
#    chomp($finName);
    #print "line is: $line | sample is: $finName\n";
#    my @metric_out;
#    my $final_met = `cat $line | grep -A23 "Final"`;
    #my @final_arr = split /\n/, $final_met;

    #my @n_contig = split /: /, $final_arr[14];
    #my @n50 = split /: /, $final_arr[15];
    #my @l_contig = split /: /, $final_arr[16];
    #my @b_contig = split /: /, $final_arr[17];

    #print "$final_arr[14],$final_arr[15],$final_arr[16],$final_arr[17]\n";
    #print "$finName\t$n_contig[1]\t$n50[1]\t$l_contig[1]\t$b_contig[1]\n";
    #print $finalOUT "$finName,$n_contig[1],$n50[1],$l_contig[1],$b_contig[1]\n";
#}

my $final_met = `cat $input | grep -A23 "Final"`;
print "final_met: $final_met\n";
my @metric_out;
my @final_arr = split /\n/, $final_met;

my @n_contig = split /: /, $final_arr[14];
my @n50 = split /: /, $final_arr[15];
my @l_contig = split /: /, $final_arr[16];
my @b_contig = split /: /, $final_arr[17];

print "$n_contig[1]\t$n50[1]\t$l_contig[1]\t$b_contig[1]\n";
print $finalOUT "$n_contig[1],$n50[1],$l_contig[1],$b_contig[1]\n";



