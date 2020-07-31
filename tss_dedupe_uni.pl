#!/usr/bin/perl
# script to deduplicate and split TSS to bidirectional and unidirectional groups
# e.g. perl tss_dedupe_uni.pl TSS_hg38_gencode > TSS_hg38_gencode.uni.skipped
# (C) Yuri Kravatsky, lokapal@gmail.com
    use strict;

    my $ARGC=scalar @ARGV;

    if ($ARGC!=1) { die "Usage: tssdedupe TSSfilemask\n"; }
  
    my $tssfilemask=$ARGV[0];
    my $infile=$tssfilemask . ".bidi.sgr";
    my $unifile=$tssfilemask . ".uni.sgr";
    my $outfile=$tssfilemask . ".uni.dedupe";

    open (EP,$infile) || die "Can't open \"$infile\" for reading: $!";

    my %TSS;
    while (<EP>) {
         chomp;
         chomp;
         if (length($_)<5) { next; }
         if ($_=~ m/^(\s+)?#/) { next; }  # commented strings written in the same order
         my @arr=split(/\t/);
#chr1	1000097	-	HES4
         my $gene=$arr[3];
#         $gene=~s/\.\d+//g;
         $TSS{$gene}=1;
                  }
    close EP;

    open (OUTP,">$outfile")  || die "Can't create \"$outfile\": $!";

    open (EP,$unifile) || die "Can't open \"$unifile\" for reading: $!";
    while (<EP>) {
         chomp;
         chomp;
         if (length($_)<5) { next; }
         if ($_=~ m/^(\s+)?#/) { next; }  # commented strings written in the same order
         my @arr=split(/\t/);
#chr1	1000097	-	HES4
         my $gene=$arr[3];
#         $gene=~s/\.\d+//g;
         if (defined $TSS{$gene}) { print "$_\n"; 
                                    next;
                                  }
         print OUTP "$_\n";
                  }
    close EP;
    close OUTP;
