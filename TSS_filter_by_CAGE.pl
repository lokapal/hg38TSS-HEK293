#!/usr/bin/perl
# script to filter TSS genome tracks by CAGE data
# (C) Yuri Kravatsky, lokapal@gmail.com
    use strict;
    use List::Util qw(max);

    my $THRESHOLD=0.05; # all minor gene TSSs that are below 0.05 * maximal expression gene TSS are omitted
    my $EPSILON=1;      # if TSS has no CAGE record, find the nearest maximum CAGE record in the epsilon vicinity

    my $ARGC=scalar @ARGV;

    if ($ARGC!=2) { die "Usage: TSS_by_CAGE.pl cagebase.txt gencodebase.txt\n"; }

    my $cagename=$ARGV[0];
    my $gencname=$ARGV[1];
    my $basename=substr($gencname,0,rindex($gencname,"."));
    my $outfile=$basename.".filtered";

    open (EP,$cagename) || die "Can't open \"$cagename\" for reading: $!";

    my %CAGE;
    while (<EP>) {
         chomp;
         chomp;
         if (length($_)<5) { next; }
         if ($_=~ m/^(\s+)?#/) { next; }  # ignore comments
         my @arr=split('\s+');
######chr1    10535   -       1
         my $chr=$arr[0];
         my $currchr=uc($chr);
         if ($currchr =~ m /_|-|CHRG|CHRH|CHRM|CHRKI/) { next; } # Leave only canonical chromosomes
         my $coord=$arr[1];
         my $strand=$arr[2];
         my $expr=$arr[3];
         $CAGE{$chr}{$coord}{$strand}=$expr;
                 }
    close EP;


    open (EP,$gencname) || die "Can't open \"$gencname\" for reading: $!";
    my %genelist;
    while (<EP>) {
         chomp;
         chomp;
         if (length($_)<5) { next; }
         if ($_=~ m/^(\s+)?#/) { next; }  # ignore comments
         my @arr=split('\s+');
#chr1    91105   -       AL627309.3
         my $chr=$arr[0];
         my $currchr=uc($chr);
         if ($currchr =~ m /_|-|CHRG|CHRH|CHRM|CHRKI/) { next; } # Leave only canonical chromosomes
         my $coord=$arr[1];
         my $strand=$arr[2];
         my $gene=$arr[3];
        if (! defined $genelist{$gene}{records}) { $genelist{$gene}{records}=0; }
        my $currec=$genelist{$gene}{records};
#        $genelist{$gene}{$currec}{name}=$gene;
        $genelist{$gene}{$currec}{chr}=$chr;
        $genelist{$gene}{$currec}{coord}=$coord;
        $genelist{$gene}{$currec}{strand}=$strand;
#print "$gene\[$currec\]: $genelist{$gene}{$currec}{chr}\t$genelist{$gene}{$currec}{coord}\t$genelist{$gene}{$currec}{strand}\n";
        $genelist{$gene}{records}++;

                 }
    close EP;

    open (OUTP,">$outfile")  || die "Can't create \"$outfile\": $!";
    foreach my $gene (sort keys %genelist) {
        my $records=$genelist{$gene}{records};
#        print "$gene\t$records\n";
        my $maxexpr=-1000000;
        for (my $i=0;$i<$records;$i++) {
            my $chr    = $genelist{$gene}{$i}{chr};
            my $coord  = $genelist{$gene}{$i}{coord};
            my $strand = $genelist{$gene}{$i}{strand};
            my $expr;
            if (defined $CAGE{$chr}{$coord}{$strand}) {
                $expr=$CAGE{$chr}{$coord}{$strand};
                if ($expr>$maxexpr) { $maxexpr=$expr; }
                $genelist{$gene}{$i}{expr}=$expr;     }
              else { my @epsexpr;
                     for (my $j=($coord-$EPSILON);$j<=($coord+$EPSILON);$j++) {
                         if (defined $CAGE{$chr}{$j}{$strand}) { push @epsexpr, $CAGE{$chr}{$j}{$strand}; }
                                                                              }
                     my $localexpr;
                     $localexpr=max @epsexpr;
                     if (defined $localexpr) {
# print "$gene\t$i = $localexpr\n";
                          $genelist{$gene}{$i}{expr}=$localexpr; 
                                             }
                   }
                                       }
        my $thresh=$THRESHOLD*$maxexpr;
        for (my $i=0;$i<$records;$i++) {
            if (defined $genelist{$gene}{$i}{expr}) {
               my $expr   = $genelist{$gene}{$i}{expr};
               if ($expr<$thresh) { next; }
               my $chr    = $genelist{$gene}{$i}{chr};
               my $coord  = $genelist{$gene}{$i}{coord};
               my $strand = $genelist{$gene}{$i}{strand};
#               print "$gene\t$chr\t$coord\t$strand\t$expr\n";
               print OUTP "$chr\t$coord\t$strand\t$gene\t$expr\n";
                                                    }
                                       }
                                           }
    close OUTP;
