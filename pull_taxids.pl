#!/usr/bin/perl

use strict;
use warnings;
use Bio::DB::Taxonomy;

#MUST USE DOWNLOADED TAXONOMY FLATFILE
my $dbdir = '/home/evan/Desktop/src/MitoNuc/db'; #downloaded data from NCBI taxdump into this directory
my $db = Bio::DB::Taxonomy->new(-source => 'flatfile',
                                 -nodesfile => "$dbdir/nodes.dmp",
                                 -namesfile => "$dbdir/names.dmp",
                                 );
my $taxa = $db->get_taxon(-taxonid => 8948);
my @childNodes = $db->get_all_Descendents($taxa);

#Extract the elements of @childNodes that are of species rank into new array
my @childSpecies;
foreach my $subnode (@childSpecies) {
    #if $subnode is a species:
        #push to @childSpecies
}


print join("\n", map { $_->id . " " . $_->rank . " " .
$_->scientific_name } @childNodes), "\n";

print "Total number of subnodes under parent taxonomy node: ", scalar(@childNodes), "\n";
