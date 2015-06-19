# the table narrative :[#096]


## about this document & the many tables

we almost called this "the omni table narrative", but didn't because our
longerm goal is to unify all table implementions:

    [#.D]  2013-03-13  ad-hoc for application. rewritten once.

    [#.C]  2012-03-16  the old functional experiment

    [#.B]  2011-08-22  the "main" one

    [#.A]  2011-08-22  a tiny, almost minimal one

because we are not there yet, this document is divided by horizontal
"lines" into sections corresponding to the respective implementations.

we *certainly* want to make a [cu]-like feature comparison meta-table
(that is, a table about tables :P ) and then reduce these down to one..


----------------

# the fourth table narrative :[#.D]

## justification

at writing this was re-written from the ground up. we did not use
[#.B] for this because of the product of these factors:

  • we were in the middle of a full rewrite of the application itself.
    to try and fold-in a unification of libraries on top of this would
    be decidedly out of scope.

  • this custom implementation has at least one feature that the others
    don't (an optional summary row that knows that a "data object" is
    a thing).

however, "very soon" we hope to unify the implementations; an effort for
which the work here will likely serve as a major contribution, being as
it is informed by all that came before it.





## :#note-fm-315

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

# the CLI table ACTOR narrative :[#.B]

## introduction (leads to [#.G])

during the "pre-unification" phase, we designated this implementation as
"actor" based solely on how it was typically interfaced with: calling it
in the "one-shot"/"inline" form had the appearance of calling a proc.

furthermore; like a proc, this object can be "curried". this makes it
superficially like the [#.D] "structured" table, but we take a tack that
is more simple or more complicated, depending on whether or not you are
using or implementing this facility (respectively):

in contrast to [#.D], we make no distinction between a "declaration"
phase and a "rendering" phase: any data that you would provide during
the one you can also provide during the other, and vice-versa.

below the surface, the salience of this implementation during the rewrite
is this: whereas [#.D] ended up becoming an excercize in "visitor pattern",
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
   into a depedent object (or client) and are made art of the client's
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
:[#.G]  (then we abstracted [#pl-007] from this.)




## :#note-act-170

at first it may seem superflous to go through event dispatching for
every row. but this allows for (hypothetically) a pager, etc




## :[#.E]

fields should be immutable.




## :[#.F]

the default is to align left.



# ~ (( BEGIN erase all these

## :#storypoint-80

keep in mind what is happening here - *every* time you call the curried
executable, it makes a deep copy of the whole field box. it feels like we
should optimize this but it depends on the usage whether this is helpful: we
don't expect our usage patterns to justify such an optimization at this point



## understanding multi-pass table rendering

text-based table-rendering is not fun or interesting unless we do
"dynamic column alignment". to do this necessitates that we hold the entire
table (in some form) in memory as we determine the statistics for each column,
so that we can know how much whitespace to pad each cel of each column with.

algorithmically, alternatives probably exist to acheive a simliar end but they
are beyond the scope of this project.



## :#the-data-pass

in the data pass we flush every row of data from the producer, and along
the way we gather statistical data about each field from its each cel.

once we get to the end of the rows of data from the producer we can
know statistical metrics about the field, like what is the widest width
of all of its cels in terms of characters when stringified, or what is
the minimum and maximum values for the field when numeric.

we want to store the values of each cel in memory rather than iterate multiple
times over the same producer (if it were even possible) because the producer
might for e.g be a randomized functional tree in which case iterating over
it multiple times would probably yield different results which may obviate
attempts at building statistical data.

random gotcha: some custom enums want to short circuit the entire rendering of
the table rather than render anything.



## :#overage-here

imagine a table whose target width is 20. it has four columns. two of
them are "ordianary" data cels and two are fill columns. let's say that
the data columns end up with widths that add up to 13. (we're going to
ignore the idea of separators and margins for now). that leaves us with
a width of 7 that our two fill columns have to share. let's say our fill
columns each declare the same relative widths (the same 'parts' number).

what we want is that one column ends up with 3 and one ends up with 4.
the way we do this is we floor the floating point number (3.5 down to 3)
and then with the amount of width that is left over (in this case 1), we
distribute it from left to right, in a "one-for-you, one-for-you"
manner.

# ~ ))
