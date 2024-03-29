# the table narrative :[#001]

## objective & scope

"tabular" is a toolkit for table-oriented transformations on streams.
its canonic and minimally interesting use case is to help produce an
ASCII table with columns justified from tuples of data.




## brief history

this library is a culmination and full overhaul and distillation of six
(6) other disparate libraries that did more or less the same thing (or
different aspects of the same kind of thing).

there are very old paragraphs interspersed with very new ones in this
document. as they are not always cleanly contiguous, we will have the
work of the final (EDIT) for after we have achieved full overhaul
and unification.




## approach

rather than hide the (mostly mundane) compuation of typical use-cases
behind a black box "power function" that does everything transparently,
we prefer to make the focus of this library this: to expose a disjoint
collection of highly modular (and small!) independant but mutually-
compatible building blocks that can be pieced together in obvious ways
to produce a variety of table-oriented stream-shaped data for a variety
of use-cases and [#br-002] modalities, suitable for both user-facing
output and maybe even internal map-reduce and sort-related techniques.

(there probably *will* be a black-box god-like function somewhere at
the front of this, but we just perfer not to make it the focus of the
library.)



## about this document & the many tables

we almost called this "the omni table narrative", but didn't because our
longerm goal is (or isn't) to unify all table implementions:

    [#ze-047]    2016-08-28  "tuple pager" for long streams of data

    [#ze-050]    2013-03-13  ad-hoc for application. rewritten once.
                             now the root node for the [ze] CLI table lib.
                             was once [#here.D].

    [#here.C]  2012-03-16  the old functional experiment

    [#here.2]  2011-08-22  the "main" one

    [#here.A]  2011-08-22  a tiny, almost minimal one

because we are not there yet, this document is divided by horizontal
"lines" into sections corresponding to the respective implementations.

we *certainly* want to make a [cu]-like feature comparison meta-table
(that is, a table about tables :P ) and then reduce these down to one..


## [ze] tables - the new "best practices" (overview)

  - the production and expression of a table should be broken up cleanly
    into those two disparate areas of concern: one area of concern is the
    production of the data that goes into the table, and another (wholly
    separate one) is the area of concern that expresses it (the "rendering
    agent" or "client", as you like). this allows the same data to be
    expressed in different modalities and to work with dynamic UI's
    (in the spirit of MVC/MVVM). this idea might sound "nice" at first
    glance, but it has far-reaching impact that will set the problem-space
    for most of the work we do here.

  - life is much better all around if we cleanly and consistently follow
    one internal API for the data structures and behavior patterns to form
    a "lingua franca" for how the producer expresses this data to the
    consumer:

  - this "lingua franca" has two compontents: 1) the "rows" of data
    themselves are expressed by the producer as a *stream* of *arrays*.
    more on this below. 2) the "schema" of the data should be expressed
    by the producer as a passive event (actually data) emission [#co-011].
    also more on this below.

  - we want that the producer should only ever stream the data for the
    hopefully obvious reason that it scales better without much cost:
    for small sets of data, it is trivial to present an array (for example)
    as a stream; however there is always a sufficiently large set of data
    for which presenting it as one big array will be prohibitively expensive.
    so streaming is an answer to the challenge of scaling to lots of items.
    but this answer leads to its own challenges for rendering tables and
    aggregating their data as we will see throughout; the "tuple pager"
    being the quinessential outcome of this dynamic.

  - the "tuple" that constitutes each item of the stream, we believe it
    should be a pseudo-fixed-length array and not a hash, struct, business
    object or ad-hoc internal object for these reasons:

      - ad-hoc internal object: too much API with no real benefit

      - business object (i.e user defined): too hard to do anything useful here

      - hash: too costly? random access directly should not generally be
        needed at this point. we're ignoring the fact that the platform
        orders hashes. doesn't "feel" right. with the "schema" API, user
        agent can have effectively random access anyway..

      - struct: it's annoying (if not a showstopper) to generate these on the
        fly for dynamic queries. otherwise they are near perfect for this.

    this leaves arrays.

  - the emission of a "table schema" as a data emission for a passive
    listening model, this idea is minutes old at writing..




## the general table proto-algorithm [#here.K]

whether or not we'd like to admit it, the common thread behind all of
these libraries is they implement the logic necessary to render tables
from dynamic content to a monospaced-font, fixed-with textual output
context (that is, usually a "terminal" or console (or maybe a text
document)).

the general priciple is that we have to iterate over the collection
of rows (in some form) two times, memoizing the entire table somehow
in between these two passes:

in the first pass, we note how wide the rendered data is (or will
be) for each cel, all the while memoizing each widest width encountered
per column.

in the second pass we use this widest width of each column to determine
how we render each cel, and then render each row with this renderer,
creating the final output.

note that in the first pass, as we process each user-provided row of
data we memoize it (in some form) for use in the second pass, rather
than relying on the user data source as a means of reliably re-creating
this exact same matrix again. note that this would not scale out to
"large" datasets as written, but could be modified to do so with these
general principles and behavior intact.


----------------

# the fourth table narrative :[#here.D]

## justification

at writing this was re-written from the ground up. we did not use
[#here.2] for this because of the product of these factors:

  • we were in the middle of a full rewrite of the application itself.
    to try and fold-in a unification of libraries on top of this would
    be decidedly out of scope.

  • this custom implementation has at least one feature that the others
    don't (an optional summary row that knows that a "data object" is
    a thing).

however, "very soon" we hope to unify the implementations; an effort for
which the work here will likely serve as a major contribution, being as
it is informed by all that came before it.





## #todo DETACHED (was :#n-ote-fm-315)

although it may have "CLI" in the name, we don't want the subject node
to have to concern itself too deeply with this modality. the subject
produces "lines", and it would be nice if that were it.

the above when taken on its own makes the existence of this method here
seem a bit like a sore thumb.

so we ended up writing [#ba-046] was written to justify the existence
of this method.

although it interrupts the "purity" of this subject node otherwise not
having to know what a newline is, it is convenient to implement this
necesary (per the above mentioned doc node) mapper here instead of
clients needing to deal with it on their own.




----------------

# the CLI table ACTOR narrative :[#here.2]

## introduction (leads to [#here.G])

during the "pre-unification" phase, we designated this implementation as
"actor" based solely on how it was typically interfaced with: calling it
in the "one-shot"/"inline" form had the appearance of calling a proc.

furthermore; like a proc, this object can be "curried". this makes it
superficially like the [#here.D] "structured" table, but we take a tack that
is more simple or more complicated, depending on whether or not you are
using or implementing this facility (respectively):

in contrast to [#here.D], we make no distinction between a "declaration"
phase and a "rendering" phase: any data that you would provide during
the one you can also provide during the other, and vice-versa.

below the surface, the salience of this implementation during the rewrite
is this: whereas [#here.D] ended up becoming an excercize in "visitor pattern",
this implementation will be a grand exercize in finding the "right" pattern
to make this code more navigable (by way of having some formal
modularization).

to this end:

  • at first we thought we wanted "dependency injection"
  • then maybe "service locator" pattern
  • then we settled on "strategy" pattern (for now)

interspersed with a long excerpt from the article on dependency
injection (from the usual source) is our annotation in square brackets
indicating whether our implementation & needs qualify with the previous
point:

  "Dependency injection is a software design pattern in which one or
   more dependencies (or services) are injected, or passed by reference,
   into a depedent object (or client) and are made part of the client's
   state [yes, sounds good].

   Dependency injection involves four elements: the implementation of a
   service object [sure]; the client object depending on the service
   [yep]; the interface the client uses to communicate with the service
   [yes: our event model]; and the injector object, which is responsible
   for injecting the service into the client [no, this is probably too
   much software for our needs].

   [this next paragraph is key:]

   Implementation of dependency injection is often identical to that of
   the strategy pattern, but while the strategy pattern is intended for
   dependencies to be interchangeable throughout an object's lifetime,
   in dependency injection only a single instance of a dependency is
   used. [BOOM.]

the last paragraph of the above excerpt makes our decision for us: we
want the dependencies to be interchangeable throughout the lifetime of
the object, so what we probably wants is closer to the strategy pattern.
:[#here.G]  (then we abstracted [#pl-007] from this.)





## the rendering pipeline :[.#J]

putting a finer point on [#here.K] the general algorithm:

we anticipate one day overhauling this to become based on a user-defined
dependency graph (something like excel spreadsheets). also, our
terminology is likely to change; but we cannot find the perfect words
unless we build a bridge to them using imperfect words as a start.

we frame our general pipeline (to be explained in more detail below) in
terms of the lifecycle of how a user-provided "datatpoint" eventually
becomes an individual rendered "cel" in the finished output:

    +----------------+
    | user datapoint |   # of mixed (unknown) shape, raw data from user
    +----------------+
            |
      [ argumenter ]     # an argumenter converts datapoints to arguments
            |
            v
    +----------------+
    |   "argument"   |   # of mixed shape, an argument to the celifier
    +----------------+
            |
       [ celifier ]      # a celifier converts arguments to cels
            |
            v
    +----------------+
    |      cel       |   # a string of some fixed width per column,
    +----------------+   # ready to be assembled by glyphs to make a row





## (method documentation) :[#here.H]

an essential part of our implementation of the [#sl-023]: we send,
`.dup` to a curry to create another curry from it or to create an
executable dup of a curry.

the *whole* dependencies tree must be duped recursively in a non-
trivial manner implemented ad-hoc as appropriate for each node.




## :[#here.E]

fields should be immutable.




## :[#here.F]

the default is to align left.
_
