#!/usr/bin/perl

use warnings;
use strict;

## vcf2simplegt.pl -- convert from VCF file to simplegt format

use Getopt::Long qw(:config auto_help pass_through);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

my %colIDs = ();

my $idFileName = "";
my %ids = ();
my @idOrder = ();
my $idsSpecified = 0; # false

my %excludeCols = (
  "#CHROM" => 1, "POS" => 1,  "REF" => 1,
  "ALT" => 1, "QUAL" => 1,  "FILTER" => 1,
  "INFO" => 1, "FORMAT" => 1);

GetOptions("idFile=s" => \$idFileName) or
    die("Error in command line arguments");

if($idFileName){
  print(STDERR "Retrieving id names from $idFileName...");
  $idsSpecified = 1; # true
  my $idFile = 0;
  $idFile = new IO::Uncompress::Gunzip "$idFileName" or
      die "Unable to open $idFileName\n";
  while(<$idFile>){
    if(/^\"?(.*?)\"?[\s,]+/){
      my $id = $1;
      $ids{$id} = 1;
      push(@idOrder, $id);
    }
  }
  close($idFile);
  print(STDERR keys(%ids)." id names extracted\n");
}

while(<>){
  chomp;
  my @F = split(/\t/, $_);
  if(!$colIDs{"ID"}){
    if(!(/ID/)){
      next;
    }
    my $colNum = 0;
    foreach my $colName (@F){
      if(!$excludeCols{$colName}){
	$colIDs{$colName} = $colNum++;
	$ids{$colName} = 1;
	if(!$idsSpecified && ($colName ne "ID")){
	    push(@idOrder, $colName);
	  }
	}
      }
    }
    printf("## <Individual/Column IDs: %s > ##\n",
	join(" ", @idOrder));
    next;
  }
  ## by this time, @idOrder should be populated with column IDs
  printf("%-15s %s\n", $F[$ids{"ID"}], join(" ",@F[@ids{@idOrder}]));
}
