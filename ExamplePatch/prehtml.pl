# perl -pf ./prehtml.pl <patch.xml
# </AUni></LexEntVarText><LexEntVarText><AUni ws="jii">
s{..AUni...LexEntVarText..LexEntVarText..AUni ws.......}{_br_}g;
 #</AUni></LexAlloText><LexAlloText><AUni ws="jii">
s{..AUni...LexAlloText..LexAlloText..AUni ws=......}{_br_}g;
 #</Run><Run namedStyle="Headword-in-Example" ws="jii">
s{..Run..Run namedStyle..Headword.in.Example. ws.......}{_markstart_}g;
 #</Run><Run ws="jii">
s{..Run..Run ws.......}{_markend_}g;
