# Add the fwdata file name(s) and the Ethnologue code (e.g.xxx) to the ini file and then run:
# perl ./FWExampleExtract.pl >beforehiglight.patch.xml
# ws=xxx perl -pf ./ApplyHighlight.pl <beforehiglight.patch.xml >afterhighlight.patch.xml
# perl ./FWExampleEdit.pl

# Enhancements:
# Instead of running as a line by line script, it should use XML::LibXML to parse the patch file and process that.

# use qaa for the language code if the environment variable doesnt exist
my $ws = $ENV{ws} ? $ENV{ws} : "qaa";
say STDERR "Language Code:$ws" if ($NR ==1);
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
say STDERR "lexeme:$lextext" if $debug;

my $citfront = qq{<LexCitationText><AUni ws="$ws">};
my $citend = qq{</AUni></LexCitationText>};
next if $line !~ m/(\Q$citfront\E)(.*)(\Q$citend\E)/;
my $cittext = $2;
say STDERR "citation:$cittext" if $debug;


my $varfront = qq{<LexEntVarText><AUni ws="$ws">};
my $varend = qq{</AUni></LexEntVarText>};
my @varlist = ();
while ($line =~ m/(\Q$varfront\E)(.*?)(\Q$varend\E)/g) {
	push (@varlist, $2);
	}
@varlist = sort { length($b) <=> length($a) } @varlist; # sort longest first
for my $var (@varlist) {
	say STDERR "variants:$var" if $debug;
	}

my $allofront = qq{<LexAlloText><AUni ws="$ws">};
my $alloend = qq{</AUni></LexAlloText>};
my @allolist = ();
while ($line =~ m/(\Q$allofront\E)(.*?)(\Q$alloend\E)/g) {
	push (@allolist, $2);
	}
@allolist = sort { length($b) <=> length($a) } @allolist; # sort longest first
for my $allo (@allolist) {
	say STDERR "allophones:$allo" if $debug;
	}

my $examplefront = qq{<ExampleText><AStr ws="$ws"><Run ws="$ws">};
my $exampleend = qq{</Run></AStr></ExampleText>};
next if $line !~ m/(\Q$examplefront\E)(.+)(\Q$exampleend\E)/;
my $examplenode=$MATCH;
say STDERR "Examplenode:$examplenode" if $debug;

for my $text ($cittext, $lextext, @varlist, @allolist) {
	if (($examplefront =~ m/$text/) || ($exampleend =~ m/$text/)) {
		say STDERR qq{Found "$text" in XML code "$examplefront" or "$exampleend" ignoring on line number $INPUT_LINE_NUMBER};
		next;
		}
	say STDERR qq{look for:"$text" in "$examplenode"} if $debug;
	if ($examplenode =~ m/$text/) {
		$examplenode =~ s/$text/$highlightfront$text$highlightend/g;
		$line =~ s/(\Q$examplefront\E)(.*)(\Q$exampleend\E)/$examplenode/;
		say STDERR qq{Found and highlighted "$text" in "$examplenode"} if $debug;
		last;
		}
	}
$_=$line;
say STDERR "Record after:$line" if $debug;
say STDERR "" if $debug;
say STDERR "" if $debug;
