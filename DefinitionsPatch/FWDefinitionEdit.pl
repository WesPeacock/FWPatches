#!/usr/bin/perl
my $USAGE = "Usage: $0 [--inifile inifile.ini] [--section section] [--debug]";
# Takes an Definitions patch file and applies it to an FWdata file
use 5.020;
use strict;
use warnings;
use English;
use Data::Dumper qw(Dumper);
use utf8;
use open qw/:std :utf8/;
use File::Basename;
my $scriptname = fileparse($0, qr/\.[^.]*/); # script name without the .pl

use XML::LibXML;

use Getopt::Long;
GetOptions (
	'inifile:s'   => \(my $inifilename = "FWDefinitions.ini"), # ini filename
	'section:s'   => \(my $inisection = "FWDefinitionEdit"), # section of ini file to use
	'debug'       => \my $debug,
	) or die $USAGE;

use Config::Tiny;
 # ; FWDefinitions.ini file looks like:
# [FWDefinitionExtract]
# Definitionws=en
# Vernacularws=nko
# infilename=Nkonya.fwdata
# patchtag=ltp
# deftexttag=df
# lexsenseguidtag=lsguid
# lexenttag=let
# 
# [FWDefinitionEdit]
# Definitionws=en
# infilename=Nkonya.fwdata
# outfilename=Nkonya.1.fwdata
# patchfilename=Nkonyafwdata.patch.xml
# patchtag=ltp
# deftexttag=df
# lexsenseguidtag=lsguid
# lexenttag=let

say STDERR "read config from:$inifilename";
my $config = Config::Tiny->read($inifilename, 'crlf');
die "Couldn't find the INI file\nQuitting" if !$config;

my $DefinitionlanguageEncoding =  $config->{"$inisection"}->{Definitionws};
say STDERR "DefinitionlanguageEncoding: $DefinitionlanguageEncoding";
my $DefinitionTextXpath = q#./Definition/AStr[@ws="# . $DefinitionlanguageEncoding . q#"]#;
say STDERR "DefinitionTextXpath:$DefinitionTextXpath";

my $infilename = $config->{"$inisection"}->{infilename};
# ToDo? check that parameters exist

my $lockfile = $infilename . '.lock' ;
die "A lockfile exists: $lockfile\
Don't run $0 when FW is running.\
Run it on a copy of the project, not the original!\
I'm quitting" if -f $lockfile ;

my $outfilename = $config->{"$inisection"}->{outfilename};
my $patchfilename = $config->{"$inisection"}->{patchfilename};
say STDERR "Processing fwdata file: $infilename";
my $fwdatatree = XML::LibXML->load_xml(location => $infilename);

say STDERR "DefinitionlanguageEncoding: $DefinitionlanguageEncoding" if $debug;
say STDERR "DefinitionTextXpath: $DefinitionTextXpath" if $debug;
say STDERR "outfilename: $outfilename" if $debug;
say STDERR "patchfilename:$patchfilename" if $debug;

say STDERR "Applying patch file: $patchfilename";
my $patchtree = XML::LibXML->load_xml(location => $patchfilename);
my $patchtag =  $config->{"$inisection"}->{patchtag};
my $deftexttag =  $config->{"$inisection"}->{deftexttag};
my $lexsenseguidtag =  $config->{"$inisection"}->{lexsenseguidtag};
my $lexenttag =  $config->{"$inisection"}->{lexenttag};

say STDERR "patchtag:$patchtag" if $debug;
say STDERR "deftexttag:$deftexttag" if $debug;
say STDERR "lexsenseguidtag:$lexsenseguidtag" if $debug;
say STDERR "lexenttag:$lexenttag" if $debug;

foreach my $patch ($patchtree->findnodes(q#//# . $patchtag)) {
	say STDERR "patch:$patch" if $debug;
	my ($lexsenseguid) = $patch->findnodes(q#./# . $lexsenseguidtag . q#/text()#);
	say STDERR  "lexsenseguid:$lexsenseguid" if $debug;
	my ($PatchTextNode) = $patch->findnodes(q#./# . $deftexttag . q#/AStr#);
	my ($PatchTextAsString) = $PatchTextNode->toString;
	say STDERR  "PatchTextAsString:$PatchTextAsString" if $debug;
	my $newnode = XML::LibXML->load_xml(string => $PatchTextAsString);
	my ($fwdataDefinitionTextNode) = $fwdatatree->findnodes(q#//rt[@guid='# . $lexsenseguid . q#']/Definition/AStr[@ws='# . $DefinitionlanguageEncoding . q#']#);
	say STDERR  "fwdataDefinitionTextNode:$fwdataDefinitionTextNode" if $debug;
	if (!$fwdataDefinitionTextNode) {
		say STDERR  "Definition text not found for patch:\n$patch" ;
		next;
		}
	say STDERR  "fwdataDefinition Before:", $fwdataDefinitionTextNode->toString if $debug;
	$fwdataDefinitionTextNode->parentNode()->insertAfter($PatchTextNode, $fwdataDefinitionTextNode);
	$fwdataDefinitionTextNode->unbindNode();
	my ($fwdataDefinitionTextNodeAfter) = $fwdatatree->findnodes(q#//rt[@guid='# . $lexsenseguid . q#']/Definition/AStr[@ws='# . $DefinitionlanguageEncoding . q#']#) if $debug;
	say STDERR  "Definition Parent After:\n", $fwdataDefinitionTextNodeAfter->parentNode() if $debug;
	}

my $xmlstring = $fwdatatree->toString;
# Some miscellaneous Tidying differences
$xmlstring =~ s#><#>\n<#g;
$xmlstring =~ s#(<Run.*?)/\>#$1\>\</Run\>#g;
$xmlstring =~ s#/># />#g;
say "Finished processing, writing modified  $outfilename" ;
open my $out_fh, '>:raw', $outfilename;
print {$out_fh} $xmlstring;
