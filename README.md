# FWPatches to do sophisticated edits in a FLEx database
This repo contains pairs of scripts to handle patch files for various fields within a FLEx database.
Each script pair includes an extract script that builds a patch file and an Edit script that applies a patch file to the database.
The patch file can be edited to make corrections in relevant fields.
The patch file is an XML file with one patch per line to facilitate grepping.
Some example tasks are described in ExamplePatch/ExampleSentence/README.md

- *ExamplePatch* - scripts to modify the Example sentences in a FLEx database. This is the most detailed and complex of the patch sets.
- *DefinitionsPatch* - scripts to modify the definitions in senses in  a FLEx database
- *TranslationPatch* -scripts to modify the translations of Example Sentences in  a FLEx database

This repo was migrated from Wes Peacock's Nkonya dictionary Script directory in August 2019
