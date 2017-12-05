# (needs a name) :[#004]

## intro

Files in this folder are FLEX- and YACC- style grammar specifications that are
run through flex2treetop and yacc2treetop to generate treetop grammars
that are for now stored in a tmp directory determined by a configuration
parameter.




# the listing

README             - this file
css-file.treetop   - NOT USED - here for reference (see [#here.B])
css2.1.flex        - in "PARSERS"
css2.1.yacc3wc     - in "PARSERS"
node-classes.rb    - NOT USED - here for reference (see [#here.B])
selectors.yaccw3c  - sidestepping this for now. in PARSERS list
tokens.flex        - appears inferior to the other flex. in PARSERS list
xml-subset.treetop - NOT USED - and we need to get this not to be binary




## note :[#here.B]

we are doing forensics for actions that took place 3 years ago. what it
appears is that we begun the effort indicated by the files marked here,
and hit a wall with the difficult parts (the treetop rules that are empty.)

this proably sent us on our flex2tt and yacc2tt tangents




## document-meta

  - #pending-rename: to a proper document (or not)
