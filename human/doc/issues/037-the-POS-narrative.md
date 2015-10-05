# the parts of speech narative :[#037]

## introduction

Welcome to the deep, dark underbelly of Skylab hacked natural language
production. At its essence this node exposes publicly visible classes
that enable you to make mutable `productions` of `phrases` or `lexemes`.

(currently the conception of `phrase` and `production` are merged into
one "thing", but this is not guaranteed to stay this way).

The goal of this is simply to get things like subject-verb agreement
on-the-fly for a phrase with as little or as much hackery is necessary

  • to produce surface representations (for now, textual output)
    that read "correctly" (and hopefully "naturally", but see below)

  • from a codebase that can be skimmed over in one sitting

  • and does not rely on external datastores (like real lexicons).

so this work is both a hypothetical stand-in for such a thing should we
ever decide to try to use one; and it is an exploratory prototype sandbox
for us to play with the sort of simplifications and generalizations we
might like to see in the API of one.

as for trying to sound natural, see [#xxx].




## self-imposed and emergent design rules

  • what we will refer to conceptually as "productions" may or may
    not be implemented in code as "phrases". regarless, the fundamental
    operations of these "productions" is that they are sometimes mutable
    and that they are always capable of expressing themselves into strings.
    a "phrase structure" is a perfect name for this. (this is when we
    changed the name of the support library.)

  • a production may exhibit the "null expression": it may expesss
    itself by saying nothing.

  • productions will probably relate somewhere between "somewhat" and
    "strongly" to "syntactic categories": the componentiation (that is,
    how we implement them as classes, etc) of productions will probably
    have counterparts as a subset of the constituency (that is, the set
    of all) syntactic categories identified in the popular literature.

  • more concretely: we implement at least a "verb" syntactic category
    and "noun" syntactic category, each as one class. each class has its
    own phrase class. phrase classes are where most of the activity
    takes place.

  • some productions will be able to hold other productions as data.
    formally their relationship is in a cyclic directed graph, where a
    production may be able to hold other "instances" of its same "class"
    infinitely so. (a noun phrase can be built by co-joining two other
    noun phrases with "and" and so on and so on infinitely so) ..

  • however, the production's data-structures themselves are not
    cyclic: a production will never reference itself through any number
    of degrees of seperation. ergo, productions are all "trees"
    (allowing that the tree may be a leaf node that does not accept
    children).

  • see all the corollaries to #the-axiom-of-nun-redundant-state here:


## :#the-axiom-of-non-redundant state

some productions (likely those that are mutable) will hold grammatical/
semantic "state" such as lemma and grammatical category exponents.

in contrast to previous versions of this library, we no longer "trickle
down" state changes to relevant child nodes those that happen in parent
nodes.

rather we represent this data non-redundantly. the child that gets
inflected by a grammatical category that a possible parent may also be
inflected by *must* determine this exponent via the parent (somehow).

for example, imagine that there is one production implementation for
something like "noun phrase" and another production implemenation for
something like "pronoun". imagine further that they are in a
parent-child relationship (although do not take this as given!).

let the generic "noun phrase" production "hold" the state ("exponent")
of the grammatical category `number` (i.e `singular` or `plural`
(maybe nil?)).

imagine that the pronoun production is trying to express itself.
pronouns in english can exhibit inflection by number ("I" vs. "we",
"she" vs. "they" etc). as such, given that it is the parent (noun phrase)
that "holds" the state for number, the child (pronoun) *must* determine
the relevant number exponent to inflect against by asking the parent.

the way this is implemented is that the relevant parent is passed to the
child as an arugment to the relevant method call, so hypothetically
a "child" phrase structure could inflect against any aribtrary other
phrase structure provided that it "looks like" the correct semantic
category.

we make this change so that there is a single discrete and certain
location where any given particular grammatical category's exponent is
held, which is intended to makes things less error prone and keeps our
interfaces (and interactions) more consistent.

some corollaries of this:

  • phrase structures that derive inflection from their "parent" (or
    otherwise outside of themselves) must have a handle on this
    structure (at that moment) to inflect themselves.

    e.g: a verb phrase in english must know (or assume defaults for)
    (for starters) `number`, `person` and `tense` in order to express
    itself. currently it is implemented such that the grammatical category
    of `tense` "belongs to" the verb phrase (and ergo only the verb
    phrase). `number` and `person`, however, are seen as properties of a
    noun phrase (and ergo only a noun phrase). so for a verb phrase to
    express itself it *must* do so with a handle on something that can
    provide values ("exponents") for the above two grammatical categories.

  • for such a phrase structure that may want to mutate the relevant state
    of any grammatical categories that effect it, it will actually have
    to (somehow) inflect those phrase structures (or simply "exponent
    havers") outside of itself. an implementation of this is tagged with
    :#corollary-two.




## a :#philosophy-of-why-oneliners

for the client to arrive at a surface production using the core
library's interface alone is typically a multi-step process: the
phrase structure ("production") is built, some components of the
production are inflected directly (e.g with the `<<` method) and
(either at one point or more interestingly multiple points) methods
are called to produce a surface form.

while this workflow is well-suited (arguably perfectly suited) for
working with phrase structures as they are, it is overblown to ask
the client to go through all these steps if all she wants to do is
add an 's' to the end of a string.

using the "oneliners" comes with a tradeoff: the client must know
the name of the transformation rule she wants to employ for
(variously) the argument noun or verb.

rules that inflect based on number will typically (but not
necessariliy) take a number-ish argument (e.g integer, maybe array)
as an *option*. not providing this argument at all will probably
effect a defaulting of `plural` for the resultant exponent, because
in english you typically wouldn't need the inflection this library
provides unless for example you were trying to get the plural form
for a dynamic string (because the singular form for most words in
english is the same as the lemma).

the adapters fall into two categories: functions, and ..er.. adapters.
the functions are self-explanatory: always you pass a string and
get an inflected string back. (some take a number-ish optional argument
pursuant to the explanation above.)

the "adapters" (better name needed) wrap around one lemma and expose
methods for transformation rules. calling the method results in the
produced surface string. effectively these adapters bring you down to
two steps from three, in contrast to the functions that bring you down
to one. this is an interface best suited to particular expressing clients
where the lemma is determined early but the desired form is not know
until later, e.g [#br-016].




## :#the-pronoun-gateway-hack

in the spirit of this whole library, this is a convenient while
icky "macro" that hard codes the below magic meaning to the lemma
"it", which allows us to interpret long strings that end in 'it'
more usefully.

we are giving "it" special meaning as a macro, that is not associated
with the other pronouns ("her" etc).

_
