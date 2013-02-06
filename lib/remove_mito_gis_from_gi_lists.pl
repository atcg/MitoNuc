#!/usr/bin/perl

#remove_mito_gis_from_gi_lists.pl
#Usage: perl remove_mito_gis_from_gi_lists.pl --taxID 8948

use strict;
use warnings;
use Getopt::Long;

my $taxID;
GetOptions ("taxid=i" => \$taxID);

#Create big hashes for mitochondrial GIs (one for genomes, one for non-genomes)
print "Creating hashes for all GIs from data/mitoGIs.txt and data/mitoGIs_fullmtgenomes_$taxID.txt.\n";
my %allMitoNoGenomesHash;
my %allMitoGenomesHash;

open (my $allMitoNoGenomesGiFile, "<", "data/mitoGIs_nogenomes_$taxID.txt") || die "Couldn't open the full mito GI file for reading: $!";
while (my $mitoGI = <$allMitoNoGenomesGiFile>) {
    $allMitoNoGenomesHash{$mitoGI} = 1;
}
close($allMitoNoGenomesGiFile);
print "Finished creating hash for non-genome mitochondrial GIs.\n";

open (my $allMitoGenomesGiFile, "<", "data/mitoGIs_fullmtgenomes_$taxID.txt") || die "Couldn't open the full mito GI file for reading: $!";
while (my $mitoGenomeGI = <$allMitoGenomesGiFile>) {
    $allMitoGenomesHash{$mitoGenomeGI} = 1;
}
close($allMitoGenomesGiFile);
print "Finished creating hash for mitochondrial genome GIs.\n";


#create a hash for each family where each GI is a hash key, and check it against the mito hashes
print "Creating individual hashes for each family holding all GIs, then filtering against full mitochondrial hash.\n";
opendir(DIRECTORY, "data/gi_lists");
my @AllGI_Files = readdir(DIRECTORY); #this just holds a list of names of the txt files in the directory
closedir(DIRECTORY);

foreach my $giTextFile (@AllGI_Files) {
  if ($giTextFile =~ /(\d+)\.txt/) {
    my $familyTaxID = $1;
    my %familyHash;
    open (my $currentFamily_fh, "<", "data/gi_lists/$giTextFile") || die "Couldn't open family total GI file for reading: $!"; #must explicitly open the file to iterate through it
    while (my $gi = <$currentFamily_fh>) {
        $familyHash{$gi} = 1;
    }
    close($currentFamily_fh);
    
    my $mitoNoGenomesFileName = $familyTaxID . "_mito_nogenomes" . ".txt";
    my $mitoGenomesFileName = $familyTaxID . "_mito_genomes.txt";
    my $nucFileName = $familyTaxID . "nuc" . ".txt";
    open (my $currentFamilyMitoNoGenomes, ">", "data/gi_lists/$mitoNoGenomesFileName") || die "Couldn't create family mito GI file: $!";
    open (my $currentFamilyMitoGenomes, ">", "data/gi_lists/$mitoGenomesFileName") || die "Couldn't create family mito GI file: $!";
    open (my $currentFamilyNuc, ">", "data/gi_lists/$nucFileName") || die "Couldn't create family nuc GI file: $!";
    #compare hash to mitochondrial hash. If no match print to new nonMito file. If match print to family mito file.
    foreach my $giKey (keys %familyHash) {
        if (exists $allMitoNoGenomesHash{$giKey}) {
            print $currentFamilyMitoNoGenomes "$giKey";
        } elsif (exists $allMitoGenomesHash{$giKey}) {
            print $currentFamilyMitoGenomes "$giKey";
        } else {
            print $currentFamilyNuc "$giKey";
        }
    }
    close $currentFamilyMitoNoGenomes;
    close $currentFamilyMitoGenomes;
    close $currentFamilyNuc;
    unlink "data/gi_lists/$giTextFile";
  }
}
print "Finished separating mitochondrial and nuclear GIs!\n";
