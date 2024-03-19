# Add the fwdata file name(s) to the ini file and then run:
# perl ./FWExampleExtract.pl >beforehiglight.patch
# perl -pf ./ApplyHighlight.pl <beforehiglight.patch >afterhighlight.patch
# perl ./FWExampleEdit.pl

# Enhancements:
# Instead of running as a line by line script, it should use XML::LibXML to parse the patch file and process that.

my $ws="qaa";
my $highlightfront = qq{</Run><Run namedStyle="Headword-in-Example" ws="$ws">};
my $highlightend = qq{</Run><Run ws="$ws">};

my $debug=0;
my $line = $_;
say STDERR "Record before:$line" if $debug;

if (m/\Q$highlightfront\E/) {
	say STDERR "Record contains highlighted text already:$line";
	next;
	};

my $lexfront = qq{<LexEntText><AUni ws="$ws">};
my $lexend = qq{</AUni></LexEntText>};
next if $line !~ m/(\Q$lexfront\E)(.*)(\Q$lexend\E)/;
my $lextext = $2;
say STDERR "headword:$lextext" if $debug;

my $citfront = qq{<LexCitationText><AUni ws="$ws">};
my $citend = qq{</AUni></LexCitationText>};
next if $line !~ m/(\Q$citfront\E)(.*)(\Q$citend\E)/;
my $cittext = $2;
say STDERR "headword:$lextext" if $debug;


my $varfront = qq{<LexEntVarText><AUni ws="$ws">};
my $varend = qq{</AUni></LexEntVarText>};
my @varlist = ();
while ($line =~ m/(\Q$varfront\E)(.*?)(\Q$varend\E)/g) {
	push (@varlist, $2);
	}
for my $var (@varlist) {
	say STDERR "variants:$var" if $debug;
	}

my $examplefront = qq{<ExampleText><AStr ws="$ws"><Run ws="$ws">};
my $exampleend = qq{</Run></AStr></ExampleText>};
next if $line !~ m/(\Q$examplefront\E)(.+)(\Q$exampleend\E)/;
my $examplenode=$MATCH;
say STDERR "Examplenode:$examplenode" if $debug;

for my $text ($cittext, $lextext, @varlist) {
	say STDERR "look for:$text" if $debug;
	if (($examplefront =~ m/$text/) || ($exampleend =~ m/$text/)) {
		say STDERR qq{Found $text in XML code "$examplefront" or "$exampleend" ignoring entry on line number $INPUT_LINE_NUMBER};
		last;
		}
	if ($examplenode =~ s/$text/$highlightfront$text$highlightend/g) {
		$line =~ s/(\Q$examplefront\E)(.*)(\Q$exampleend\E)/$examplenode/;
		last;
		}
	}
$_=$line;
say STDERR "" if $debug;
say STDERR "" if $debug;
