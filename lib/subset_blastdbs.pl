#!/usr/bin/perl

use strict;
use warnings;

opendir(DIRECTORY, "data/gi_lists");
my @giFiles = readdir(DIRECTORY);
closedir(DIRECTORY);
unless(-d "data/FASTA") {
    mkdir "data/FASTA" or die "can't mkdir FASTA in data directory: $!";
}

foreach my $giTextFile (@giFiles) {
  next if $giTextFile eq '.' || $giTextFile eq '..' || $giTextFile eq '.DS_Store'; #for readability on command line
  if ($giTextFile =~ /(\d+)mito\.txt/) {
    my $newDBname = $1 . '_mito_db';
    system("blastdb_aliastool -db nt -dbtype nucl -gilist data/gi_lists/$giTextFile -out /Volumes/Spinster/data/blastdb/$newDBname");
    system("blastdbcmd -db $newDBname -dbtype nucl -entry all -outfmt %f -out data/FASTA/$newDBname.fasta");
  } elsif ($giTextFile =~ /(\d+)nuc\.txt/) {
      my $newDBname = $1 . '_nuc_db';
      system("blastdb_aliastool -db nt -dbtype nucl -gilist data/gi_lists/$giTextFile -out /Volumes/Spinster/data/blastdb/$newDBname");
      system("blastdbcmd -db $newDBname -dbtype nucl -entry all -outfmt %f -out data/FASTA/$newDBname.fasta");
  } else {
      print "$giTextFile doesn't appear to be the right file to create new databases out of (digits[mito|nuc].txt).\n";
  }
}

