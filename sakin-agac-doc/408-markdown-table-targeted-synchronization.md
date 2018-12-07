---
title: "markdown table-targeted synchronization"
date: "2018-04-24T16:01:17-04:00"
---
# markdown table-targeted synchronization

## document objective

this document serves dual purposes, one more general and one more specific:

generally, we decompose our [#407] high-level synchronization algorithm
into code-level modules ("magnetics", usually) that we write one by one.

more specifically, begin to tilt the work towards our target use case:
markdown-table-targeted synchronization.




## overview: decompose the synchronization algorithm

as an overview, we decompose the synchronization algorithm in a regression
friendly order. (we may use these points as checklist to correspond to test
files we write.)

1. get the synchronizer to work with a list of names over an exhaustive
   set of cases. this could require as many as three format adapters:
   1. a base class thing for a format adapter itself
   1. in-memory real object (dictionary) stream
   1. json-esque stream
   1. a made up format adapter for a list of names

1. item-level synchronization over an exhaustive set of cases. (come up
   with a format adapter that is totally made up). (requirements for a
   format adapter are many.)

1. magnet: semi-editable DOM-like rows

1. magnet: traverse all lines of the document, but parsed

1. collection-level synchronization as document over a variety of cases
   (that only outputs the new document as a stream of lines! use generator!)

1. a whole diff thing yikes.

1. format adapter for our target use case. note this will have to accomodate
   the crazy tagging stuff, but if we treat that as whitespace it might be
   trivial. (will still involve parsing hacks).




## freeform discussion: xx xx xx

what we're working up to is _modules_ (in the purest sense)
that take as input "resource strings" (or something), CHA CHA

LET'S THINK ABOUT CAPABILITIES:

BUT FIRST:

synchronization

  - a collection of new items (let's call it the "far" collection)
  - a collection of original items (let's call it the "near" collection)

we're gonna just talk about things knowing in advance what we're gonna
need to do without coming from how to science

so let's look at our COARSE ALGORITHM and try to think of its
requirements in terms of what it says about the CAPABILITIES we
might require of the collections.

first, we'll do this of the FAR COLLECTION:

  - ORDERED: we expect the items in the far collection etc

  - NATURAL KEY: each item must be able to produce one

  - (as a detail, any natural key that is not unique in that collection: fail)

  - NAME-VALUE PAIRS: each item, we must be able to model it as such
    an ordered collection (with any name occuring no more than once)

as far as we know, that's it for the far side.

but note that things get more interesting with the NEAR COLLECTION:

  - HEAD LINES and TAIL LINES: (boring but essential)

  - (we are currently side-stepping the issue of multiple tables in one
    document.)

  - SCHEMA-ROW: this establishes the ALLOWABLE SET

  - AT LEAST ONE HEURISTIC TEMPLATABLE ROW

x XX xx XX xx




## categorized wrapping of far items (freeform discussion)

as we write this we are dismantling our original conception of "item class".
the idea is that for a synchronization, the client can optionally pass a
function with a name something like `far_item_wrapperer` (sic).

this function (if provided) will (at the first (if any) occurrence of a far
item) be passed a namespace/struct with "consts" (strings) and a listener.

the struct's purpose is to tell the client what available "categories" are
of result (think HTTP status). (currently we will just have `OK` and `failed`
but we might later add `skip`, hence we don't want to limit ourselves to
binary to start with.)

this function must result in a function who takes as one argument a native
object. the result will be a tuple: the first item in the tuple will always
be the result "category" (think "status"), and the second one will be the
item to use, IFF the first element of the tuple to use is `OK`.

    def _far_item_wrapperer(result_categories, listener):

        def wrap(native_object):

            wrapped_item = # ..
            # (if you will fail or skip, emit to listener)

            if # ..
                return (result_categories.failed)
            elsif # ..
                return (result_categories.skip)
            else
                return (result_categories.OK, wrapped_item)

        return wrap

    _new_stream = sync(
        # ..
        far_item_wrapperer=_far_item_wrapperer,
        # ..
    )




## <a name=E></a> provision: the item normalizer

(when referencing this point as a provision (or otherwise), use [#418.E.2])

in order for a practical synchronization to make a remote object fit in with
our local presentation (document), we have to be able to read the remote
objects at a component level; that is, we will have to traverse each item's
each name-value pair one-by-one.

we cannot simply have the far format adapter provide a wrapper class: the
far format adapter cannot know anything about the required behavior for the
target collection (document).

so the near format adapter relies on the far format adapter to provide a
function that converts far native objects to a shape it can recognize and
use.

this "lingua franca" format was once a stream (iterator) of name-value pairs,
but at #history-A.1 this changed to be a dictionary. ALTHOUGH to provision
it as a dictionary "feels less pure" and breaks streaminess (so it could be
less efficient for some contrived scenarios);

  - once you need random access to particular components, this choses
    dictionaries or similar (yes you could do a "read" function instead,
    but this lacks reflection ability on its own; and these idioms are
    in-built when we use something as familiar as dictionaries)

  - in practice in our imagined ideal scenario we are getting [#417.A]
    streams of JSON objects anyway. to first run each item thru a normalizer
    that presented it as an iterator of name-value pairs, and then go and
    derive again a dictionary from such a function, was far too triggering
    of our OCD.




## (document-meta)

  - #history-A.1 pipeline change
  - #born.
