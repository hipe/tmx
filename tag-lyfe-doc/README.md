# tag lyfe

## objective & scope

"Tag-lyfe" is a small specification and implementation of a tagging language
and query language. Collections that participate in the tagging language can
be seached using the query language (and associated functions provided here).

The tag-lyfe tag specification is designed to look familiar to people familiar
with the "hashtag" convention of social media platforms like Twitter and
Instagram (where tags start with an "octothorpe" `#`), but we extend this
convention a bit:

* Our tag names can be any combination of upper or lowercase letters, numbers
  and underscores; but can also use a dash `#like-this`. (If the desire were
  there, we would formally add support for multi-byte (unicode) tag names but
  at present this is undefined.)
* Search for entities that are tagged with the tag by using a query composed
  of just the tag as-is. For example, the query `#tbt` would find entities
  tagged with that exact tag (but not `#tbt2019`, for example). (Case-
  sensitivity is discussed below.)
* One way we extend the familiar convention significantly is that our
  "taggings" can represent some name value pairs like this: `#priority:urgent`.
  (We call these "deep taggings".)
* Such name-value-looking "taggings" can be nested arbitrarily deeply:
  `#priority:urgent:right-now`.
* In your query you can express a boolean "AND-group" or "OR-group" from a list
  of taggings with `and` or `or`: `#tbt and #2019`, `#cats or #dogs or #reptiles`.
* You can (and sometimes must) use parenthesis to make groupings clear:
  `#red or #blue or ( #pink and #brown )`. (Unlike most programming languages,
  we do *not* assign different precedence to those two operators, because we
  find that arbitrary, non-obvious and hard to remember.)
* Negate with `not`: `#red and not #blue`.
* Combine "deep taggings" with boolean conjuction: `#code:red or #code:pink`
* The `in` operator provides a shorthand for the above:
  `#code in ( red pink )`.
* You can search your deep tagging "value" with a regular expression:
  `#full-name in /^Kim Jong-/`.
* Search for integer values in a range: `#age in 33..44`. (Experimental,
  not very useful because no `∞` yet.)
* Find tags with a certain name that do *not* have a value:
 `#age without value` and tags that *do*: `#urgent with value`.




## <a name=status></a>status

This currently works and is useful. At #history-A.1 we moved its integration
from [\[#400\]] "sakin-agac" to [\[#851\]] "kiss-rdb".



this subproject currently works and is useful. combined with the power of
[\[#400\]] sakin-agac, this thing can take collections of items we're
tentatively calling "dim sum" tables (like in [\[#404\]], sort of) and pare
them down to match criteria (your "query").


for example:


    ./script/filter_by.py '#open' and not '#boring' tag-lyfe-doc/README.md


the above pares down the below [node table][#nt] (in this same document)
and ouputs (at writing):

    {"id": "#709.D", "main_tag": "#open", "content": "integrate queries and .."}
    {"id": "#709.C", "main_tag": "#open", "content": "maybe don't walk (#when)"}
    ..

i.e, it pares down the below collecton to filter it down to only those items
that are tagged with `#open` and not tagged with `#boring`.

the output is expressed as a stream (in the UNIX sense) of JSON objects
(where each line is one object) making it suitable to be piped into or
consumed by arbitrary other processes.




## <a name=nt></a>the node table

(My range is [#701]-[#799].)

|Id                         | Main Tag | Content |
|---------------------------|:-----:|-----------------------------------------|
|                 (example) | #eg   | #example blah blah
|                   #709.D  | #open | integrate queries and tagging to use same grammar (#when)
|                   #709.C  | #open | maybe don't walk (#when)
|                   #709.B  | #open | generic small seams (#when)
|                   #709    |       | (seams to revisit when stable)
|                   #708.3  |       | (this one coverpoint, referenced in [ma]
|                   #708.2  |       | (this one script, cross-sub-project coverage)
|                   #708    |       | (external tracking)
|                   #707.K  | #open | reconcile something with something
|                 [#707.10] |       | maybe lost coverage/created appendates at #history-A.1
|                   #707.I  | #hole |
|                   #707.H  |       | #provision: don't use default whitespace handling
|                   #707.G  |       | #provision: isolate parser-generator specifics
|                   #707.F  | #trak | the "wordables" micro API
|                   #707.E  | #trak | quoted string terminal nodes in taggings & queries
|                   #707.D  | #trak | the catch-22 of development order (see)
|                   #707.C  | #trak | when we formalize allowable tag names
|                   #707.B  | #hole |
|                   #707    |       | (internal tracking)
|                   #705    | #hole |
|                   #704    |       | experimental conventions
|                  [#703.B] | #edit | edit documentation
|                   #703    |       | soft notes
|                [\[#702\]] |       | due dilligence on parser generators
|                   #701    |       | (this readme)




[\[#702\]]: 002-parser-generators-dilligence.md
[\[#404\]]: ../sakin-agac-doc/404-wiki-app-dim-sum.md
[\[#400\]]: ../sakin-agac-doc/README.md




## (document-meta)

  - #history-A.1
  - #born.
