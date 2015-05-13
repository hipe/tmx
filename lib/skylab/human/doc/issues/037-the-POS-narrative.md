# the parts of speec narative :[#037]

## introduction to the new edition

( most of this text is from the original inline comments that go back more
than two years before the creation of this document. )




## introduction

Welcome to the deep, dark underbelly of Skylab hacked natural language
production. At its essence this node exposes publicly visible classes
that enable you to make mutable `productions` of `phrases` or `lexemes`.

The goal of this is simply to get things like subject-verb agreement
on-the-fly for a sentence with as little hackery is necessary to get
this to fit all in one file of semi-resonable length, as a proof of concept.




## :#introduction-to-the-lexeme

the wikipedia explanation of "lexeme" is pretty much spot on with
our intention here. but for the impatient, "lexeme" more or less
means "word".

familiarity with the following terms from the above source is recommended
and will be assumed in comments & code (in fact the whole architecture is
based on):

    • lexicon
    • lexeme
    • grammatical category
    • exponent
    • form

more loosely we will dance around with ideas of `syntactic categories` and
`phrase structure grammars` but attotw we know less what we are doing there.

more specifically, a "lexeme" subclass will generally represent one
syntactic category and one inflection paradigm. we don't expect to
make too many of these, possibly just two.

(historical note - this class used to be a hacked subclass of ::String!!)

We document our journey as a narrative and riveting story. we start from
the beginning (one of them, anyway): with your new lexeme class (we won't
make that many of them), you define its
grammatical categories, at its essence a two dimensional structure:
a simple hash with simple array values, each array containing symbols.
see you at next storypoint! (storypoints have leading capital letters).




## :#defining-production-strategies

Then with the lexeme class we want to define default production
strategies (regular forms). we are simply associating a combination of
(often 1) exponent (like :preterite) with one hacky rendering strategy
(like "add -'ed' to the lemma").

(if you are familiar, `as` is a lot like ::Rspec's `let`, the main
difference being it memoizes to an ivar named after the property rather
than writing to e.g. `@memoized_`.)




## :#irregular-production-strategies

When we make a lexeme with irregular production strategies (which
we will need to do for the most common verbs, because the most common
verbs are in fact irregular because of some linguistic phenomenon
with some name that more broadly exhibits one of natural language's
anti-optimalities from a computational perspective. yes i'm arguing
that we should all speak Lojban.), when we make such a lexeme we
need some place to put it so that it Just Works when we later go
to use it, e.g in a sentence. That place is called a...

(note that for now too a lexicon is associated with a lexeme class
(syntactic category!?) as zero-or-one lexicon *per* *lexeme* *class*
so e.g there will be one lexicon with nouns and *another* with e.g
verbs. this is for ease of implementation because we take tagged
input, and are only doing crude NL production and not (yet) NL
processing; but keep in mind we might flip it, reverse it, or
aggregate syntactic cateogry lexicons into a more bigger one.)




## :#with-these-lexemes

Now that we have some lexemes, with grammatical categories and exponents,
and those lexems are stored in a lexicon related to syntactic categories
which are themselves lexeme subclasses (whew!), we might want to actually
make a "production" of a lexeme. we do that with the `produce` method.




## :#the-production-class

(the production class is produced lazily at time of first request -
whatever the state is of the *categories* (not exponents) is at that
time will get baked in to the class (and subsequent categories will
not make it into the class as setters).)




## :#semicollapse

given the `combination` (that is a structure-like combination of grammatical
category exponents), resolve some kind of string expressing perhaps fuzzily
the grammatical category / exponent combination (e.g. "her or his") based on
the set of regular and any irregular forms or this lexeme. (this nerk happens
to be the centerpiece of this whole endeavor. it was the novelty algorithm
that became the raison d'etre of this whole nerkiss around you now)




## :#we-can-optimize

(we can either optimize this for speed or for memory: because slow
language production is a good problem to have, and not one we *do*
yet have, *and* because it's nice having readable dumps of the
object graph, we opt for the latter, possibly re-creating the bound
method for regular forms each time the lexeme is collapsed: meh.)
_
