#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;
use Getopt::Long;

unless(-d "data/db") {
    mkdir "data/db" or die "can't mkdir data: $!";
}


my $taxID;
GetOptions("taxid=i" => \$taxID);
if ($taxID eq '') {
    print "must supply taxon ID to subset_mito_db.pl\n";
}

my $queryOrg = "txid" . $taxID . "[Organism:exp]";
print "Higher Level Taxon ID for creating mito GI subset: $taxID.\n";

my $query = "$queryOrg AND gene_in_mitochondrion[PROP]";

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
open(my $MITOGIOUT, ">", "data/mitoGIs_$taxID.txt") || die "Can't open file: $!\n";

while(my $line = <$MITOSEQIDS>){
    if ($line =~ /Seq-id\s::=\sgi\s(\d+)/) {
        print $MITOGIOUT "$1\n";
    }
}

close $MITOSEQIDS;
close $MITOGIOUT;

unlink "data/mitoEUTILpull.txt"; #deletes temporary file


#Create the actual vertmito blast database
system("blastdb_aliastool -db nt -dbtype nucl -gilist data/mitoGIs_$taxID.txt -out data/db/AllMitoGIs_$taxID -title AllMitoGIs_$taxID") #Mac testing version
#system('blastdb_aliastool -db allNuc -dbtype nucl -gilist data/mitoGIs_$taxID.txt -out /Volumes/Spinster/data/blastdb/vertMito -title vertMito') #Linux production version

#Create a database of ONLY the nuclear accessessions (don't include the mitochondrial GIs)


#TODO: Add support for protein databases

