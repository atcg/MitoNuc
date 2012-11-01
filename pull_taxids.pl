#!/usr/bin/perl

#This subroutine recursively searches through all child nodes of a taxon
#You feed the subroutine a single NCBI taxon ID (say a genus), and it will return
#an array of taxon IDs corresponding to all of the species within that genus.
#If you need to get other information (such as species names or species/subspecies
#ranks), then you can easily alter the subroutine to return an array of
#Bio::DB::Taxonomy objects instead, which may be accessed downstream.

#MUST USE DOWNLOADED TAXONOMY FLATFILE (update this regularly). The use of entrez
#as the source of the factory is apparently broken in BioPerl.

#usage example (for the genus anolis): my @childSpecies = getChildSpecies(28376);

use strict;
use warnings;
use Bio::DB::Taxonomy;


my @childSpecies = getChildSpecies(50);
print scalar(@childSpecies) . "\n";

sub getChildSpecies
{

#first check to make sure our input parameters are correct:
    if (scalar(@_) == 1 && $_[0] =~ /^\d+/)
    {    
        my $dbdir = 'db'; #this is a dir containing nodes.dmp and names.dmp from ncbi
        my $db = Bio::DB::Taxonomy->new(-source => 'flatfile',
                                        -nodesfile => "$dbdir/nodes.dmp",
                                        -namesfile => "$dbdir/names.dmp",
                                        );
        my $taxa = $db->get_taxon(-taxonid => $_[0]);
        my @childNodes = $db->get_all_Descendents($taxa);
        
        #Extract the elements of @childNodes that are of species rank into new array
        my @childSpecies;
        foreach my $subnode (@childNodes)
        {
            if ($subnode->rank eq 'species' or $subnode->rank eq 'subspecies') {
                #add taxon to @childSpecies
                push(@childSpecies, $subnode->id);
            }
        }
        return (@childSpecies);
    #    print join("\n", map { $_->id . " " . $_->rank . " " . 
    #    $_->scientific_name } @childSpecies), "\n";
    #    print "total species/subspecies: ", scalar(@childSpecies), "\n";
    } else {
        die "Must provide a single integer value (taxon ID) to getChildSpecies";
    }
    
}