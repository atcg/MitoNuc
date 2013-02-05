#!/usr/bin/perl

#This script does a few things (uses example taxon ID of 8948 below):
#1. queries entrez nucleotide database for: txID8948[Organism:exp] NOT "complete genome" AND gene_in_mitochondrion[PROP]";
#2. Pulls all the results from query in #1 500 at a time (which is the max) and writes them to a temporary file
#3. Uses a regex to extract the GI number from the temporary file in #2, and writes the GIs to a file called data/mitoGIs_8948.txt
#4. Deletes the temporary file from #2 above
##SKIP THIS STEP FOR NOW-->5. Creates a blast database in the current directory called "Mitos_exceptGenomes_8948", then moves it to data/db/Mitos_exceptGenomes_8948
##SKIP THIS STEP FOR NOW-->#   a. This database is a subset of the nt database (or another, more-inclusive, database), using the GIs from #3 above to subset
#
#6. queries entrez nucleotide database for: txID8948[Organism:exp] AND "complete genome" AND gene_in_mitochondrion[PROP]";
#7. Pulls all the results from query in #6 500 at a time (which is the max) and writes them to a temporary file
#8. Uses a regex to extract the GI number from the temporary file in #7, and writes the GIs to a file called data/mitoGIs_fullmtgenomes_8948.txt
#9. Deletes the temporary file from #7 above
##SKIP THIS STEP FOR NOW-->#10. Creates a blast database in the current directory called "fullmtgenomes_8948", then moves it to data/db/Mitos_exceptGenomes_8948


use strict;
use warnings;
use LWP::Simple;
use Getopt::Long;
use File::Copy;

unless(-d "data") {
    mkdir "data" or die "can't mkdir data: $!";
}

unless(-d "data/db") {
    mkdir "data/db" or die "can't mkdir data/db: $!";
}


my $taxID;
GetOptions("taxid=i" => \$taxID);
if ($taxID eq '') {
    print "must supply taxon ID to subset_mito_db.pl\n";
}

my $queryOrg = "txid" . $taxID . "[Organism:exp]";
print "Higher Level Taxon ID for creating mito GI subset: $taxID.\n";

my $query = "$queryOrg NOT \"complete genome\" AND gene_in_mitochondrion[PROP]";
my $query2 = "$queryOrg AND \"complete genome\" AND gene_in_mitochondrion[PROP]";

#assemble the esearch URL
my $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
my $url = $base . "esearch.fcgi?db=nucleotide&term=$query&usehistory=y";

#post the esearch URL
my $output = get($url);

#parse WebEnv, QueryKey and Count (# records retrieved)
my $web = $1 if ($output =~ /<WebEnv>(\S+)<\/WebEnv>/);
my $key = $1 if ($output =~ /<QueryKey>(\d+)<\/QueryKey>/);
my $count = $1 if ($output =~ /<Count>(\d+)<\/Count>/);


#open output file for writing (temporary file)
open(my $MITOGIPULL, ">", "data/mitoEUTILpull.txt") || die "Can't open file: $!\n";
        
#retrieve data in batches of 500
my $retmax = 500;
for (my $retstart = 0; $retstart < $count; $retstart += $retmax) {
    my $efetch_url = $base ."efetch.fcgi?db=nucleotide&WebEnv=$web";
    $efetch_url .= "&query_key=$key&retstart=$retstart";
    $efetch_url .= "&retmax=$retmax&rettype=seqid&retmode=text";
    my $efetch_out = get($efetch_url);
    print $MITOGIPULL "$efetch_out";
    if ($retstart % 10000 == 0){
        print "$retstart GIs of $count total processed.\n"
    }
}
close $MITOGIPULL;

#Parse the resulting file to get just the GI numbers of the accessions, one on each line
open(my $MITOSEQIDS, "<", "data/mitoEUTILpull.txt") || die "Can't open file: $!\n";
open(my $MITOGIOUT, ">", "data/mitoGIs_nogenomes_$taxID.txt") || die "Can't open file: $!\n";

while(my $line = <$MITOSEQIDS>){
    if ($line =~ /Seq-id\s::=\sgi\s(\d+)/) {
        print $MITOGIOUT "$1\n";
    }
}

close $MITOSEQIDS;
close $MITOGIOUT;

unlink "data/mitoEUTILpull.txt"; #deletes temporary file


