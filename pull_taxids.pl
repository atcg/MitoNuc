#!/usr/bin/perl

use strict;
use warnings;
use Bio::DB::Taxonomy;
use Bio::DB::Taxonomy::entrez;

my $db = Bio::DB::Taxonomy->new(-source => 'entrez');

my $taxonid = 54318;

# get a taxon
my $taxon = $db->get_taxon(-taxonid => $taxonid);

my @taxa = $db->get_all_Descendents($taxon);

print @taxa;




#TRY THIS BELOW

my $dbdir = '/db/taxonomy/ncbi/'; #downloaded data from NCBI taxdump into this directory
my $db = Bio::DB::Taxonomy->new(-source => 'flatfile',
                                 -nodesfile => "$dbdir/nodes.dmp",
                                 -namesfile => "$dbdir/names.dmp",
                                 );
my $taxa = $db->get_taxon(-taxonid => 151341);
my @d = $db->get_all_Descendents($taxa);

print join("\n", map { $_->id . " " . $_->rank . " " .
$_->scientific_name } @d), "\n";
