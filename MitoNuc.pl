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
#       2. Subset the mitochondrial GIs from the full GI list in step 2, and
#           create a database of just the mitochondrial stuff.
#           (subset_mito_gis.pl)
#       3. Creating lists of GI numbers for all members of each family within
#           the higher-level taxonomic category (there are 3 families within
#           falconiformes, for instance). This is implemented in taxID_to_GIs.pl
#       4. Subsetting the full GI lists for nuclear and mitochondrial GIs
#           (remove_mito_gis_from_gi_lists.pl)
#       5. Creating subsets of blast databases which include only the GI numbers
#           for each family in step one. Each family gets four blast databases,
#           two for protein sequences (mitochondrial and nuclear) and two for
#           nucleotide sequences (mitochondrial and nuclear). This is implemented
#           in subset_blastdbs.pl
#       6. Create FASTA flatfiles for all the databases I just made. This is
#           needed to run CD-Hit
#       6. Run clustering analysis on the individual family blast databases. This
#           will be implemented in get_your_clustering_on.pl
#       7. Format data matrices for analysis
#       8. Run phylogenetic analyses on formatted data.
#       9. Quantify results


#To change this to work with the Rover:
#  1. switch the nt to allNuc in the system calls to blast+ applications

use strict;
use warnings;
use Getopt::Long;

my $taxID = 8948; #default to falconiformes (for testing). Vertebrata is 7742.
GetOptions ("taxid=i" => \$taxID);
if ($taxID == 8948) {
   print "taxID not set by user. Using falconiformes (8948) as example.\n";
}

print "Higher Level Taxon ID: $taxID.\n";

##1.
#print "Updating blast databases. This will take a while...\n";
#system("updateblastdb"); #Downloads a bunch of databases and creates allNuc and allProt. 24 HOURS?

#2.
#print "Creating a full mitochondrial blast database called vertMito.\n";
#system("perl lib/subset_mito_db.pl"); #Also creates a list of all vertebrate mitochondrial GIs (data/mitoGIs.txt)--FEW HOURS

#3.
print "Creating full (includes nuclear and mitochondrial) GI lists for every family found within taxon ID $taxID.\n";
system("perl lib/taxID_to_GIs.pl --taxID $taxID"); #8 HOURS?

#4.
print "Creating master mitochondrial GI list for vertebrates\n";
system("perl lib/subset_mito_db.pl --taxID $taxID"); 

#4
print "Separating into distinct lists mitochondrial and nuclear GIs for each family.\n";
system("perl lib/remove_mito_gis_from_gi_lists.pl --taxID $taxID");

#5.
print "***Subsetting blast databases with GIs from each family and creating FASTA files from blast databases to use with cd-hit..***\n";
system("perl lib/subset_blastdbs.pl"); #independent of input $taxID, just loops through all files in the gi_lists directory. FAST


#6. Run clustering analysis on the individual family blast databases
#system("get_your_clustering_on.pl -dir gi_lists");