##Create the actual vertmito blast database
#system("blastdb_aliastool -db nt -dbtype nucl -gilist data/mitoGIs_nogenomes_$taxID.txt -out Mitos_exceptGenomes_$taxID -title Mitos_exceptGenomes_$taxID"); #Mac testing version
##system('blastdb_aliastool -db allNuc -dbtype nucl -gilist data/mitoGIs_$taxID.txt -out /Volumes/Spinster/data/blastdb/vertMito -title vertMito'); #Linux production version
#copy("Mitos_exceptGenomes_$taxID.n.gil", "data/db/Mitos_exceptGenomes_$taxID.n.gil") or die "File cannot be copied: $!\n";
#copy("Mitos_exceptGenomes_$taxID.nal", "data/db/Mitos_exceptGenomes_$taxID.nal") or die "File cannot be copied: $!\n";
#unlink "Mitos_exceptGenomes_$taxID.n.gil";
#unlink "Mitos_exceptGenomes_$taxID.nal";




#*******************************************************************************#
#*******************************************************************************#
#*******************************************************************************#
#*******************************************************************************#
#*******************************************************************************#
#*******************************************************************************#
#*******************************************************************************#
#*******************************************************************************#
#*******************************************************************************#




#Below is the same as above, except for dealing with mitochondrial full genome sequences
my $url2 = $base . "esearch.fcgi?db=nucleotide&term=$query2&usehistory=y";

#post the esearch URL
my $output2 = get($url2);

#parse WebEnv, QueryKey and Count (# records retrieved)
my $web2 = $1 if ($output2 =~ /<WebEnv>(\S+)<\/WebEnv>/);
my $key2 = $1 if ($output2 =~ /<QueryKey>(\d+)<\/QueryKey>/);
my $count2 = $1 if ($output2 =~ /<Count>(\d+)<\/Count>/);


#open output file for writing (temporary file)
open(my $MITOGIPULL2, ">", "data/mitoEUTILpull_fullmtgenome.txt") || die "Can't open file: $!\n";
        
#retrieve data in batches of 500
my $retmax2 = 500;
for (my $retstart2 = 0; $retstart2 < $count2; $retstart2 += $retmax2) {
    my $efetch_url2 = $base ."efetch.fcgi?db=nucleotide&WebEnv=$web2";
    $efetch_url2 .= "&query_key=$key2&retstart=$retstart2";
    $efetch_url2 .= "&retmax=$retmax2&rettype=seqid&retmode=text";
    my $efetch_out2 = get($efetch_url2);
    print $MITOGIPULL2 "$efetch_out2";
    if ($retstart2 % 10000 == 0){
        print "$retstart2 GIs of $count2 total processed.\n"
    }
}
close $MITOGIPULL2;

#Parse the resulting file to get just the GI numbers of the accessions, one on each line
open(my $MITOSEQIDS2, "<", "data/mitoEUTILpull_fullmtgenome.txt") || die "Can't open file: $!\n";
open(my $MITOGIOUT2, ">", "data/mitoGIs_fullmtgenomes_$taxID.txt") || die "Can't open file: $!\n";

while(my $line = <$MITOSEQIDS2>){
    if ($line =~ /Seq-id\s::=\sgi\s(\d+)/) {
        print $MITOGIOUT2 "$1\n";
    }
}

close $MITOSEQIDS2;
close $MITOGIOUT2;

unlink "data/mitoEUTILpull_fullmtgenome.txt"; #deletes temporary file


##Create the actual vertmito blast database
#system("blastdb_aliastool -db nt -dbtype nucl -gilist data/mitoGIs_fullmtgenomes_$taxID.txt -out fullmtgenomes_$taxID -title fullmtgenomes_$taxID"); #Mac testing version
##system('blastdb_aliastool -db allNuc -dbtype nucl -gilist data/mitoGIs_$taxID.txt -out /Volumes/Spinster/data/blastdb/vertMito -title vertMito') #Linux production version
#copy("fullmtgenomes_$taxID.n.gil", "data/db/fullmtgenomes_$taxID.n.gil") or die "File cannot be copied: $!\n";
#copy("fullmtgenomes_$taxID.nal", "data/db/fullmtgenomes_$taxID.nal") or die "File cannot be copied: $!\n";
#unlink "fullmtgenomes_$taxID.n.gil";
#unlink "fullmtgenomes_$taxID.nal";

print "***subset_mito_db.pl finished executing.***\n"
