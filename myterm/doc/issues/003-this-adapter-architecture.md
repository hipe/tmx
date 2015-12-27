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




## :#more-about-conservancy

this cache must work for the unserialization of any possible serialized
payload, so it must possibly traverse the entire adapter collection,
even adapters that may not be activated at the moment.

however each load ticket in the cache is itself produced lazily, so
for any set of adapters greater than 1 in size, there exist
serialization payloads the unserialization of which will not incur the
full traversal of the list of adapter paths. the degree to which the
traversal of paths will be perfectly "conservative" depends on the
order of entries returned by the filesystem against the constituency of
items in the serialized payload.

but in general this isn't a big deal, because the load ticket itself
doesn't ever load more than is requested of it - if only the name
(function) is needed, the particular adapter (file(s)) is never loaded.
if only the component association is needed, the adapter front file is
loaded but the particular adapter instance is not built, etc.




## :#more-about-hot-cold

we cache "load tickets" so that we only ever hit the filesystem and
effect name function transformations once per adapter per runtime.
an appropriate place to cache such data is in a "silo daemon".

all "silo daemons" are to be considered long-running and not bound to
anything (cold not hot, cannot emit events internally, only to handlers
passed in a method call). this is so they can be used within different
other model "silos" and across actions.

this "coldness" of all silo daemons must also apply to all data cached
within them (recursively downwards). as such the load ticket cache in
this silo daemon must be cold as well, as well as every load ticket.

any particular adapter instance is presumably "hot" - that is, while
not explicit, it implicitly has one custodian listener. (here we'll use
"hot" as a synonym for "bound").

because adapter instances are hot (by our design) and load tickets are
necessarily cold, we cannot put the cached adapter instance in with the
load ticket. this is why it is cached in the (hot) "adapters" entity
instead.




## :#note-about-serialized-references

in serialization, the "adapter" node serves only to hold the name of
the selected adapter (if any) and the "adapter*s*" node serves to hold
persistent data about whichever adapters want to store data.

in the runtime tree, however, the "adapter" node actually holds the full
adapter that is selected (if any). to make this work is actually
tricky:

the order that serialization occurs is not reliable, nor should be.
so the "adapter" node cannot resolve the reference to any actual adapter
it holds until all unserialization is complete ..




## :how-component-injection-is-currently-implemented

1) an adapter is selected IFF the above ivar is set. per the
component association that defines it, the ivar holds not the
adapter itself but a "selected adapter" controller. this ivar is
set *only* thru a signal handler in this file or underialization.

2) if an adapter is selected, it can add nodes ("qualified
knownnesses") to our interface stream as if they were our own.


### :somewhat-nasty

we do a tremendous hack to "inject" an association:
the SELFSAME association object is MUTATED so that it reports
it is a sub-category of `visiting`.

  • `method_missing` hacks are nasty and we never do them.

  • we were hand-writing the proxy class but it didn't scale.

  • we mutate these guys because they are regenrated on-the-fly anyway.
    if this doesn't work ok, dup-mutate should work.

  • maybe this is a [#sl-003]




# (notes from the particular adapter base class)

## :#note-about-explicit-readers-writers

the "ACS way" (at writing) is about not subclassing nor pulling in
mix-in modules, but rather The ACS querying for various hook-ins as it
operates. part of this is that for component reading and writing, the
default assumption is ivar-based memoization. the two methods near the
subject codepoint are an explicit implementation of this default
behavior. the only reason we have implemented what is default as
explicit is because it "feels better" (and will operate with less
overhead) to have the decision effectively cached that this component
uses ivar-based storage.
