#!/usr/bin/perl
# script to convert EPD CAGE SGA files to TXT
# Source files location ftp://ccg.epfl.ch/mga/hg38/fantom5/
# (C) Yuri Kravatsky, lokapal@gmail.com
    use strict;

    my $ARGC=scalar @ARGV;

    if ($ARGC==0||$ARGC>1) { die "Usage: sgr_to_txt infile.sgr\n"; }

    my $infile=$ARGV[0];
    my $basename=substr($infile,0,rindex($infile,"."));

    my $outfile=$basename.".txt";
    open (EP,$infile) || die "Can't open \"$infile\" for reading: $!";
    open (OUTP,">$outfile") || die "Can't create \"$outfile\": $!";

    while (<EP>) {
         chomp;
         chomp;
         if (length($_)<5) { next; }
         if ($_=~ m/^(\s+)?#/) { print OUTP "$_\n"; next; }  # commented strings written in the same order
         my @arr=split(/\t/);
         my $name=$arr[0];
         $name=~ s/NC_0000/chr/g;
         $name=~s/chr0/chr/g;
         $name=~s/\.\d+//g;
         $name=~s/chr23/chrX/g;
         $name=~s/chr24/chrY/g;
         print OUTP "$name\t$arr[2]\t$arr[3]\t$arr[4]\n";
                  }
    close (EP);
    close (OUTP);
