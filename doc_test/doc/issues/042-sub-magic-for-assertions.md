# notes for particular quickie view controllers :[#042]


## overview

this project’s “relationship to failure” has just flipped over into
its next phase of evolution - it used to be that we had a system that
was theoretically fail-proof. that is, it could process theoretically
*all* line streams and always do *something* (with “nothing” included
in “something”) to existing test documents, without the need ever to
encounter or report any errors that we knew of.

now, we A) begin to formalize our desire to fail at the document-
level for a certain pattern of ambiguity, and B) we acknowledge that
expressive, localized failure is the best option when dealing with
one particular (but perhaps others more generally) external
side-system for execution.

the main, concrete consequence of this is that we now go from a
purely cold model (or one that showed some strain towards wanting
but not having hot operations), to an operation stack that is
suffused with the passing of emission listeners everywhere so that
the application can hear back from any various low-level actors
that can variously emit failure (that is turned into an `info`
emission).




## intro

this started as a note about an edge case salve, but then it
expanded into a more general and more interesting treatment of
several intersecting issues, presented here as a series of
small case studies:

  1. what our chain of matcher-expressers is here (i.e what
     "sub-magical" means) as it pertains to expressing assertions.

  1. what happens if any one of them fails.

  1. what happens to our application when something
     (or anything) fails more generally.

  1. how we decode literal strings vis-a-vis sub-magical
     patterns.

  1. whether not this is a smell.




## what is "sub-magic" and what is our chain of matcher-expressers?

the code-node near [#here.B] is one of several "matcher-expressers" that
we traverse over in order, looking for the first one that matches.
(the following will serve as the definition of "matcher-expresser",
which we may refer to as simply "matcher" further down below.)

each matcher-expresser (in order) is concerned with first seeing if it
matches some data from the asset side (the shape of which doesn't
concern us here), and then secondly (if it matches), expressing the
particular kind of assertion in test-side code.

note that whichever first matcher-expresser matches, that is the
one that "wins", and the rest aren't even evaluated for that
particular input structure. note too that we arrange this "chain"
such that the last matcher-expresser *must match any input it gets*
so that it acts as a default case.

(this pattern should probably have a name, something like "matchers chain".)

the cornerstore of the whole [dt] stack, if it had to be expressed in
three characters, is "#=>". we call this character sequence (actually
a pattern, because you can use "# =>" too) "magic" (introduced briefly
at [#018]). this main element of magic generally becomes the
"equality assertion" on the test-side (the hopefully familiar pattern
of `expect( actual ).to eql expected` in r.s and quickie).

however, a pattern that is employed at writing only at the associated
code-node's matcher-chain is that of "sub-magic", which is our label
for the idea of a general category of magical expression (the things
that happen when you use "# =>") that has specific variations depending
on if other sub-patterns are employed within that super-pattern. this
probably makes no sense at this point.




## what are the "sub-magical patterns" here?

for the particular matcher in question, we're seeing if we parse
a string in the form of «"foo.."» (where the double quotes are
*part* of the string (and the guillemets are not), and the trailing
"dot dot" is also part of the string, but the "foo" is a
placeholder).

that is, we're seeing if we match a quoted string (actually single
*or* double quotes) whose content part ends with two literal dots.

(if we had the quoted string alone in a string, we might match
it with something like `/\A(?:".*\.\."|'.*\.\.')\z/`.)

(for this matcher-expresser, what we do if we match is besides
the point so we won't go into it here.)

the thing is, once we get into trying to parse asset-side (or
test side, for that matter) quoted strings, it's a bit non-trival
to the extent that we can't (or merely shouldn't) just do it with
a simple regex.

in fact, we have a whole library node for this in [ba]. and then
the thing about *this* is (to introduce what will become a theme
here), we attempt a semi-robust implementation of this effort
as a proof of concept prototype; however we leave known holes
because A) solving the problem (whatever it is) more completely is
not interesting to us, and B) and effort to do so would probably
carry us into out-of-scope territory (even for a library module),
depending. (more on this in a below section #here-1.)

whether or not this particular library *should* have an API for
failing is a bit oblique to our focus here (by choice). the idea
is that any library we might use *could* have an API for failure.
if it does, and then if our interaction with that library fails,
we have to decide what to do.




## what happens when a matcher-expresser fails :[#here.C]

towards a more general idea we will introduce #here-2 below, our
pattern for what to do if one (or more) of our matcher-expressers
fails is this:

  1. emit a *notice* (not *error*) that the matcher failed.

  1. move on to the next matcher.

this arrangement will always "work" provided that our final matcher
never fails. this arrangement is also ideal for us because it gives
the user feedback about possible reasons why a desired matcher is not
matching, will still producing *some* output. this is consistent with
a more general design tendency:




## what happens more generally when something in the application fails

just because of the way it happened to work out, with this particular
application we can theorize a version of it that would never fail.
(there is probably some name for grammars/whatevers like this.)

much like the regular expression `//` will match all strings, our
application will (in theory) parse all input streams of strings. if it
doesn't find any "magic" in the input "document", its maps to an empty
output stream of stem components (see [#039] the pipeline overview),
which in theory shouldn't cause the rest of the system to fail.

this theory held up surprisingly well - for at least the first 18 of our
25 real-world cases. the only time this model faced a real challenge
was when it came time to deal with cases like these:

  - external side-systems failing.

  - input patterns that we chose to classify as
    "probably unintend anomolies/irrecoverable ambiguities" rather
    than ignore.

this document is concerned primarily with the former case, but the
behavior we describe here also covers our solution for the latter
category of cases, which we describe along the way and is tagged as
:[#043].

how it's working out now is that every kind of failure is forseeable
and we can design it such that it falls into a certain designed category
that we think of as having a certain designed "scope" and expression.

  - for the failure that is the catalyst subject of this document,
    this is a failure of a relatively small scope that we recover
    from locally as we describe at [#here.C].

  - for a failure of the type referenced by [#043], at writing this is
    designed to be a document-level failure. that is, upon encountering
    such a failure in a given document, we "fail out" of processing that
    document (the target file being presumably not clobbered at all
    until the end, it is probably written to one big string as an
    intermediary); however this failure won't cause the broader recursive
    operation to fail; rather that document will have the effect of
    being skipped with an emission explaining the local failure.

    note this means that that such an operation is not "atomic" at
    the filesystem-tree level, only at the document level.




## about out of scope :#here-1

as it would work out, the external library's relationship to
failure (i.e its "failure API") is analogous to the general
workaround-philosophy (if not the architectural underpinnings)
of this project.

the [#002] "ersatz parser" embodies this same sort of "leap of faith" -
for yet another analogy, consider the syntax-highlighter of your
editor or IDE (if any). whetheter it's vim, emacs, some GUI for mac,
some other editor, or a full-blown IDE; it probably offers syntax
hightlighting for the particular document type(s) you edit.

furthermore (and this part we're more shaky on), this syntax
highlighting facility probably does *not* use the actual interpreter
or parser for your target platform. (all of the editing environments
i mentioned have the ability to hook into your iterpreter or parser to
do syntax checks using the real target platfrrom, but i'm just talking
about syntax highlighting alone, not syntax checking.)

syntax highlighting for a particular language is usually built into
a bundle or plugin for that particular editor/IDE, and this bundle
is usually composed of a collection of regexes and keywords and syntactic
categories, etc. (EDIT)
