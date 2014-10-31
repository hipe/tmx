# discussion of all the meta-property libraries :[#053]

## introduction

this is the world of :#parameter-library's, "field libraries", actors
and entites.


## a cursory overview

first, a quick history (most recent at top):

    [#cb-042] actors                                          2014-08-00

    [#br-001] the entity library                              2014-07-22

    [#gv-030] the isomorphic interface parameter              2014-01-20

    [#cb-058] methodic actors                                 2013-12-19

    [#tm-081] the "config shell" (working title) (lost)       2013-10-11

    [#ba-030] the basic struct                                2013-07-21

    [#br-058] Fields_ DSL --> "contoured fields" --> [br]     2013-07-18

    [#mh-061] basic fields                                    2013-07-05

    [#ba-003] the basic field                                 2013-04-11

    [#hl-009] the headless parameter                          2012-08-29

    [#mh-024] the metahell formal attributes                  2011-09-11


annotation (most recent at top, start at bottom for a narrative):
  • [cb] actor is and always will be minimal.
  • [br] entity started out clean, got heavy, is most popular for bus. model
  • [gv]'s is a clean rewrite of the below meant to be rbx-compatible
  • borrowing from that but as a small standalone rewrite was [hl] API params
  • then, during the "headless earthquake" of late 2013.. (well, read below)
  • then there was the basic "field" [#ba-003]
  • then there was the headless "parameter" [#hl-009]
  • first, there was the metahell "formal attributes" [#024]



## a comparison of our favorite solutions & favorite categories

                | actor                 |     methodic actor |     entity

what does it do | actor leaves your     | although we one did not do it this
to your ivar    | ivar namespace alone  | way, these two maintain ivar(s)
namespace?      | completely except for | modeling the current iambic scan
                | your business ivars   | which is convenient for IWM's (belo)

property        | actor does not model  | has a base class   | its base p.class
objects?        | field meta-data with  | that it itself a   | is intentional
                | these, it has a box   | lithe methodic     | minimal
                | that maps names to    | actor. modeling    |
                | ivars and models an   | some common m.p's  |
                | order, and that's all

customizing     | actor does not doa    | you manipulate the | manipulate
your property   | anything like this    | p.class subclass   | directly, or use
objects (e.g    | at all. by design     | directly           | a crazy DSL. this
for declarative | it is kept minimally  |                    | thing  models
instead of im-  | simple                |                    | meta-meta-
perative        |                       |                    | properties.
algorithms)     |


hooks?          |             no way    | you can write some | an overwrought
                |                       | arbitrary logic    | hooking DSL
                |                       | inside your prop   | to trigger
                |                       | for e.g when       | logic when
                                        | metaprops come in  | m.p's come





## more in-depth comments about the particular implementations


### the [gv] isomorphic interface parameter library

although this library may not introduce any sweeping new innovations in the
space of parameter libraries, it may represent the cleanest yet effort to
synthesize many of our favorite implementation for the simpler bulk of those
features:

  • a flat iambic interface for its DSL, one that starts to approach
    the [#mh-047] #item-grammar but simplifies by needing no prepositional
    phrases: our grammar prefers simple flag adjectives to key-value pair
    predicates, arguing that the former can often replace the latter to make
    for more readable specifications. (for example, ":argument_arity,
    ":one_or_more" can be replaced with ":list".)

    (but this would not be the case for for e.g wanting to pass in a regex
    in to the spec, so keep this in mind. fortunately this library does
    not concern itself with validation beyond parameter arity.)

  • immutable parameters inherited via ancestor chain method inheritance
    • as a simplification to predecessor, the internal, normalized symbolic
      name for the parameter *is* the method name that gets the parameter.
      no runtime name translation or spec-time hashtable generation necessary.

  • less reflection than headless API: all map-reduce, scanning, and
    enumeration starts with just getting an array (but we may universalize and
    smooth these interfaces, such that this is an implementation detail).

  • no extensible meta-parameter API (none needed b.c of its simplified scope)

this was a just-enough effort to allow us to generate option parsers
as an afterthought for our interface specs.



### [#cb-058] methodic actors (was "the headless API parameter library")

this was a small, standalone, clean ground-up rewrite of a parameter library
for the pursposes of this re-imagined headless API (it was abstracted out
of something, i can't remember what (ah yes: f2tt)).

borrowing from its immediate predecessor, it features:
  • immutable parameters with inheritance via method inheritance
  • extensible meta-paramters via a DSL for sub-classing the parse
    class and writing your own writers, and perhaps sublcassing the
    parameter class.

it's undergoing a ground-up rewrite putting it at the head of the pack.



(EDIT: for history we are leaving the below section intact: it is left as it
was originally written: in chronolgical order (from where it starts (the
beginning of time) to where it ends (the middle of time). in the rest of this
document above, chronological progressions occur with the most recent at the
top. so, yes: to get the full narrative, start from this middle, read to the
end, then go back to this middle and read up to the top. whew!)


## formal attributes was the first stab at a meta-properties library

it started on 2011-09-11 with a 40 line DSL extension module. it may prove
to be the only one still standing when all this dust clears.


## [hl] parameters was a successful experiment that failed to improve the above

on 2012-08-29 it first got individual recognition. for some reason we tried
to cram every meta-attribute that would ever be used into one scope, thinking
mistakenly that it would somehow make life easier. it did not. a longterm
goal is to absorb all the good parts of this into the above.

(further discussion of this library is in [#tm-045] - tan-man at the time
of this writing straddled far into both libraries)


## then came the N-meta experiment with [ba] field

in 2013-04-11 we attempted another experiment: what if saying "meta" was
itself varible? this may or may not be useful, but is sitting there now
in meta-fields.


## frustraded by the diaspora, the solution was to add to it

watch for upcoming "config shell" [#tm-081] that is lightweight, ground-up
rewrite of basically all of the above. among other things, the novelty that
this guy brings is:
  + meta-attributes *and* attributes are both modeled alongside each other
    as properties of a class (accesses by reader methods, and truly memoized)
  + meta-attributes and attribtues are immutable. to change them is
    to re-write them.
  + given the above, inheritance works lazily, leveraging the existing
    inheritance model of ruby instead of the graph deep-copying that
    happened in formal attributes [mh-024]
_
