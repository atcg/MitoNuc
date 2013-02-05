#!/usr/bin/perl

use strict;
use warnings;
use File::Copy;

opendir(DIRECTORY, "data/gi_lists");
my @giFiles = readdir(DIRECTORY);
closedir(DIRECTORY);
unless(-d "data/FASTA") {
    mkdir "data/FASTA" or die "can't mkdir FASTA in data directory: $!";
}

foreach my $giTextFile (@giFiles) {
  next if $giTextFile eq '.' || $giTextFile eq '..' || $giTextFile eq '.DS_Store'; #for readability on command line while running program
  if ($giTextFile =~ /(\d+)_mito_nogenomes\.txt/) {
    my $newDBname = $1 . '_mito_nogenomes_db';
    system("blastdb_aliastool -db nt -dbtype nucl -gilist data/gi_lists/$giTextFile -out $newDBname -title $newDBname");
    system("blastdbcmd -db $newDBname -dbtype nucl -entry all -outfmt %f -out data/FASTA/$newDBname.fasta");
  } elsif ($giTextFile =~ /(\d+)_mito_genomes\.txt/) {
      my $newDBname = $1 . '_mito_genomes';
      system("blastdb_aliastool -db nt -dbtype nucl -gilist data/gi_lists/$giTextFile -out $newDBname");
      system("blastdbcmd -db $newDBname -dbtype nucl -entry all -outfmt %f -out data/FASTA/$newDBname.fasta");
  } elsif ($giTextFile =~ /(\d+)nuc\.txt/) {
      my $newDBname = $1 . '_nuc';
      system("blastdb_aliastool -db nt -dbtype nucl -gilist data/gi_lists/$giTextFile -out $newDBname");
      system("blastdbcmd -db $newDBname -dbtype nucl -entry all -outfmt %f -out data/FASTA/$newDBname.fasta");
  } else {
      print "$giTextFile doesn't appear to be the right file to create new databases out of (digits[mito|nuc].txt).\n";
  }
}

unless(-d "data/db") {
    mkdir "data/db" or die "can't mkdir db in data directory: $!";
}

my $old_loc_nal = "./*.nal";
my $old_loc_gil = "./*.gil";
my $arc_dir = "./data/db/";

for my $file (glob $old_loc_nal) {
    move ($file, $arc_dir) or die $!;
}

for my $file (glob $old_loc_gil) {
    move ($file, $arc_dir) or die $!;
}