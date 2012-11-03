#!/usr/bin/perl

use strict;
use warnings;
use Bio::DB::Taxonomy;

#first get the taxon IDs of all vertebrate families
my @vertFamilies = getChildTaxa(7742, 'family');
print scalar(@vertFamilies);



unless(-d "gi_lists") {
    mkdir "gi_lists" or die "can't mkdir gi_lists: $!";
}
foreach my $family (@vertFamilies) {
    #first create file that will contain all the gi's for that molecule type for that family
    #the filename will be familytaxid.txt. So for Apistidae it would be 990930.txt
    my $filename = "gi_lists/" . $family . '.txt';
    open my $fh, '>', $filename;
    }



sub getChildTaxa
{
#first check to make sure our input parameters are correct:
    if ((scalar(@_) == 1 or scalar(@_) == 2) && $_[0] =~ /^\d+/)
    {    
        my $dbdir = 'db'; #this is a dir containing nodes.dmp and names.dmp from ncbi
        my $db = Bio::DB::Taxonomy->new(-source => 'flatfile',
                                        -nodesfile => "$dbdir/nodes.dmp",
                                        -namesfile => "$dbdir/names.dmp",
                                        );
        my $taxa = $db->get_taxon(-taxonid => $_[0]);
        my @childNodes = $db->get_all_Descendents($taxa);
        
        #Extract the elements of @childNodes that are of species rank into new array
        my @childTaxaOfInterest;
        foreach my $subnode (@childNodes)
        {
            if ($subnode->rank eq $_[1]) {
                #add taxon to @childSpecies
                push(@childTaxaOfInterest, $subnode->id);
            }
        }
        return (@childTaxaOfInterest);
    #    print join("\n", map { $_->id . " " . $_->rank . " " . 
    #    $_->scientific_name } @childSpecies), "\n";
    #    print "total species/subspecies: ", scalar(@childSpecies), "\n";
    } else {
        die "Must provide a single integer value (taxon ID) to getChildSpecies";
    }
}