#!/usr/bin/perl

use strict;
use warnings;
use Bio::DB::Taxonomy;

#First we create the master hash that will be used for taxID lookup and sorting
#There needs to be the ginormous gi-taxid columned files in the /mnt/Data1/blastdb
#directory. These should be called nuc_gi_taxa_key.txt and prot_gi_taxa_key.txt
#We create a ginormous hash first that puts makes the first value of each row
#(the gi number) the hash key, #and the second value of each row (the taxon ID)
#the hash value
open( my $txIDgi_fh, "<", '/mnt/Data1/blastdb/allnuc_taxa_key.txt' )
  or die "Can't read /mnt/Data1/blastdb/allnuc_taxa_key.txt: $!\n";

my %taxgi;
while ( defined( my $txgi_row = <$txIDgi_fh> ) ) {
    my $row = $txgi_row =~ /(\d+)\s(\d+)/;
    my $taxonID = $1;
    my $gi = $2;
    #push the gi to the end of the hash value for the corresponding key (taxonID)
    push (@{$taxgi{$taxonID}}, $gi);
}
print "Ginormous (94 million key-value pairs?) taxID - GI hash created!\n";
close $txIDgi_fh;

#Now we create a hash of all the taxon IDs of all vertebrate families
#This should be an array of length 971, with all integer values. 7742 is the
#taxonID for vertebrates
my @vertFamilies = getChildTaxa(7742, 'family');
print "Array of all ", scalar(@vertFamilies), " families created!\n";

#Now, for each family, we want to create an array of taxonIDs that correspond to
#all the species and subspecies within that family
#We do this by creating a hash from the @vertFamilies array. Each element of the
#@vertFamilies array becomes a key, and we compute the array of taxIDs using the
#getChildTaxa subrouting
my %vertFamilySpecies;
my $counter = 0;
foreach my $loopFamily (@vertFamilies) {
    push(@{$vertFamilySpecies{$loopFamily}}, getChildTaxa($loopFamily, 'species',
                                                          'subspecies'));
    $counter ++;
    print "$counter of ", scalar(@vertFamilies), " families processed...\n";
}
print "Hash of all species within each vertebrate family created!\n";

#Now we process the hash to print to gi files
#First we set up our files and directory
unless(-d "gi_lists") {
    mkdir "gi_lists" or die "can't mkdir gi_lists: $!";
}
foreach my $familyKey (sort keys %vertFamilySpecies) {
    #first create file that will contain all the gi's for that molecule type for
    #that family the filename will be familytaxid.txt. So for Apistidae it would
    #be 990930.txt
    my $filename = "gi_lists/" . $familyKey . '.txt';
    open my $fh, '>', $filename;
    #as we iterate through each key of the above hash, we need to iterate through
    #the array stored in the hash value and print the values from %taxgi. Each
    #gi should be separated by a newline.
    foreach my $VSpecies (@{$vertFamilySpecies{$familyKey}}) {
        print $fh map { "$_\n" } @{$taxgi{$VSpecies}};
    }
}

sub getChildTaxa
{
#first check to make sure our input parameters are correct. We can input one or
#two taxonomy levels (family, species, subspecies, etc...) after the taxID:
    if ((scalar(@_) == 2 or scalar(@_) == 3) && $_[0] =~ /^\d+/)
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
            if (scalar(@_) == 3)
            {
                if ($subnode->rank eq $_[1] or $subnode->rank eq $_[2]) {
                    push(@childTaxaOfInterest, $subnode->id);
                }
            } elsif (scalar(@_) == 2)
            {
                if ($subnode->rank eq $_[1]) {
                    #add taxon to @childSpecies
                    push(@childTaxaOfInterest, $subnode->id);
                }
            }
        }
        return (@childTaxaOfInterest);

    #    print join("\n", map { $_->id . " " . $_->rank . " " . 
    #    $_->scientific_name } @childSpecies), "\n";
    #    print "total species/subspecies: ", scalar(@childSpecies), "\n";
    } else {
        die "Must provide a single integer value (taxon ID) and either one or two taxonomy ranks to getChildSpecies";
    }
}