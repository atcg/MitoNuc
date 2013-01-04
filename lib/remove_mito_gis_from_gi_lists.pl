#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $taxID;
GetOptions ("taxid=i" => \$taxID);

#create a big hash for all the mitochondrial GIs
print "Creating a hash for all mitochondrial GIs from data/mitoGIs.txt.\n";
my %allMitoHash;
open (my $allMitoGiFile, "<", "data/mitoGIs_$taxID.txt") || die "Couldn't open the full mito GI file for reading: $!";
while (my $mitoGI = <$allMitoGiFile>) {
    $allMitoHash{$mitoGI} = 1;
}
close($allMitoGiFile);
print "Finished creating hash for all mitochondrial GIs.\n";

#create a hash for each family where each GI is a hash key, and check it against %allMitoHash
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
    
    my $mitoFileName = $familyTaxID . "mito" . ".txt";
    my $nucFileName = $familyTaxID . "nuc" . ".txt";
    open (my $currentFamilyMito, ">", "data/gi_lists/$mitoFileName") || die "Couldn't create family mito GI file: $!";
    open (my $currentFamilyNuc, ">", "data/gi_lists/$nucFileName") || die "Couldn't create family nuc GI file: $!";
    #compare hash to mitochondrial hash. If no match print to new nonMito file. If match print to family mito file.
    foreach my $giKey (keys %familyHash) {
        if (exists $allMitoHash{$giKey}) {
            print $currentFamilyMito "$giKey";
        } else {
            print $currentFamilyNuc "$giKey";
        }
    }
    close $currentFamilyMito;
    close $currentFamilyNuc;
    unlink "data/gi_lists/$giTextFile";
  }
}
print "Finished separating mitochondrial and nuclear GIs!\n";
