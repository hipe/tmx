# approaching a pattern langauge for semantic structures

in the treatise _Categories_, Aristotle analyzed the differences between
classes and objects. woah. mind blown. Aristotle was an information
architect! [1]

even more relevant to us might be the approach that Plato took, the one off of
which Aristole's above work was based: in Plato's _Statesman_ he "introduces
the approach of grouping objects based on their similar properties." [2][3]

## perfect is the enemy of good

with or without Plato and Aristotle we - in our software and in our minds -
are developing a system for representing and transforming information. while
we have no doubt that our effort to document "The API API" [#fa-022] would be
bolstered significantly by putting it into a context within the state of
the discipline of categorization as it pertains to machine learning, this
document's primary purpose is to stand as a centralized manifest of
placeholders: we know these are not new ideas. furthermore we know that most
of these are probably not the "right" names for the ideas. but in the interest
of getting something done now with the intention of one day catching up on 25
centuries (wow!) of theory, but having neither the wherewithal nor foolishness
to frame the one as a precondition for the other; we offer this as "good
enough for now".

indeed, "Aristotle [..] propouned the principle of the golden mean which
counsels against extremism in general."[4]

[1] - Aristotle (1995). "Categories". In Barnes, Jonathan. The Complete Works
  of Aristotle, 2 vols. Transl. J. L. Ackrill. Princeton: Princeton University
  Press. pp. 3–24.
[2] - "Stateman_(dialogue)"
[3] - Plato (1892), "Dialogues, vol. 4 - Parmenides, Theaetetus,
w  Sophist, Statesman, Philebus", Transl. Benjamin Jowett
[4] - Tal Ben-Shahar (2009), The Pursuit of Perfect, McGraw Hill Professional,
  ISBN 978-0-07-160882-4

## introducing `categories` and `exponents` as we see them

this small calculus we are building (ontology more like it) has at its
foundation the concepts of a `category` :[#007] and its `exponents`.
now, defining words in any robust manner using solely other words is always
a chore. fortunately for us, our conception of `category` and `exponent` in
their relationship to each other is (for the sake of the discussion at this
point) perhaps perfectly isomorphic with the idea from linguistics of a
"grammatical category"[5] and its "exponents"[6].

take for example gender in the german language. every noun in german
"inherently carries one value of the grammatical category called gender."[7]
the possible values, or `exponents`, for this grammatical category in
this language are 'feminine', 'neuter', and 'masculine' (likewise for russian,
latin and sanskrit).

this one example above - gender in german - exhibits a huge swath of the
behavior we are interested in documenting of a `category` and its `exponents`,
so expect it to be referenced throughout this document.

to give it a loose working definition of these key ideas, (and note that
whenever a semi-formal definition is presented it is indented like so):

  an `exponent` is a value of a `category`. i.e an `exponent` belongs to
  a `category`. [#009]

this is an "ASCII semantic ERD" (entity relationship diagram) [#it-022].
note in our ERD's that a line with a circle at the end of it means
something like "is associated with many":

                      +----------+       +----------+
                      | category |------o| exponent |
                      +----------+       +----------+

conversely, we will define `category` circularly as:

  a `category` is defined with many (let's say one or more)
  `exponents`. :[#007]

(if there exist two exponents with the same names but in different categories,
they are different exponents, but see [#it-023])

## `categorization` vs `category`

  we will use `categorization` as distinct from `category` when we are talking
  about the application of an exponent from the category on a specific
  instance in particular, as opposed to the category in general.
  for example, "there exists a `category` in german called 'gender'.
  the german noun "Welt" ("world") has a gender `categorization` of
  `feminine`."

  `instance` is not defined formally (yet) but used generally to mean some
  unspecified entity that a `categorization` is applied to :[#025]

to review, and delineate explicitly some relationships that were only implied:

          +----------+     +----------------+     +----------+
          | category |----o| categorization |o----| instance |
          +----------+     +----------------+     +----------+

  a `categorization` is the application of one `category` to one `instance`.

  one `instace` may have multiple `categorizations`.

  one `category`, through its multiple `categorizations`, can be associated
  with multiple `instances`.

  conversely, one `instance` can belong to many `categories` through its
  many `categorizations`. (but not shown in the graph is that one instance
  is expected never to have more than one `categorization` from the same
  `category` :[#024].)

## what is the `categorization exponent arity` of your `category`?

if we jump back to the german example at the top, our source stated that
every noun "inherently carries _one_" exponent from the category (emphasis
mine). this statement obliquely expresses the valid sensical range for the
count of exponents in one such `categorization`: one.

Indeed, we lean further on linguistics theory, perhaps to jump off from it:

> A given constituent of an expression can normally take only one value from
a particular category. For example, a noun or noun phrase cannot be both
singular and plural, since these are both values of the category of number.
It can, however, be both plural and feminine, since these represent different
categories (number and gender).[5]

the above excerpt exemplifies what will prove to be several of the critical
questions we ask when modeling with our pattern language - questions like:
"what exponents are mutually exclusive to each other?", "what is the sensical
range for a number of exponents for an instance to have?".

when dealing with expressing the sensical range for a certain count in
general, we call that `arity` -- a concept that is introduced an explored
in [#fa-024]. to avoid a confusion that will become evident below, we will
always call this the `categorization exponent arity` because it represents
the sensical range for the count of exponents in a categorization.

so in the example, it does not occur in the 'domain space' of german nouns
that any noun exists with more than one gender, and never do nouns occur
with no gender (when 'neuter' is a gender), hence the number of genders any
noun has is always 1, hence `german noun gender` has an arity of 1.

using our pattern languages from this universe, we would say formally that
this category (gender) has an `categorization exponent arity` of 1, and as
such any given `categorization` (that is, application of this category to an
instance) will have exactly one exponent associated with it (i.e not zero,
not two or more).

Furthermore,

  we can describe a category that has an categorization exponent arity of 1
  as `unary`.  that is, "the `categorization` of gender in german is
  `unary`.". [#017]

Although the grammatical categories of linguistics are "normally mutually
exclusive within a given category" [5] (that is, you cannot normally use
more than one `exponent` in a categorization), (and of the categorizations of
machine learning we don't yet know what their arity is [#015]); in this
pattern language we allow for our `categorizations` to be possibly `N-ary`.

  an `N-ary` catgorization is a categorization whose
  `categorization exponent arity` is not 0 or 1. that is, the application of
  the category to a particular instance may use multiple unique exponents
  from the set of exponents defined by the category. :[#018] (but see note
  below).

again, in linguistics and perhaps too in machine learning, categories are
"usually" unary so this facet is not as often explicitly stated. but here
we want our conception of `category` to be sufficiently broad to have utility
in a variety of spaces, so we hence (for now) elect
`categorization exponent arity` as a variable property of `categorizations`.

however, for reasons that will become clear below, we still adopt `unary` as
the default asssumption, and that `N-ary` is the "marked" `exponent` of the
pair: so if the `categorization exponent arity` of the category is not stated,
it is generally safe to assume it is `unary`.

(note: in the interest of centralizing our theroy into an optimally small
number of "places", we are for now going with this broad definition of
categorization, that it may be either `unary` or `N-ary`, with `unary` being
the default but `N-ary` begin possible. however, there is a chance that if
a) we find that in The Literature [#015] "category" almost always
means `unary`, and / or if we decide to merge our nascent "field theory"
[#fa-013] into this, we may decide that `category` is a subset of `field` --
that subset of `field` with an `categorization exponent arity` of 1. but for
now, in our head at least, we are painting it as that `field` is a concrete
implementation of the `category` theory we are building here. :[#020])

a naive application of this principle could be found by modeling a video game
rating sytem in this way: there is a `N-ary` `category` called 'rating' whose
`exponents` are defined as 'violence' and 'strong language'. a given video
game `instance` might have both, none, or only one of these `exponents`
apply to it in its `categorization`, hence we want its categorizations to
be `N-ary` and not `unary`.

pizza toppings for a particular pizza could likewise be modeled naively
in this way. pizza can have multiple topings, a toping is a discrete, atomic
thing from a pre-determined finite set of things: we could say there is a
'toppings' category that is `N-ary`.

the question of whether a given categorization should be `unary` or `N-ary`
can lead to some interesting side-effect questions about the domain you
may be creating or trying to model: imagine we are designing the AI for a
video game and we have to model the 'mood' of individual agents in the
system (think "the Sims").

to this end we'll make a `category` 'agent mood' that includes the `exponents`
'happy' and 'sad'. should 'agent mood' be an `N-ary` or `unary` category?
well, is it possible for an agent to be simultaneously happy *and* sad?
is it possible for agents to possess multiple moods at the same time?
it becomes a fun design problem that can give insight into an optimal
design for the domain based on the desired behavior of the model.

## who's arity is it, anyway?

to paint a facet of this relationship in more detail between `arity`,
`category` and `categorization`: we furthermore offer that the
`categorization exponent arity` in question (that is, the sensical range of
the count of exponents that may be used in a `categorization`) is a property
of the `category`, not the `categorization` :[#019].

that is, we must define a `category` too by its
`categorization exponent arity` as well as by its `exponents`. the
`categorization exponent arity` that `category` has applies to every of its
`categorizations`.

to take it back to german again, remember that we said that the gender
category of nouns is `unary`. we couldn't for example decide that there is
a certain class of words that can have multiple genders, while other cannot.
we would need to construct a whole new category for that, or redefine the
original category itself.

note this this facet (of `categorization exponent arity` being instrinsic to
`category`) is offered only for the sake of completeness and is not a
requisite part of the pattern language. if it is useful to do so we may
change this. but both alternate universes are isometric (that is, it is two
different ways of doing the same thing, and we can switch back and forth
between one way and the other trivially) so the point might be moot.

                      +----------+     +----------------+
                      | category |----o| categorization |
                      +----+-----+     +-------+--------+
                           |      \            ?
                      +----+-----+ \   +-------+--------+
                      | cat. exp.|  +-o| exponent       |
                      | arity    |     +----------------+
                      +----------+

  a `category` is defined by one `categorization exponent arity` and
  many `exponents`.

  a `categorization` will have some number of those same `exponents`
  associated with it, the number being constrained by the
  `categorization exponent arity` of the `category`.

[5] - "Grammatical_category" (wikipedia)
[6] - "Exponent_(linguistics)"
[7] - "Grammatical_gender"

## must we always be so discrete?

another fun facet that was grazed lightly above is again hidden again in that
word "one" in "every noun in german inherently carries one value of the
grammatical category called gender."

keep that in mind while we consider a different example: used cars.

imagine a used car salesman who has been observing the ebb and flow of her
business over the past few years. she wants to acquire a new dealership,
but she must start this process years in advance, and she wants to do it
only in a year when she can get a loan from the bank with an optimal APR.
how good her APR will be depends on how good her balance sheets look for the
last few years.

based on her years of observing consumer spending habbits, she has a
complicated theoretical formula in her head for how well her business does
in a given fiscal year. the formula relates, among other metrics, real estate
prices in her area to the GDP, to whether the dodgers are doing well that year.

she wants to test her formula to see how accurate a predictor it is of her
revenue, but to do this she must first index all of the cars in her lot with
something she suspects is a key metric: "new-ness". (she suspects that newer-
seeming cars sell proportionally better when both the real-estate values are
relatively high (but dropping) *and* when the dodgers are doing well.)

if we are trying to model this domain with the pattern language we have
developed so far, we might offer that 'new-seeming' and 'used-seeming'
are two `exponents` of a `category` we will call 'new-ness'. (fun fact:
the words we use for exponents are often adjectives, while the words we
use for categories are often nouns.)

so, can the used car salesman walk up to any given car in her lot and say
definitively whether it is 'new-seeming' or 'used-seeming'? maybe. but it is
optimal for her to represent this metric in these terms? or is it perhaps more
useful to model "new-ness" on a scale of e.g. 1 thru 5, or zero to one
hundred, etc?

if we are using numbers to represent her perceived 'new-ness' of a car (or
more usefully, her prediction of the perception of the 'new-ness' of any car
in the eyes of her average customer..) if we are using numbers to represent
this metric, we could even decide to use any non-negative real number, or hey,
it could be *any* real number, if all we were doing was a comparative
analysis, and maybe we were going to normalize the data later.

to express this dynamic formally in our pattern language, we will borrow two
terms from mathematics: `discrete` and `continuous`. but before we reveal
definitions for those, let's jump back to the german example:

imagine we can access the twitter "firehose" of all tweets in the universe
as they are happening in real-time. (this exists. it's expensive.)

imagine further that we are somehow able to resolve discretely (yes!) for
each tweet, one natural language from a finite set representing every natural
language. (we need to suspend our understanding of the real world quite a bit
for this hypothetical.)

let's imagine further that we can parse each such german tweet into a list
of one or more "words". (german is an agglutinizing language so perhaps
unsurprisingly words don't delineate in quite the same way as in english,
i.e nouns get long and scary looking.) can we tag any given word from this
process as either a noun or not a noun? let's presume that the answer is
"almost always yes" (because we have to allow for the possibly of some
ambiguity and stochastics, with for e.g wierd new emoticons that look like
words, and/or acronyms, neologisms, slang, unparsable senteces, etc).

http://www.link.cs.cmu.edu/link/submit-sentence-4.html

now, after having performed the most epic map-reduce function in the history
of computational socio-linguistics: with any of these nouns, can we tag each
one as either feminine, neuter, or masculine? we expect here that the answer
is "yes. very yes." why?  because it's almost a tautology: a noun in german
*must* have a gender. if it doesn't, it's not a noun. this is what language
does. this particular grammatical category is baked deep into this particular
language at this moment in its history.

to frame this in terms of the new additions to our pattern language, we
say that the `category` of `gender` in german nouns is `discrete` - that is,
any given noun in german must be *exactly* one gender, not some combination
of genders, or partially one gender.

but when we jump back into the used car lot, we are saying that the 'new-ness'
of any given car is *not* `discrete` - it will be respresented as some value
on a scale. we call this kind of category `continuous`. note we still call
'new-ness' a `category`, and indeed *still* call 'new-seeming' and
'used-seeming' `exponents` (although this particular point is *very*
experimental :[#021] .. we are considering calling them 'waypoints'..)

our general litmus test for whether or not a category is `discrete` is:
"can we hold up any instance (of some relevant scope) against each exponent
of our category and resolve a defininte 'yes' or 'no'?"

(it is worth mentioning that when implementing any `continous` `category`
with computers, the representation of its values will ultimately be `discrete`
(because digital information is a kind of discrete information). (indeed
"digital physics" is a relevant perspective here [8].) however as will become
clear below, the `meta-categorization` of 'continuity' is useful because of
the different sets of functions it suggests for instances tagged by its
different `exponents`)

[8] - "Digital_physics" (wikipedia)

now, to place `discrete` and `continuous` into our existing framework
pseudo-formally, we will attempt something interesting and fun:

## are we self-supporting yet?

given the concepts of our pattern language that have introduced and pseudo-
defined thus far, we can now attempt to define further elements of the
pattern language using the pattern language itself.

hopefully this won't be too jarring because for each new concept introduced,
the definition of the concept for all practical purposes will also be in plain
language with examples. but what we proffer is that we have defined the pattern
langauge formally enough that we can start using the language formally for
definitions.

what we are after is to eat our own dogfood that is made of our own body.
what we are after is auto-trans-substantiation.

So, let's review and build off of what we "know" (more aptly, what tools we
have so far built for ourselves):

                    +-----------------------+    +----------+
                    |      continuity       |--->| category |
                    +----------+------------+    +----------+
                    | discrete | continuous |
                    +----------+------------+

we can model `discrete` and `continuous` as the only two exponents of a
category that we will call 'continuity'. (we can draw a category and its
exponents this way - with smaller squares inside of a bigger square. an
arrow generally means 'IS-A'.)

because 'continuity' has exactly two exponents, we can describe it as `binary`.

    `binary` is shorthand adjective that describes a `category` with
    exactly two `exponents`. a category that matches this criteria and some
    others exhibits a certain set of behavior we will explore below. :[#011]

regrettably, `binary` and `unary` may sound like they describe the same axis,
but they do not. `unary` describes a commonly occuring and interesting count
for the `categorization exponent arity` of a category. `binary` describes a
commonly occuring and interesting count for the *number of exponents* of a
category. we would not use such confusing names were it not for their
conciseness and the utility of what they represent.

when we get confused, it helps to remember that there are different
counts that we can derive for a `category`: one is the count of its exponents,
and another is the `arity` (which sometimes looks like a counting number) of
the elements of one of its categorizations.

remember, too, that `unary` is the default when not specified, so that we can
avoid ever having to describe a `category` as `unary binary` (or `binary`
`unary` if you prefer) even though by the above definition, this pairing
of descriptors is in fact sensical (indeed commonplace in our models).

(so much so, in fact, that we should probably reserve the use of `binary`
for *only* when the category is also `unary`!)

when we want to indicate a `categorization` in a graph verbosely, we can do
that with a simple line connecting the `exponent` with the `instance`:

 +-------------------------------+
 |    gender of a german noun    |
 +-----------+--------+----------+    +----------------+     +-------------+
 | masculine | neuter | feminine |----| "Welt" (world) |---->| german noun |
 +-----------+--------+----------+    +----------------+     +-------------+


"Welt" is a german noun whose gender is feminine. (since the `category space`
of grammatical categories generally has `exponents` that are unique within
that space, we can probably say more succinctly but still unambiguously,
'"Welt" is a feminine german noun' -- that is, we do not need to state the
name of the category explicitly, even though it is still there [#023].)

back to putting 'continuity' into our self-supporting ontology: if it's
useful or fun, we can say that `continuity` is not just a category
but a `meta-category` (which is, in turn, a category):

      +-----------------------+    +---------------+    +----------+
      |      continuity       |--->| meta-category |--->| category |
      +----------+------------+    +---------------+    +----------+
      | discrete | continuous |
      +----------+------------+

  let `meta-category` describe a `category` whose target instances are
  themselves other `categories`. that is, a `meta-category` is a category
  that describes other `categories` :[#008].

remember above that we presented `unary` and `N-ary` as two mutually exclusive
ways to categorize the `categorization exponent arity` of a `category`? (can
the pizza have mutiple toppings? can the person have multiple moods? can the
noun have multiple genders? etc.)

we can now also model `categorization exponent arity` as a category (but note
that it is a `categorization` of the arity and not a representation of it -
it is lossy. arity representation is explored in [#fa-024].)

                  +-----------------+    +---------------+
                  | cat. exp. arity |--->| meta-category |
                  +-----------------+    +---------------+
                  | unary  |  N-ary |
                  +--------+--------+

  categorization exponent arity modeled (lossfully) as a binary meta-category.
  its two exponents are listed.

so we're saying that `continuity` is a `meta-category` *and*
`categorization exponent arity` is a `meta-category`. watch what happens now:

                              +---------------+    +----------+
                              | meta-category |--->| category |
                              +---------------+    +----------+
                                    ^  ^
         +-----------------------+  |  |  +-----------------+
         |      continuity       |  |  |  | cat. exp. arity |
         +-----------------------+--+  +--+-----------------+
         | continuous | discrete |        | unary  |  N-ary |
         +-----------------------+        +-----------------+

how many `categories` appear above? two. (note that 'IS-A' relationshps are
inherited from parent to child to grandchild, etc. not reflected in the graph
is the fact that `category` and `meta-category` are effectively abstract
base classes.)

how many `meta-categories` appear above? also two (the same two). what do
meta-catgories apply to? they apply to categories. hence the categories that
appear above serve as `instances` (targets) for the `meta-categories` that
appear above. so: how many `categorizations` do we get to model? ...

four. two categories * two instances. (we took some logical leaps to arrive
at that number so definitively - this has to do with the idea of category
`applicability` and `scope` ([#013], [#026]) which we haven't explored yet.)

let's start with the easier categorizations - the non-self-referential ones:

1) is 'continuity' 'unary' or 'N-ary'?

well what does continuity describe again? a category. can a category be
both 'unary' and 'N-ary'? modeling with this ontology will be *much easier*
if we say strictly that `continuity` is `unary`, so until we can think of a
good counter example, we're gonna say "no, a category cannot be both."

`continuity` is a `unary` `meta-category`. this is, a `category` must be
either `discrete` or `continuous`, it cannot be both.

         +-----------------------+        +-------------------------------+
         |      continuity       |----+   | categorization exponent arity |
         +-----------------------+    |   +-------------------------------+
         | continuous | discrete |    +---| unary           | N-ary       |
         +-----------------------+        +-------------------------------+

  `continuty` is `unary`

so for the next question, let's take it in the opposite direction:
2) is 'categorization exponent arity' 'discrete' or 'continuous'? well,
can we resolve a definite 'yes' / 'no' for whether the
'categorization exponent arity' of something is `unary`? `N-ary`?
because of how those terms are defined, yes we can.
`categorization exponent arity` is `discrete`.

         +-----------------------+       +-------------------------------+
         |      continuity       |   +---| categorization exponent arity |
         +-----------------------+   |   +-------------------------------+
         | continuous | discrete |---+   | unary            | N-ary      |
         +-----------------------+       +-------------------------------+

  `categorization exponent artiy` is `discrete`.

now remember, because these meta-categories are themselves categories (and
we consider these meta-categories `univerally applicable` or `univeral` for
short (described below)), and because we define the `target instance` of
`meta-categories` to be `categories`, we can therefor ask the question
"what is the continuity of 'continuity'?" and "what is the arity of 'arity'?"

3) "what is the continuity of 'continuity?'"
let's assume that we can answer 'yes'/'no' to whether any category is
'continuous' and 'yes'/'no' to whether any category is 'discrete'.

  then `continuity` is `discrete`.

(we are positing that it is meaningless to model the idea that a category
is e.g "somewhat continuous" or e.g "almost totally discrete". we offer no
proof of this.)

4) "what is the arity of 'arity'?"

"categorization exponent arity" refers to the sensical range within which
the count of applied exponents may be to any instance. by definition we never
deal with multiple sensical ranges here, just one range.

  `arity` is `unary`.

so here, then, is every entity we have presented so for, and *most* of
their relationships:

                         +----------+        +----------------+
                         | instance |-------o| categorization |
                         +----------+        +----------------+
                                               O           O
                                               |           ?
      +-----------------------+       +----------+    +----------+
      |     meta-category     |------>| category |---o| exponent |
      +-----------------------+       +----------+    +----------+
                 ^       ^                        ( category called "binary"
                 |       +---------------+          when exactly 2 exponents )
                 |                       |
      +-----------------------+       +-------------------------------+
   +--|      continuity       |--\ /--| categorization exponent arity |--+
   |  |-----------------------|   X   |-------------------------------|  |
   +--| discrete | continuous |  / \  | unary          | N-ary        |--+
      +-----------------------+  | |  +-------------------------------+
           |                     | |               |
           +---------------------+ +---------------+

(to reduce noise we have omitted the associations between the two
`meta-categories` and `category`.)

## all we want is the universe

this document has kicked at but not yet jumped on the idea of `applicability`
and `scope`. all this time that we have been making `categories` we have been
referring to things like its `target instances` and so on.

  `scope` defined broadly refers to the "kinds of things" a category can
  be sensically applied to. for now we nest it in with `applicability`
  (defined below), of which a category can have multiple, so effectively
  a category have have multiple scopes. for a category to be useful in any
  pseudo-formal way it should define at least one `scope`. :[#026]

we hold off on defining scope more formally than this because we would
then need some kind of formal defintion for things like entities and classes,
which is outside of the .. er ..  scope of this inquiry - we are waiting to
read up on The Literature [#014] for this.

  however we should offer the placeholder idea that a scope *may* want
  to reference `semantic structure pattern` or whatever that becomes
  :[#004]. (it would be like a class, or entity, but ideally defined
  in terms of a set of applicable functions).

one thing we *are* doing semi-formally, however, is saying (indirectly) that
scope's `categorization exponent arity` is `N-ary`. what do we mean by that?
we mean that a category may define *multiple* "kinds of things" it can be
applied to. it can even be applied to "unforseen kinds of things".

again let's return to our old friend the category of "german noun gender".
as the name suggests, the "kinds of things" it is meant to be applied to
is "german nouns". one facet of this that was never stated explicitly is
whether or not this category is `universal` to all 'german nouns'.

in fact, what we said was, "every noun in german inherently carries one
value of the grammatical category called gender". so, yes we *did* strongly
imply what was not stated explicitly: "the category of 'gender' is
`universal` to the `scope` of german nouns". i.e "every german noun has a
gender."

modeling that something is `universal` in some `scope` becomes kind of
a big deal because of the ramifications and corollaries it can produce,
as we will explore below.

experimentally, we will implement `scope` and `applicability` in our pattern
language by introducing a new structure-structure as it were: the idea of
a `category` that takes arguments. (this will almost certainly get dismantled
after [#014], so watch out. any programmer will detect smells here..)

(as an aside, there are two isomorphic ways we could model the following:
we can either think of scope as a property of applicability, or the reverse.
as they are isomorphic, we needn't worry too much about it. we will go with
what "sounds" right.)

let's say that `applicability` is a category that is constructed with
an `argument` - `scope`.

    +----------------------------------------+    +---------------+
    | applicability  ( scope )               |--->| meta-category |
    | N-ary, discrete                        |    +---------------+
    | universally applicable to any category |
    +----------------------------------------+
    |      univeral     |      sparse        |
    +----------------------------------------+

there are three new notations introduced above:

1) "( scope )" - terms that appear in parenthesis like this represent the
arguments to the categorization. they are defined informally for now (i.e
"scope" was a word we chose, that has no magic meaning.)
you can think of arguments as "stored" inside of the catgorizations.
(for now we say that if a categorization is `N-ary`, it will have one
associated tuple of arguments per exponent. an example below will demonstrate
this.)

2) "N-ary, discrete" - we can 'tag' this category with exponents from
our previously defined meta-categories. because of [#023] we can figure
out what category the exponents come from.

3) "univerally applicable to any category" - this is of course the
meta-category hitting itself in the face with its own arms.
when we need to notate a categorization that takes arguments, we can do
it like this: an adjectivial phrase in english that shows 1) the exponent
("univerally" = `universal`) and 2) the arguments, in this case the scope
("to any category") of the applicability.

given that the category being invoked is `N-ary`, we could have multiple
lines like these, to model the multiple applicabilities of the subject.

so, to read out the above, what it says is, "there is an N-ary discrete
`meta-category` 'applicability' that takes 'scope' as an argument. it can be
'universal' or 'sparse'. it is univerally applicable to any category.

  as for the exponents of `applicability`, `universal` means that the
  category can be applied universally (i.e. to any one of) the constituents
  of the indicated `scope`. `sparse` means that it *might* apply to any of the
  constituents of `scope`, but it is false to say that it *does* apply to any
  of them. :[#013]

(also, any category that is `N-ary` need not report that it is `sparse`
or `universal` -- this exponent should effectively be "ignored" here (?),
because (for now) a categorization with zero constituents (exponents)
in it is isomorphic with having no categorization applied to it at all;
but this is experimental.  e.g a pizza with a list of topings that is zero
items long is isomorphic with a pizza that has no 'toppings' categorization -
neither carries any more or less information than the other.)

all of this is fine and good but it is getting kind of boring.

## let's do something

the only reason we have assembled such a thus-far small ontology toolkit
with such painstaking detail is to be able to present the following axioms
in a semi-formal, albeit unproven manner:

### 1) the axiom of universal applicability

the `axiom of universal applicability` is as follows:

> any discrete sparse category for a given scope can be made universal
  for that scope by adding one exponent to its exponent set. :[#027]

this is a formal way of stating that if we add an exponent equivalent of
`not applicable` to any sparse (i.e non-universal) category, it becomes
universal for those scopes it was formerly sparse for (because we can use
the new `exponent` in categorizations for those instances where formerly
we would not have categorized them).

a highly contrived demonstration:

  +--------------------------------------+    +----------+
  | highest rank achieved in the army    |--->| category |
  | discrete                             |    +----------+
  | sparsely applicable to u.s citizens  |
  +--------------------------------------|
  | private | corporal | commndr | srgnt |
  +--------------------------------------+

the highest rank you achieved in the U.S. army is *not* univerally applicble
to U.S. citizens: not all have served in the U.S army. it is hence a `sparse`
category. but then BOOM:

  +--------------------------------------------+    +----------+
  | highest rank achieved in the army          |--->| category |
  | discrete                                   |    +----------+
  | universally applicable to u.s citizens     |
  +--------------------------------------------|
  | private | corporal | commndr | srgnt | n/a |
  +--------------------------------------------+

almost naively trivial but fun to make into an axiom. the uptake of this
is that anytime you see or create a category that is not universal for some
scope, realize that that is a cosmetic design decision, and should be done
for "semantic aesthestics".

### 2) the axiom of binary convertability

the `axiom of binary convertabiliy` is easier to define with another defintion
to build on:

  a `sparse tag` describes a `discrete`, `sparse` category with
  exactly one `exponent` :[#029].

demo:

             +-----------------------------------+    +----------+
             | lolcats, discrete                 |--> | CATegory |
             | sparsely applicable to: any photo |    +----------+
             +-----------------------------------+
             | has "cat" feature                 |
             +-----------------------------------+

  let `lolcats` be a discrete category sparsley applicable to any photo,
  whose only exponent is: 'has "cat" feature'

  we will use this tag when we crawl our social graph in facebook, using
  OpenCV to look for pictures of cats, because the internet needs moar.
  ** any picture that has a cat in in gets CATegorized with this tag **

were it that the above were `universal` (for a scope), then every instance
in that scope would have this exponent. probably usually useless unless
you're trying something clever across scopes. (imagine a social network
where every picture (every picture) had a cat in it. at best, it would be
meaningless to tag every picture with this tag. at worst, every picture
would have a cat in it.)

using `the axiom of universal applicability` [#it-027] above, any
`sparse tag` category can be converted to what we for now call a
`universal discrete binary category`. BOOM [#012]:

             +--------------------------------------+    +----------+
             | lolcats, discrete                    |--> | CATegory |
             | univerally applicable to: any photo  |    +----------+
             +--------------------------------------+
             | has "cat" feature | no "cat" feature |
             +--------------------------------------+

so then the first part of the `axiom of binary convertability` is as follows:

  any discrete category (whether `unary` or `N-ary`, with its whatever
  set of scopes) along with all of its `categorizations`, may isomorph
  (convert losslessly) into an equivalent set of `sparse tag` categories
  and an equivalent set of `categorizations`.

so:

                  +--------------------------+   +----------+
                  | spirit, discrete, N-ary  |-->| category |
                  | applicable to the people |   +----------+
                  +--------------------------+
                  | hungry      |      tired |
                  +--------------------------+

  which of the people are hungry or tired? (any person may be hungry, tired,
  both or neither.)

                  +----------+                     +----------+
                  | hungry   |-------------------> | category |
                  | discrete |  +------------+ |   +----------+
                  | sparse   |  | tired [..] |-+
                  +----------+  +------------+
                  | hungry   |  | tired      |
                  +----------+  +------------+

  now that we have converted one category to two, it still supports our
  "domain ontology" : people can still be hungry, tired, both or neither.
  also any instance data that we have could still be intact.

  note also that we could losslessly convert those to
  `universal discrete binary` categories and categorizations if we wanted to.

a corollary exists of the above axiom that states:

  any `discrete binary categorization` that is declared to be `tag-like`,
  that is, either it came from the above process or it is delcared to be
  equivalent, may be automatically "upgraaded" to being considered
  universally applicable for the relevant scope(s) (because using the
  equivalent of the `not applicable` exponent on any instance is
  tautologically equivalent to having been not tagged.) :[#014]

part 2 of the `axiom of binary convertability` has some hiccups in it:

  A) with any set of `sparse tags` or `universal discrete binary categories`,
  you may convert them into one or more `N-ary` `discrete` `categories`
  (where the sum of the count of exponents in the resulting categories
  is equal to the starting count of tag-like categories)
  B) you may again convert back to the discrete category you started with
  in part 1 (and its categorization data) provided that all of the relevant
  data is in the same state.
  C) converting any set of `sparse tags` [..] to one or more
  `unary discrete categories` is not guaranteed, and to determine its
  feasibility requires computation.

to put it another way, if you break a `unary discret category` (with N
exponents) into a bunch of tags, the bunch of tags can hold more information
than the equivalent `unary` category (significantly more - a categorization
with the former could have N possible values, while the different
combinatorial possibilities of the latter is 2^N). so going one direction
is lossless, but going the other direction is lossy.

~
