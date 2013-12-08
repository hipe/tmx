# headless testing conventions :[#133]

## we don't say "should" in tests, we use noun phrases or sentence phrases

saying "should" in a test description string is redundant: every single
of the almost 2000 tests we have currently could probably contain "should"
in them, so it doesn't add any value, and furthermore adds cognitive noise
when we are reading verbose test output.

#todo it would be interesting to review the different patterns for naming
we have assumed.



## "-" in a test description name typically separates the ..

..description of the test setup from the description of the expected outcome.
for example:

    it "with valid input - renders correctly"



## "o", "x" and "X"

you may see the single letters "o", "x", and "X" appear at the end of test
description strings, for example:

    it "with a correct argument - o" do  # ...
    it "with a bad argument - x" do  # ...

this is just now developing - it is a shorthand: "o" means "ok", it means
that the operation being performed was expect to result in a soft success.
"x" means a soft failure, i.e something that the UI would report back to
the user. "X" means a hard failure, i.e something that raises an exception.

in older tests we would sometimes use the verbs "whine" or "complain" to
express what is now symbolized with "x"; and we would sometimes say "bork"
to say what is expressed by "X"


## the canonoical numbers for CLI arguments :[#134]

because we so often test the same different permutations for CLI arguments
for the various classes of syntaxes that exist, we developed a shorthand
(whose primary function, incidentally, is to assist us in determining if we
forgot to test any important permutations).

the convention is supposed to be mnenomic; that is, once you've learned the
high-level rules once you may be able to re-construct the detail in your head
later without necessarily having to look this up in reference.

the convention revolves around usually two terms. it is a semi-formal notation
that looks something like this:

  it "X.Y) when foo is bar - o"

the "X" term is a positive integer counting the number of arguments being
passed. the "Y" term is usually a "1", "2", "3", or "4" that describes
the last argument being passed, with meanings described below.

when we are passing zero arguments to a CLI, there will only be one term
in our identifer, because there are no arguments to describe.

despite our convention, whenever there is room left over in the line we may
chose to provide a fuller description (redundant with the identifier):

    it "0)   no arguments - o" do  # for the no-arg syntax
    it "0)   no arguments - missing required argument" do  # for the 1-arg

when we get to passing in one argument it starts to get interesting. here
is the mnenomic for remembering what "1", "2", "3" and "4" mean: there are
two high level axes we care about: one is whether the actual term is an option
or an (non-option) argument, and two is whether that term is valid or invalid.

take for example a commonplace git invocation:

    git log -3 .

'git' is a command, 'log' is a sub-command (we might call "git log" the
"terminal action" here because we like to think of applications as trees; in
actuality it is more likely that "git-log" is the standalone command and part
of a flat list of many many git commands). "-3" is an option, and "." is
an argument.

OK, so among the two axes of "valid vs. invalid" and "option vs. argument",
any given single "argument" (sorry) can have one of four permutations, that
correspond to the four numbers.

here is the part where it gets mnemonicy: if we had a random string generator
that spit out random terms (and this is what we imagine we are doing when
writing tests), the 'Y' numbers correspond to the four categories that those
strings would fall into, ordered by liklihood they are to occur (descending):

1) an invalid "argument"-looking string (i.e not staring with a dash)
2) an invalid "option"-looking string (i.e starting with a dash)
3) a valid (non-option) argument term
4) a valid option term

(granted, it is a bit arbitrary and dependent on the particular syntax whether
or not for e.g an invalid option-looking term is more likely to occur before
a valid argument term, but as a point of workflow, because we always start
our test driving with "input most likely to occur" and in this case it is
an invalid argument (so we are already testing for we), we decide to round out
the invalid categories before moving on to valid input).

hence:     "0)    (no arguments)"
           "1.1)  (one argument, invalid)"
           "1.2)  (one option, the option is invalid)"
           "1.3)  (one argument, the argument is valid)"
           "1.4)  (one option, the option is valid)"

sometimes we may even take it to the next level, to cover permutations for
options that themselves take arguments (either required-ly or optionally!)
(remember that the first term simply counts the number of arguments:)

           "2.4.1) (one option with one argument passed, arg is invalid)"
_
