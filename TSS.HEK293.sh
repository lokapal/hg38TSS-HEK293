#!/bin/sh
# script to obtain TSS genome tracks for GRCh38/hg38 genome
# (C) Yuri Kravatsky, lokapal@gmail.com
# input from EPD and Gencode databases
# output files: hg38.
# Requirements: Perl, wget, gzip, GNU tools: sh/bash, sort, rm, mv, rename
# Results are in the following files:
# TSS_hg38_epd.sgr : H.sapiens GRCh38/hg38 complete TSS list in SGR format, obtained from EPD database, deduplicated and filtered by CAGE database
# TSS_hg38_epd.bidi.sgr: hg38 EPD bidirectional TSS in SGR format
# TSS_hg38_epd.pairs.bed: hg38 EPD bidirectional TSS joined in pairs, in BED format
# TSS_hg38_epd.uni.sgr: hg38 EPD unidirectional TSS in SGR format
# TSS_hg38_gencode.sgr : H.sapiens GRCh38/hg38 complete TSS list in SGR format, obtained from Gencode database, deduplicated and filtered by CAGE database
# TSS_hg38_gencode.bidi.sgr: hg38 Gencode bidirectional TSS in SGR format
# TSS_hg38_gencode.pairs.bed: hg38 Gencode bidirectional TSS joined in pairs, in BED format
# TSS_hg38_gencode.uni.sgr: hg38 Gencode unidirectional TSS in SGR format
#
# We will get CAGE HEK293 expression data from EPD ftp site
wget ftp://ccg.epfl.ch/mga/hg38/fantom5/embryonicKidneyCellLine_aHEK293_fSLAMUntreated.CNhs11046.10450-106F9.hg38.nobarcode.sga.gz -O HEK293_cage.sga.gz
gzip -d HEK293_cage.sga.gz
perl sga_to_txt.pl HEK293_cage.sga
rm HEK293_cage.sga
# process Gencode
perl TSS_filter_by_CAGE.pl HEK293_cage.txt TSS_hg38_biomart.full
sort -k1,1V -k2,2n TSS_hg38_biomart.filtered -o TSS_hg38_biomart.filtered
perl tssdedupe.pl TSS_hg38_biomart.filtered
sort -k1,1 -k2,2n TSS_hg38_biomart.dedupe -o TSS_hg38_gencode.sgr
rm TSS_hg38_biomart.dedupe
perl tssplit.pl TSS_hg38_gencode.sgr
perl tss_dedupe_uni.pl TSS_hg38_gencode > TSS_hg38_gencode.uni.skipped
# process EPD
# get the latest H.sapiens TSS EPD database
wget ftp://ccg.epfl.ch/epdnew/H_sapiens/current/Hs_EPDnew.sga -O TSS_hg38_epd_full.sga
perl sga_to_tss.pl TSS_hg38_epd_full.sga
rm TSS_hg38_epd_full.sga
mv TSS_hg38_epd_full.txt TSS_hg38_epd.full
perl TSS_filter_by_CAGE.pl HEK293_cage.txt TSS_hg38_epd.full 
sort -k1,1V -k2,2n TSS_hg38_epd.filtered -o TSS_hg38_epd.filtered
perl tssdedupe.pl TSS_hg38_epd.filtered
sort -k1,1 -k2,2n TSS_hg38_epd.dedupe -o TSS_hg38_epd.sgr
rm TSS_hg38_epd.dedupe
perl tssplit.pl TSS_hg38_epd.sgr
perl tss_dedupe_uni.pl TSS_hg38_epd > TSS_hg38_epd.uni.skipped
rename -f 's/\.dedupe/\.sgr/g' *.dedupe
gzip -f HEK293_cage.txt
rm -f *.filtered *.skipped
