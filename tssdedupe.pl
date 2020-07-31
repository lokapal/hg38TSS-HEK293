#!/usr/bin/perl
# script to deduplicate, filter and merge TSS from the raw TSS database
# (C) Yuri Kravatsky, lokapal@gmail.com
    use strict;

    my $ARGC=scalar @ARGV;

    if ($ARGC!=1) { die "Usage: tssdedupe TSSfile.txt\n"; }

    my $infile=$ARGV[0];

    my $basename=substr($infile,0,rindex($infile,"."));

    my $outfile=$basename.".dedupe";
    open (EP,$infile) || die "Can't open \"$infile\" for reading: $!";
    open (OUTP,">$outfile") || die "Can't create \"$outfile\": $!";

    my %TSScoord;
    while (<EP>) {
         chomp;
         chomp;
         if (length($_)<5) { next; }
         if ($_=~ m/^(\s+)?#/) { print OUTP "$_\n"; next; }  # commented strings written in the same order
         my @arr=split(/\t/);
#NC_027893SS	77407	-	NOC2L_1
         my $chr=$arr[0];
         my $currchr=uc($chr);
         if ($currchr =~ m /_|-|CHRG|CHRH|CHRM|CHRKI/) { next; }
         my $coord=$arr[1];
         my $gene=$arr[3];
#         $gene=~s/\.\d+//g;
         my $chain=$arr[2];

         my $genename=$TSScoord{$chr}{$coord}{$chain};
         if (defined($genename) && $genename ne '') {  $gene = $genename . "-" . $gene; }
         $TSScoord{$chr}{$coord}{$chain}=$gene;
                  }
     close EP;


    foreach my $chr (keys %TSScoord) {   
       print "$chr:\n";
       foreach my $coord (keys %{$TSScoord{$chr}}) {
#           print "\t$coord\n";
           foreach my $chain (keys %{$TSScoord{$chr}{$coord}}) {
               my $genename=$TSScoord{$chr}{$coord}{$chain};
               print OUTP "$chr\t$coord\t$chain\t$genename\n";    }
                                                   }
                                        }
    close OUTP;
