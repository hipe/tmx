# the option parsing substitution hack  :[#074]


## introduction

parse e.g -1, -2

this naive implementation simply scans the whole argument array for
any first token that matches any of the regexes in the client-
provided substitution rules.

if any such token is found, it is replaced with the *zero to many*
tokens produced when the matchdata is passed to the rule's substitution
proc.

partial example:

    subject_class.new your_option_parser,

      %r(^-(?<num>\d+)$),

      -> md do
        [ '--max-count', md[ :num ] ]
      end

the above psedodcode fragment suggests a way to produce an option-
parser-ish that replaces tokens like "-1", "-2" etc with the
multiple tokens [ "--max-count", "1" ], [ "--max-count", "2" ] etc.




## the self-aware nature

after any substitution rule is used, these search-and-substitute
steps are then repeated from the beginning, allowing (hypothetically)
for substitution rules to feed into each other (either intentionally
or otherwise).

this substitution loop stops when there are no matching substituion
rules against the mutated input in its current state.

also hypothetically, infinite loops are certainly possible. this
facility only ensures that your substitution changes the token it
matched on. it cannot easily ensure that your inter-operating rules
do not keep invoking each other.

it bears mentioning that of all of the described behavior in this
section (both positive and negative), none of it has even been seen
"in the wild" in years, much less covered by any tests.




## limitations

this is not integrated into the stdlib option parser per se. rather,
at its essence it is just a simple search-and-replace that happens
right before a stdlib (or otherwise) option parser gets to see the
input array.

given that this substition happens earlier on the pipeline than does
the parsing of arguments for options that take arguments, when using
this facility you will never be able to pass as arguments tokens
that match any of your substitution rules.





## history

this hack originated in [sg] years before the creation of this document;
and was abstracted from there.
_
