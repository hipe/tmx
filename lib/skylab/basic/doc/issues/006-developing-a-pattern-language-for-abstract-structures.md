# developing a pattern language for abstract structures

## style and purpose

we are going to cherry-pick a subset of all human knowledge (specifically
computer science, more specifically data-structures) and then bastardize it
beyond reasonable recognition, with the goal of being able to say something
about API's in a way that is general enough to avoid being locked into one set
of technologies, but formal enough to be reasonably unambiguous when applied
to a particular technology.

## desire deferred

we had wanted this to sound like chomsky's CFG's, but that was before we
realized that it is often data structures and set theory that we can use
express what we're after. but expect CFG's to get shoe-horned into this
somehow. also note we distance ourself from data structures somewhat.

## defining what this is not

### this more `logical` than `physical`, more `semantic` than `structural`

we want to reference data structures sparingly. we want to reference built-in
data-types not at all when possible. what we are doing is trying to develop
our own information theory based on observations we have made of shadows on
the wall of a cave we are chained to.

down deep, in tandem with [#it-003], what we are really attempting is to
develop a lexicon of the structures (and patterns?) of meaning, to an
extent that it is both useful and elegant for the purpose of specifying,
developing, and understanding API's.

(make it a semantic web of behavior clusters. now that's just silly. #todo)

### this is style-ish

we may use the suffix '-ish' a lot to distance ourself from existing formal
definitions. to delve not into a programming language but rather its
surrounding oral tradition: ruby provides a sublime example in its culture's
use of the concepts of "true-ish" and "false-ish". it hits right on the money
the sense we are after - to the uninformed, the above categorizations may
sound fuzzy ("how can it be true-ish but not true?").

but in fact "true-ish" and "false-ish" are not fuzzy. they are indeed
`discrete` [#it-010]: any expression in ruby either is or is not "true-ish",
and any experssion in ruby either is or is not "false-ish".

indeed, this `categorization` [#it-007] that we will here call `truthiness` --
of which `true-ish` and `false-ish` are the only two `exponents` [#it-009] --
is a `discrete binary categorization` [#it-012], *and* it is `universal`
[#it-013] to each member of the set of all ruby expressions.

i.e any expression in ruby is either "true-ish" or "false-ish". it has to be
one of those and cannot be both of those.

now, sidestepping a debate about the respective merits of staticly vs.
dynamically typed languages because that was not at all the point, but just
taking this as a metaphor for metaphor's sake: when you understand true-ish
and false-ish in ruby, you understand that those categorizations have discrete
*semantic* meaning - that rather than expressing what data type and value
something *is*, they express what a particular expression *means* in a
particular context (that is, does the thing act true or false?). and,
depending on the context, it is often the `truthiness` of the expression that
matters, and not merely whether it is `true` or `false`.

(it bears pointing out that this phenomenon of needing to define truthiness is
a property of most (if not all) dynamically typed languages [no citation
needed])

the point was not to make accidentally a strong allusion to perl's contexts,
may they rest in peace; the point is that here we care less about strict
type and more about behavior and/or applicable functions for a certain purpose.

that is, maybe what we are doing is making a quack semantic network (WAT)

to conclude the metaphor (perchance to put it out of its misery), in the same
sense that the rich oral tradition and history of the ruby people embraced the
suffix "-ish" to express a discrete concept that was maybe something other
than the term it modifies, we will do the same below..

#### for a more specific example of what we're talking about, even
 though we haven't really said it yet

(the below will assume a working familiarity with what you find in wikipedia's
"list of data structures".)

take for example an `array` in the classical sense: it is an ordered
collection of elements. each element (in this definition) is accessed by one
of a contiguous range of integers starting from zero.

because this is not a formal definition of an `array` but rather a didactic
one with the purpose of demonstrating a technique, we will instead call it
`array~` (array-ish).

and then take for example a `dictionary`, again in the classical sense. (your
culture might call it a `hash`, `map`, or `associative array`. if your culture
is devoid of culture entirely, you might be confused as to why we are treating
`array` and `dictionary` as separate entities. if this is the case, stop
reading now.)

let's try defining our imaginary `array~` and `dictionary~` in terms of some
of the operations they support:

`array~`: fetch an element using: ( an integer index )
`dictionary~`: fetch an element using: ( a key )

let's pose some pseudo definitions for `integer` and `key`:

`key~`: any node
`integer~`: a subset of all of the nodes
(a *really* loose definition of `node` is offered at [#it-006])

interestingly (and perhaps unremarkably to any programmer) there is
`semantic intersect` between what an `array` *means* and what a `dictionary`
*means*. to jump ahead to a more formal treatment, we are looking for some
set intersect of their respective `operations`, both collectively and then
individually:

our `array~` and `dictionary~` both have operations to fetch an element.
they both take one argument. the `array~` takes an `integer~` as its argument,
and the `dictionary~` takes any `node~` as its argument.

since the set of all `integer~` is a subset of the set of all `node~` ; and
since both the `array~` and the `dictionary~` in this context are only
defined by this one operation, and since in this one operation they both
differ only by this one argument, and since the one is a subset of the other,
we can say that in this context an `array~` IS-A `dictionary~`.

that took a lot of saying to get to that point but this gives you a hint of
where we're going with this:

  we are going to concern ourselves less with the `physical` data structure,
  that is, what is the data structure in the classical sense, and more about
  the `logical` way that that node behaves in some particular context, given
  what we want to do with it at that moment.

  in the above example, `array~` and `dictionary~` are of course `physically`
  different, but in context where all keys are integer keys, they can be
  treated as `logically` the same :[#009]

## on to the content - developing a small semantic web

### introducing the `enumerability` category: `list-ish` or `atom-ish`

  in a particular context, a `node` [#it-006] can be `atom-ish` or `list-ish`.
  we present these here as two ends of (another)
  `discrete binary categorization` that we will call `enumerability`.
  so the set of `atom-ish` and `list-ish` is the comprehensive set of
  `exponents` that makes up the `enumerability` `category`
  (again [#it-012], [#it-009], [#it-007]).

  (although it may be tempting to substitute the term `enumerable` for
  `list-ish`, we do not to avoid consfusion with the underlying discrete
  interface/implementation in some platforms of the same name. remember a
  large point of this excercize is to come up with a pattern language for
  semantic (or just abstract) structures, as distinct from formal data
  structures, algorithms, or specific implementations thereof.)

  `list-ish` - (the exponent introduced above) is probably what it sounds like.
  e.g if we are talking letters of the alphabet, then a person's first name is
  `list-ish` because it has a list of indivdual letters.

  e.g a list that is one letter in length is still `list-ish` because lists
  are still lists even when they are of length 1.

  e.g the empty list of letters is also `list-ish` even though it is empty.

  however, if the node in question is for example not a list that is one
  letter in length, but rather it is just one letter, itself, then in this
  context the node is `not list-ish`.

  but, to zoom-in, if we were talking about the letter as a glyph defined by a
  series of bezier curves, then the letter is again `list-ish` - it can be
  conceptualized as a list (or whatever) of bezier curves with little control
  points or whatever thingy dingies.

  remember how the letter came from a name? you could have a list of names
  that represents your social graph in a social network. now the individual
  name is `not list-ish` anymore in this context. etc.

  `atom-ish` - (the exponent introduced above) is a node that is not
  `list-ish` in a given context. because `list-ish` and `atom-ish` are the two
  ends of a `discrete binary categorization` [#it-012], then it follows that
  `not list-ish` is the same as `atom-ish`, and conversely, `not atom-ish`
  is the same as `list-ish`. it then also follows that the above definition of
  `list-ish` cited two examples of `atom-ish` without saying it.

## structural operational categories (definition)

data structures out in the "real world" of wikipedia get defined (necessarily)
in terms of operations they support. we likewise define semantic
structure-patterns here in those terms.

it is useful and amusing to put these operations *themselves* into categories,
one of them being `destructiveness`, i.e whether the operation attempts to
`mutate` the host node, i.e whether the operation has `side-effects`.

but first, some recursively nesting definition/examples yay:

  any `operation` :[#ba-007] is defined in association with at least one
  `semantic structure` [#it-004]. (conversely, semantic structures are defined
  by one or more operations.) the same `operation` can be a part of multiple
  structure definitions.

  there exist `operational categories` that we use to categorize operations
  (examples follow). if an operational category can be said to apply to *any*
  operation, then we call it a `universal operational category`.

  `universality` is itself an `operational meta-category`, that is, it is
  a category that we apply to operational categories. it is `discrete` and
  `binary`.

  `universality` the category is itself universal, that is, any operational
  category can be said to be either `universal` or not.

  this also makes `universality` an `operational N-meta-category` i think,
  because it can be a meta-category, and a meta-meta-category, and so on.
  but meh.

  (don't worry if your eyes glazed over at that last half above, it's more
  for fun than anything.)

to build on the above, but this time with a fancy ASCII semantic ERD:

    +-----------+
    | semantic  |                        +-------------+    +----------------+
    | structure |    +-----------+       | operational |    |  operational   |
    |  pattern  |o--o| operation |o-----o|  category   |o--o| meta-cateogory |
    +-----------+    +-----------+       +-------------+    +----------------+
          ^                ^                    ^                   ^
          |                |                    |                   |
    +-----------+    +-----------+  +-------------------+   +-----------------+
    |   tuple   |----|   fetch   |  |  destructiveness  |-+ |  universality   |
    +-----------+    +-----------+  +-------------------+ | +-----------------+
                           |        | destructive | not | +-| universal | not |
                           |        +-------------+-----+   +-----------+-----+
                           |                         |
                           +-------------------------+

it reads: "a `semantic structure pattern` can be associated with many
`operations`, and an `operation` likewise can be associated with many
`semantic structure patterns`. a `tuple` is an example of a
`semantic structure pattern`. a `tuple` is associated with a `fetch`, a kind
of `operation`. an `operation` can be associated with `operational catgories`
[..]"

## structural operational category: `destructiveness`

what are the operational categories that we can use to categories operations?

  `destructiveness` (first mentioned above) is one such category.
  there are two `exponents` for this category -- this category has a strong
  isomorphicism with the same concept from computer science, so we have a
  choice of terms we could borrow to represent its two `exponents` -- we chose
  `read-only`, `destructive`.

  it is a `discrete` category. since it has two exponents, that makes it a
  `discrete binary categorization`. we will take it a step further and say
  that this is a `universal operational category`, that is, that it applies to
  any operation.

  (i.e we may later regret this, but this is to say that *any* operation is
  either `read-only` or `destructive` - one or the other, not both.) no proof
  is offered. it is merely a theoretical axiom.

  (note that many universal discrete binary categories are tautologocially
  axiomatic in their universality [#it-014])

  (note too that we used the `opearational meta-category` of `universality`
  defined above.)

### a leak-proof abstraction

note that we said `destructiveness` has a strong isomorphicism with the
same concept from computer science. in fact it may be too strong. What we're
after in developing our pattern language for abstract structures is less about
talking about desctructive operations those abstract structures may exhibit,
and more about functions we can use on them to derive properties from them..
