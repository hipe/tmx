# tag lyfe

## objective & scope

  - à la twitter, imagine a collection that is marked up with "ordinary" tags:

    1. `tweet one - #metoo #basta`
    1. `what a great game #fifa2018`
    1. `rose mcgowan #metoo autobiagraphy 😭✊ #fierce`

  - we can search for all items that have one particular tag, but also
    we can make more complicated boolean queries based on the taggings.
    a minimal example is in the [next section](#status).

(oblique snippet that will be moved to somewhere like `filter_by_tags.py`:
this is for making informed decisions, and then later being able to
justifying how you made those deicisions in a straightforward, reproducible,
machine-readble way.)




## <a name=status></a>status

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
|                   #707.I  | #open | #refactor: queries and tagging should use same grammar (for tagging)
|                   #707.H  |       | #provision: don't use default whitespace handling
|                   #707.G  |       | #provision: isolate parser-generator specifics
|                   #707.F  | #trak | the "wordables" micro API
|                   #707.E  | #trak | quoted string terminal nodes in taggings & queries
|                   #707.D  | #trak | the catch-22 of development order (see)
|                   #707.C  | #trak | when we formalize allowable tag names
|                   #707.B  |       | for now no 'tag subtree' class
|                   #707    |       | (internal tracking)
|                   #706    | #trak | #central-conceit: queries then other arguments in ARGV ([#706.B] is note)
|                   #705    |       | the tagging model (graph viz file)
|                   #704    |       | experimental conventions
|                   #703    |       | soft notes
|                [\[#702\]] |       | due dilligence on parser generators
|                   #701    |       | (this readme)




[\[#702\]]: 002-parser-generators-dilligence.md
[\[#404\]]: ../sakin-agac-doc/404-wiki-app-dim-sum.md
[\[#400\]]: ../sakin-agac-doc/README.md




## (document-meta)

  - #born.
