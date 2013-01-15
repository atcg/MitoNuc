#!/usr/bin/perl

use strict;
use warnings;
use Bio::DB::Taxonomy;
use Env qw(BLASTDB); #This creates the variable $BLASTDB in Perl, which is equal
                     #to the system environmental variable $BLASTDB
use Getopt::Long;

my $taxIDz;
GetOptions ("taxid=i" => \$taxIDz);
unless (defined $taxIDz) {
    print "Higher level taxon ID not supplied. Must use --taxid argument in call.\n";
}
print "***taxID_to_GIs.pl. Supplied Taxon ID: $taxIDz. blastDB: $BLASTDB***\n";

#We create a hash of all the taxon IDs of all vertebrate families
#This should be an array of length 971, with all integer values. 7742 is the
#taxonID for vertebrates. 8948 is for Falconiformes (fewer taxa for testing)
my @vertFamilies = getChildTaxa($taxIDz, 'family');
print "Array of all ", scalar(@vertFamilies), " families created!\n";

#Now, for each family, we want to create an array of taxonIDs that correspond to
#all the species and subspecies within that family
#We do this by creating a hash from the @vertFamilies array. Each element of the
#@vertFamilies array becomes a key, and we compute the array of taxIDs using the
#getChildTaxa subrouting
my %vertFamilySpecies;
my $counter = 0;
foreach my $loopFamily (@vertFamilies) {
    push(@{$vertFamilySpecies{$loopFamily}}, getChildTaxa($loopFamily, 'species', 'subspecies'));
    $counter ++;
    print "$counter of ", scalar(@vertFamilies), " families processed...\n";
}
print "Hash of all species within each family of interest created!\n";
print "Setting up gi directory structure.\n";

#Now we process the hash to print to gi files
#First we set up our files and directory
unless(-d "data/gi_lists") {
    mkdir "data/gi_lists" or die "can't mkdir gi_lists in data directory: $!";
}
my $familyCounter = 0;
foreach my $familyKey (sort keys %vertFamilySpecies) {
    #first create file that will contain all the gi's for that molecule type for
    #that family the filename will be familytaxid.txt. So for Apistidae it would
    #be 990930.txt
    my $filename = "data/gi_lists/" . $familyKey . '.txt';
    open(my $fh, '>', $filename) or die "Couldn't open: $!\n";
    $familyCounter ++;
    print "***Processing family #", $familyCounter, " of ", scalar(@vertFamilies), ". (Family taxID: $familyKey)***\n";
    #as we iterate through each key of the above hash, we need to iterate through
    #the array stored in the hash value and print the values from %taxgi. Each
    #gi should be separated by a newline.
    my $speciesCounter = 0;
        foreach my $VSpecies (@{$vertFamilySpecies{$familyKey}}) {
        #Iterate through each species within a family, and store the GIs that we
        #harvest from gi_taxid_nucl.dmp.gz into a single scalar variable, which
        #we then print to the end of the file for the corresponding family
        $speciesCounter ++;
        
        #GNU grep is so much faster--if using on a Mac then use the locally installed
        #version of GNU grep in /usr/local/bin instead of system grep. Can use zgrep
        #in Linux machines
        my $VSpeciesGIs = `/usr/local/bin/grep "[[:space:]]$VSpecies\$" $BLASTDB/gi_taxid_nucl.dmp | awk '{print \$1}'`;
        print $fh $VSpeciesGIs;
        print "Processing species #$speciesCounter of ", scalar(@{$vertFamilySpecies{$familyKey}}), ".\n"
    }
}

print "*****Finished printing GIs for each family to individual files.*****\n";


sub getChildTaxa
{
#first check to make sure our input parameters are correct. We can input one or
#two taxonomy levels (family, species, subspecies, etc...) after the taxID:
    if ((scalar(@_) == 2 or scalar(@_) == 3) && $_[0] =~ /^\d+/)
    {    
        my $dbdir = $BLASTDB; #this is a dir containing nodes.dmp and names.dmp from ncbi
        unless(-d "data/taxonomy") {
            mkdir "data/taxonomy" or die "can't mkdir gi_lists in data directory: $!";
        }
        my $db = Bio::DB::Taxonomy->new(-source => 'flatfile',
                                        -nodesfile => "$dbdir/nodes.dmp",
                                        -namesfile => "$dbdir/names.dmp",
                                        -directory => "data/taxonomy",
                                        );
        my $taxa = $db->get_taxon(-taxonid => $_[0]);
        my @childNodes = $db -> get_all_Descendents($taxa);
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