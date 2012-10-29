MitoNuc
=======
Evan McCartney-Melstad

This is a set of tools that will be used to do a few things:
*  make many subsets of NCBI databases
*  run clustering analyses on these sub-databases
*  run phylogenetic analyses on the resulting nucleotide/protein clusters

This software was written on a Linux machine. It should work cross-platform,
however, as long as Perl, BioPerl, BioPerl-run, and blast+2.2.27 are installed
and configured correctly. See below for some tips on that.
    
MitoNuc requires several things to function. Among these are:
*  BioPerl-live (latest version of BioPerl from GitHub)
*  BioPerl-run (latest version from GitHub)
*  blast+2.2.27
*  Perl needs to know where to find the bioperl-run and bioperl-live modules
    *  can do this by modifying the $PERL5LIB environmental variable
    *  for instance: export PERL5LIB="$HOME/bioperl/bioperl-live:$HOME/bioperl/bioperl-run/lib:$PERL5LIB"
*  Perl needs to know where to find the blast+ binaries
    *  do this by setting the $BLASTPLUSDIR environmental variable
*  Perl needs to know where to find the blast(+) databases
    *  must set the $BLASTDB environmental variable to point to the databases
    (which you must download)
    

