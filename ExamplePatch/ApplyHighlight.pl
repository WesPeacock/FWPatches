# Add the fwdata file name(s) to the ini file and then run:
# perl ./FWExampleExtract.pl >beforehiglight.patch
# perl -pf ./ApplyHighlight.pl <beforehiglight.patch >afterhighlight.patch
# perl ./FWExampleEdit.pl

# Enhancements:
# Instead of running as a line by line script, it should use XML::LibXML to parse the patch file and process that.

my $debug=0;
my $line = $_;
say STDERR "Record before:$line" if $debug;

my $highlightfront = qq{</Run><Run namedStyle="Headword-in-Example" ws="qaa">};
my $highlightend = qq{</Run><Run ws="qaa">};

if (m/\Q$highlightfront\E/) {
	say STDERR "Record contains highlighted text already:$line";
	next;
	};

my $lexfront = qq{<LexEntText><AUni ws="qaa">};
my $lexend = qq{</AUni></LexEntText>};
next if $line !~ m/(\Q$lexfront\E)(.*)(\Q$lexend\E)/;
my $lextext = $2;
say STDERR "headword:$lextext" if $debug;

my $varfront = qq{<LexEntVarText><AUni ws="qaa">};
my $varend = qq{</AUni></LexEntVarText>};
my @varlist = ();
while ($line =~ m/(\Q$varfront\E)(.*)(\Q$varend\E)/g) {
	push (@varlist, $2);
	}
for my $var (@varlist) {
	say STDERR "variants:$var" if $debug;
	}

my $examplefront = qq{<ExampleText><AStr ws="qaa"><Run ws="qaa">};
my $exampleend = qq{</Run></AStr></ExampleText>};
next if $line !~ m/(\Q$examplefront\E)(.+)(\Q$exampleend\E)/;
my $examplenode=$MATCH;
say STDERR "Examplenode:$examplenode" if $debug;

for my $text ($lextext, @varlist) {
	say STDERR "look for:$text" if $debug;
	if ($examplenode =~ s/$text/$highlightfront$text$highlightend/g) {
		$line =~ s/(\Q$examplefront\E)(.*)(\Q$exampleend\E)/$examplenode/;
		last;
		}
	}
$_=$line;
say STDERR "" if $debug;
say STDERR "" if $debug;