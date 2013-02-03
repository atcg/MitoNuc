#!/usr/bin/perl

use strict;
use warnings;

#Break up mitochondrial genomes into individual gene records and add to FASTA file . Then remove all long sequences.

#Change subset_mito_db.pl into two steps.
#One is a search a pull for $queryOrg NOT "genome" (or maybe NOT "complete genome") AND gene_in_mitochondrion[PROP].
#The other is $queryOrg AND "genome" (or maybe AND "complete genome") AND gene_in_mitochondrion[PROP]

#Create two different GI files (1 of mitochondrial genomes, 1 of not mitochondrial genomes but still in mitochondrion)

#Create the non-genome mitochondrial database as usual, then append broken up genome records to the end of the FASTA file
