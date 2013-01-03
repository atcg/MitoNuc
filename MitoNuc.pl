#!/usr/bin/perl

#   MitoNuc.pl, December 29, 2012
#   Written by Evan McCartney-Melstad (evanmelstad@ucla.edu)   
#
#   This script is the figurative crank that must be turned to perform all the
#   tasks involved in this project. Usage is:
#    
#   cd ~/Desktop/src/MitoNuc
#   perl MitoNuc.pl --taxid 8948
#
#   where 8948 is an example taxID to be used for the higher taxonomic category
#   of interest (8948 is Falconiformes).
#
#   This script calls several other scripts which perform the higher level tasks.
#   These tasks include:
#       1. Download blast databases and master GI list file
#           (updateblastdb.sh)
#       2. Subset the mitochondrial GIs from the full GI list in step 2
#           (subset_mito_gis.pl)
#       3. Creating lists of GI numbers for all members of each family within
#           the higher-level taxonomic category (there are 3 families within
#           falconiformes, for instance). This is implemented in taxID_to_GIs.pl
#       4. Creating subsets of blast databases which include only the GI numbers
#           for each family in step one. Each family gets two blast databases,
#           one for protein sequences and one for nucleotide sequences. This is
#           implemented in subset_blastdbs.pl
#       5. Run clustering analysis on the individual family blast databases. This
#           will be implemented in get_your_clustering_on.pl
#       6. Format data matrices for analysis
#       7. Run phylogenetic analyses on formatted data.
#       8. Quantify results

use strict;
use warnings;
use Getopt::Long;

my $taxID = 8948; #default to falconiformes (for testing). Vertebrata is 7742.
GetOptions ("taxid=i" => \$taxID);
if ($taxID == 8948) {
   print "taxID not set by user. Using falconiformes (8948) as example.\n";
}

print "Higher Level Taxon ID: $taxID.\n";

#1.
print "Updating blast databases. This will take a while...\n";
system("updateblastdb");

#2.
print "Downloading list of GI numbers for all vertebrate mitochondrial records.\n";
system("perl lib/subset_mito_gis.pl");

#3.
print "Creating GI lists for every family found within taxon ID $taxID.\n";
system("perl lib/taxID_to_GIs.pl --taxID $taxID");

#4.
print "Subsetting blast databases with GIs from each family.\n";
opendir(DIRECTORY, "gi_lists");
my @giFiles = readdir(DIRECTORY);
closedir(DIRECTORY);
foreach my $giTextFile (@giFiles) {
  if ($giTextFile =~ '(.+)\.txt') {
    my $newDBname = $1 . 'db';
    system("blastdb_aliastool -db nt -dbtype nucl -gilist gi_lists/$giTextFile -out /Volumes/Spinster/data/blastdb/$newDBname")   
  }
}

#5. Run clustering analysis on the individual family blast databases
#system("get_your_clustering_on.pl -dir gi_lists");










