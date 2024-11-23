#### FWExampleExtract.pl & FWExampleEdit.pl
This pair of programs extract Example Sentences from an fwdata file. It creates lines that can be edited and applied as patches to the fwdata file.
As well as the Example data, it also gives the headword and variants of the entry.
The edit program applies the patch file back onto the fwdata file, changing the Example text only.

Use them like this:
- build a patch file with *FWExampleExtract.pl*
- select the patches you're interested in
- If there are not to many, you can manually use FLEx to edit those Example sentences
- or massage the patch file to do simple edits and apply them with the *FWExampleEdit.pl*

You can modify the *FWExampleExtract.pl* to add other fields to the patch file.
These fields can be used to make more sophisticated changes to the Example sentences (e.g. Task 3 below).
However, only the Example sentence will be changed by the *FWExampleEdit.pl* script.

Currently, following fields are added to the patch file:
- The lexeme form, tagged *\<LexEntText\>*
- The citation form, tagged *\<LexCitationText\>*
- The (possibly multiple) forms of variants, tagged *\<LexEntVarText\>*
- The (possibly multiple) forms of allomorphs, tagged *\<LexAlloText\>*

Here's a sample patch entry:
````XML
<LexExamplePatch exampleguid="3fff38c2-5258-4ece-b93c-039d2db3368e">
	<ExampleText>
		<AStr ws="jii">
			<Run ws="jii">ané walaalkis ba'ané</Run>
		</AStr>
	</ExampleText>
	<LexEntText>
		<AUni ws="jii">ba'adh</AUni>
	</LexEntText>
	<LexCitationText>
		<AUni ws="jii">ba'adhaal</AUni>
	</LexCitationText>
	<LexEntVarText>
		<AUni ws="jii">badhaal</AUni>
	</LexEntVarText>
	<LexAlloText>
		<AUni ws="jii">ba'a</AUni>
	</LexAlloText>
</LexExamplePatch>
````
In the patch file, the entire patch entry is on one line to make it easier to do edits. For example a perl one-liner can then do a regular expression substitute on each line of the patch file.

The *FWExampleEdit.pl* script finds the \<rt\> with *class* attribute = "LexExampleSentence" and *guid* attribute is the same as the exampleguid in the patch node.
In that \<rt\>, the rtext in the \<Example\> sub-node will be changed to the text in \<ExampleText\> of the current patch.
##### Task 1:
Change all Example Sentences with *Strong* styled text to *Headword-in-Example* style. Note that the patch program that the *FWExampleEdit.pl* reads must be an XML file. That is why we head/tail the first/last lines of the patch file built by *FWExampleExtract.pl*
```bash
perl ./FWExampleExtract.pl >Nkonyafwdata.full.patch.xml
head -1 Nkonyafwdata.full.patch >Nkonyafwdata.patch.xml
grep 'namedStyle="Strong"' Nkonyafwdata.full.patch.xml |perl -pe 's/namedStyle="Strong"/namedStyle="Headword-in-Example"/g;' >>Nkonyafwdata.patch.xml
tail -1 Nkonyafwdata.full.patch.xml >>Nkonyafwdata.patch.xml
perl ./FWExampleEdit.pl
```
##### Task 2:
Extract all sentences where the Example sentence doesn't already have "Headword-in-Example" highlighting. From those sentences, find all the sentences where the Lexical headword doesn't appear exactly in the Example sentence. Display all those that start with the letters b-f (no c's). For simplicity of viewing, all XML markup on the sentence is deleted. This ruins the output for input into the ExampleEdit. 
```bash
grep -v Headwo Nkonyafwdata.full.patch.xml |perl -ne 'if (!/(?<=\<LexEntText><AUni ws="nko">)([^<]+)<.*?\1/i) { print  }'  |perl -pe 's/<(.)?(LexExamplePatch|AUni|AStr|Run)[^>]*>//g;' |sort |grep 'LexEntText>[bdeɛf]' |less
```
Bug: the match on \1 should only be inside *\<ExampleText\>* The above matches Headwords that are subsets of Variant texts.

This script shouldn't be a one-liner and the complex regex should maybe use a /x to put the various parts on separate lines Like:
```
(! #match not
	/(?<=\<LexEntText><AUni ws="nko">)  # start at lexeme tag
	([^<]+)<# lexeme stops at < of trailing XML
	.*?\1 # see Bug --should be  .*?\<ExampleText>.*?\1
	/ix)
```
##### Task 3:
Same as Task 2 checking Citations, Variants and Allomorphs &ndash; this is more complicated because two or more  or variants or allomorphs can occur so it can't be done by a simple regex backrefence (\1) in the search.
The perl script *ApplyHIghlight.pl* makes the necessary changes to the patch file.

*ApplyHIghlight.pl* looks in the Example sentence for an occurrence of any of the following:
 - citation form
 - lexeme form
 - variant forms
 - allomorph forms

 in that order.

When it finds one, It applies the highlighting style "Headword-in-Example" to all occurences that text.
The name of the highlight style can be changed by modifying *namedStyle* attribute of the XML code assigned to the variable *\$highlightfront* at the beginning of the *ApplyHIghlight.pl* script.
It needs to match the name of the Highlight style in the FLEx project.

If more than one of the search texts occurs, only the occurences of the first match will be highlighted.
Some short forms may occur as a sub-string in the XML code in the Example text node.
They will be ignored and an error message will be written to the STDERR stream.

Note that affixes are handled as text with no context. For example with '**-er**', the highlighted version of 'eraser' would be '**er**as**er**'.

If the Example sentence text has XML code (e.g. other highlighting) inside a match, it will not find that match.

*xml2htmlForPatches.xsl*, *prehtml.pl*, and *posthtml.pl*  are helper scripts for displaying Example sentences together with the head word, allophones and variants.
