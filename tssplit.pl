#!/usr/bin/perl
# this utility ignores chrM and other incomplete chromosomes with "-" or "_" in name

    use strict;
    use Fcntl qw(SEEK_SET SEEK_CUR SEEK_END);
    use File::Copy;

    my $ARGC=scalar @ARGV;

    if ($ARGC!=1) { die "Usage: tssplit tssfile.sgr\n"; }

    my $infile=$ARGV[0];

    open (INP,"$infile") || die "Can't read \"$infile\": $!";
    my $basename=substr($infile,0,rindex($infile,"."));
    my $outbidi=$basename.".bidi.sgr";
    my $outuni=$basename.".uni.sgr";
    my $outpairs=$basename.".pairs.bed";

    open (OUTB,">$outbidi")  || die "Can't create \"$outbidi\": $!";
    open (OUTU,">$outuni")   || die "Can't create \"$outuni\": $!";
    open (OUTP,">$outpairs") || die "Can't create \"$outpairs\": $!";

    my $i=0;
    my (@chr, @coord, @chain, @name, @uni);
    while (<INP>) {
       chomp;
       chomp;
       if (length($_) < 5) { next; }
       my @arr=split('\s+');
       my $currchr=$arr[0];
       my $currcoord=$arr[1];
       my $currchain=$arr[2];
       my $currname=$arr[3];
       if ($currchr =~ m /_|-/) { print "chr $currchr skipped\n"; next; }
       if (uc($currchr) =~ m /CHRM/) { print "chr $currchr skipped\n"; next; }
       my $sname = $currname =~ s/_\d+//r;
       $chr[$i]=$currchr;
       $coord[$i]=$currcoord;
       $chain[$i]=$currchain;
       $name[$i]=$sname;
       $uni[$i]=1;
       $i++;
                  }
    close (INP);

    my $totaltss=$i;
    print ("$totaltss TSS read\n");
    undef $i;

    my $prevperc=0;
    for (my $i=1;$i<$totaltss;$i++) {
       if ($chr[$i] ne $chr[$i-1]) { next; }
       if ($chain[$i] eq $chain[$i-1]) { next; }
       if ($chain[$i] ne "+") { next; }             # Divergent/Convergent BIDI switch
       if ($coord[$i]-$coord[$i-1]>1000) { next; }  # Distance between TSS to be bidirectional
       print OUTP "$chr[$i]\t$coord[$i-1]\t$coord[$i]\n"; # \t$chain[$i-1]\t$chain[$i]\n";
       $uni[$i]=0;
       $uni[$i-1]=0;                }

    for (my $i=0;$i<$totaltss;$i++) { 
       if ($uni[$i]==1) { print OUTU "$chr[$i]\t$coord[$i]\t$chain[$i]\t$name[$i]\n"; }
       if ($uni[$i]==0) { print OUTB "$chr[$i]\t$coord[$i]\t$chain[$i]\t$name[$i]\n"; }
                                    }
    close (OUTU);
    close (OUTB);
    close (OUTP);
    my $cmd="sort -k1,1 -k2,2n ". $outuni . " -o ". $outuni;
    `$cmd`;
    $cmd="uniq $outbidi > uni.tmp";
    `$cmd`;
    move("uni.tmp",$outbidi);
    $cmd="uniq $outuni > uni.tmp";
    `$cmd`;
    move("uni.tmp",$outuni);
    $cmd="wc -l $outuni";
    my @arr1=`$cmd`;
    $_=$arr1[0];
    @arr1=split(/\s+/,$_);
    my $uni_strings=$arr1[0];
    undef @arr1;

    $cmd="wc -l $outbidi";
    @arr1=`$cmd`;
    $_=$arr1[0];
    @arr1=split(/\s+/,$_);
    my $bidi_strings=$arr1[0];
    undef @arr1;

    my $cmd="sort -k1,1 -k2,2n ". $outpairs . " -o ". $outpairs;
    `$cmd`;

    my $sumstr=$bidi_strings+$uni_strings;
    print "Bidirectional TSS: $bidi_strings, unidirectional TSS: $uni_strings, TSS sum: $sumstr, totalTSS: $totaltss\n";
