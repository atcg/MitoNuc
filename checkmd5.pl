#!/usr/bin/perl

#usage example: perl checkmd5.pl --file2hash mito.aa.gz --md5file mito.aa.gz.md5
#The program returns exit status 0 if the checksums match, and exit status 23 if they do not!

use strict;
use warnings;
use Getopt::Long;
use Digest::MD5;

my $file;
my $checksum_file;

GetOptions ("file2hash=s" => \$file,
            "md5file=s" => \$checksum_file);


my $rmt_digest = read_md5_file($checksum_file);
my $lcl_digest = compute_md5_checksum($file);


if ($lcl_digest ne $rmt_digest) {
    exit(23); #computed md5 does not match downloaded md5, so return custom error code
}
else {
    exit(0); #computed md5 matches downloaded md5, so return 0 (success)
}


sub read_md5_file
{
    my $md5file = $_[0];
    open(IN, $md5file) or die "FML! Couldn't open md5 file for reading: $!\n";
    $_ = <IN>;
    close(IN);
    my @retval = split;
    return $retval[0];
}

sub compute_md5_checksum
{
    my $file = shift;
    open(DOWNLOADED_FILE, $file) or die "FML! Couldn't open file to have md5 computed.\n";
    binmode(DOWNLOADED_FILE) or die "FML! Couldn't binmode the file that is having md5 computed.\n";
    my $digest = Digest::MD5->new->addfile(*DOWNLOADED_FILE)->hexdigest;
    close(DOWNLOADED_FILE);
    return $digest;
}