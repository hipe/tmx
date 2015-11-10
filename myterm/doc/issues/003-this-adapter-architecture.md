# this adapter architecture :[#003]

adapter-related assets as they appear in the generated API ("UI") are a
sort of truncated view on a tree.

the imagined (if not real) underlying structure of our tree is this:

    [ top ]
        ├── adapter
        │   ├── set
        │   └── list
        |
        └── adapters
            ├── imagemagick
            ├── tek
            └── ..

     fig 1. an imaginary view of the underyling structure

each adapter itself has child nodes (the "assets"). when an adapter is
the selected adapter, it gets to populate the toplevel node with
"visiting associations". when read by UI concerns, these associations are
expected to be expressed as if they are any other component associated
with the top node:

    [ top ]
        ├── adapter
        │   ├── set
        │   ├── list
        │   └── [ todo: we should have a "which" operation ]
        │ 
        ├── node-from-imagemagick-1
        └── node-from-imagemagick-2


    fig 2. a schematic view of an imagined generated UI

however, when it comes time for storage (both in memory and on disk or
other (i.e "serialization"), we need to place the data in the correct
location using the full tree, because the full tree must express itself
in a way that expresses *all* adapter-specific data regardless of what
adapter is selected at the time of serialization.

the full tree for (in memory and disk) storage might look something like:

    [ top ]
        ├── adapter : imagemagick
        |
        └── adapters
            ├── imagemagick
            |   ├── name1: value1
            |   └── name2: value2
            ├── tek
            |   └── name1: value3
            └── ..

    fig 3. an imaginary "storage tree" for memory & serialization

it's that simple!
_
