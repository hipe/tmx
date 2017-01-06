# introduction to this sidesystem :[#001]

## meta-introduction

the immediate reason that [pl] was created was to be a more focused,
dedicated sidesystem for the somewhat ancient bundle- and plugin-related
"leftover scraps" from [m-h] as it was dissolved: we wanted to get rid of
that lib proper, but some of its facilities were still needed by some legacy
applications.

but when we moved [#024] the "fancy lookup" proc to here, [pl] became an
essential member of The Pantheon of skylab support libraries. as such,
the subject has become *the* home for all plugin-like solutions.




## where are the tests?

the old bundle facilities were frequently either abstracted out of
working applications with their own test coverage, *or* were implemented to
help implement tests themselves. so sadly, as this became its own formal
thing, it did not have its own formal tests that travelled with it.





------------------------------
# comparison of the legacy solutions (historic)

## the scope and purpose of this document is..

.. to give a comprehensive and chronological overview of every re-usable (and
potentially re-usable) plugin-like solution (or if you prefer, "dependency
injection framework") in the skylab universe past, present and future.

the purpose of this document is *not* to give comprehensive documentation for
each such library, but where other documenation exists this document will
serve as a hub of references to those documents.




## the structure of this document

the top section-item in this document will be the most recent library; and
each library that preceded it will be described in each following section. we
will number the solutions in order of their inception, so the top item will
be item N, and then following it will be N minus one, etc down to solution 1
which will occur at the bottom.

this structure is employed because we want to keep the most relevant content
always at the top, and we generally give a greater weight of relevance to
more recent solutions, because they have the advantage of building on what
was learned from the previous solutions.

NOTE: we reserve the right to re-sequence or add numbers to the sequence at
any point at any time as we reconsider and re-discover the history of the
universe, so do not use them as references either inside or outside of this
document.



## a justification for the utility of dependency injection frameworks..

is outside the scope of this document `^_^ #yolo ¯\_(ツ)_/¯`



## a one-line summary of each item

 7. [pl] digraph-powered simplification of below Feb.,  2015  active
 6. [  ] import [gv]'s custom facility           Jan.,  2014  sunsetted
 5. [pl] quickie rolls a custom solution         June,  2013  active (custom)
 4. [fa] the forgettable `Services_`             June,  2013  sunsetting
 3. [  ] Plugin abstracted out of test/all       April, 2013  sunsetted
 2. [tr] "adapter" (plugin) facility             June,  2012  paved
 1. [as] an "assesss" take on plugins            March, 2010  antique



## library 7 of N: digraph-powered simplification of predecessor



this is a synopsis of what is at [#004]:

  • no more shell/kernel pattern. there is just one plugin dispatcher
    class, one plugin base class, and tons of little ancillary classes.

  • plain-old-programming with small classes as much as possible over
    overwrought interfaces.

  • the most advanced, expressive yet implementation of a digraph-driven
    plugin architecture.




## library 6 of N: [gv] rolls an intra-reusable solution

(EDIT: this was so excellent and simple, that headless's contemporary solution
was bumped over to face and this was bumped up to headless.)

although every collection of code has its own reasons for doing things in its
own weird way, this particular solution calls itself "the best" for the
following reasons:

  • it is as simple as possible while being as complex as necssary:
  • name-mappings and name translations are kept to a minimum.
    for example, all event channels must have the same name as their
     corresponding callback methods, so here they all follow the name pattern
     /^on_.+/, as do all event channels.
  • rather than the complex API of 'meta-services' that [hl] employs, here
    the plugin host simply implements one lone "plugin conduit" subclass
    that will be used for two-way communication from host to plugin.
  • plugins need not subclass anything in particular; they derive services
    from the host via the shell passed to them in their construction, and
    they subscribe to events via following the method-naming patterns
    (that is, subscribing to events and declaring public methods with
    particulr names are one and the same.)
  • we offer a *much* simplifield solution to the "crowded namespace"
    problem of different plugins wanting to define different options: each
    plugin automatically gets its name appended to each option it defines
    (it defines its options via a "recorder" proxy without knowing it).



## library 5 of N: [ts] Quickie rolls a reasonable custom solution.

(UPDATE: this moved to here and is now [#023]. EDIT: this makes half of
the below historial sentiment. we add fresh commentary in a dedicated
document at that node but the below is still half-relevant.)

for quickie to have its own custom solution makes like easier because
we can use the quickie in the same distribution as the plugin lib
(or whichever) we are developing without breaking quickie.

although it's not as minimal and powerful as our latest effort, this stab
at plugins is easily comprehendable; and by this point it's clear that 90%
of what we are doing "now" was established by this point.




## library 4 of N: [fa] "Services_"

shortly after the previous library, something calling itself "basically
a miniature version of [hl] Plugin" emerges, but it looks to us now like
it might be more of a "client services" pattern. regardless, it uses an
out-of-date style and is being considered now as only a historical artifact.



## library 3 of N: the [hl] Plugin library

originally abstracted out of the toplevel test-runner in mid-April of 2013,
this was the first time that we really considered this as a valuable thing
to have in its own right.

it was at one point used by at least four other subsystems. it helped
cross-polinate its descendants; and was then sunsetted.



## library 2 of N: whatever we did in treemap

without at first realizing it, treemap has always been all about being a
plugin architecture. in mid June of 2012 there is is a commit with a line
that reads: "make an entire thing for loading plugings ("Adapter")".

although it has survived one rewrite and has one more in progress and stashed
away in a branch, as yet no effort has been made to abstarct anything
re-usable from it but this is being considered if we ever get back to finishing



## library 1 of N: "assess" is absolutely ancient,

but for completeness we include whatever it is that it did in this list,
because it referred to its things as "plugins". interestingly some of the code
there looks totally alien, while other parts seem reasonably acceptable.
