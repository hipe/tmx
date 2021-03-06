## introduction to a headless dream :[#065]

## synopsis


## introduction to this document in context

this document is probably somewhere in the 98th percentile of old documents
by age in our entire universe. we have "hijacked" is from its original
incarnation as a collection of spurious notes and "lessons learned",
and charged it with the formidable duty of carrying this most important
mission statement.

the degree to which the very old remains is a function of how much we
feel like editing it at this moment.




## (sketch)

  - the idea of a headless server is one without a keyboard or screen
  - the "client" "mounts" the "server"
  - we can apply this idea to application design with varying results





## (EDIT: this document is historical and largely no longer relevant)


## this architecture


  + The cornerstone of the headless design pattern (let's say) is that
    things emit events from the same graph, regardless of modality.
    Exceptions to this guideline are possible but annoying.


  + Broadly a headless app can be thought of as a tree of sub-clients,
    with a root client (or "root runtime").  Each node in the tree
    often but not necessarily relies on its parent for services like
    well, services, an emit() implementation, a pen for rendering text,
    environment configuration, etc.  We keep changing the name (in our
    mind and in the code) between words like "client", "runtime",
    "parent", "host", "ui", and many permutations of combinations of
    these. Experimentally we are for now naming it "parent_client" to
    see how that feels.


Following is a module-by-module rundown of the different roles of each
module.

  + Core::SubClient::{ IM }
    + behavior shared by most sub-clients: mostly delegation to parent

  + Core::Client::{ MM, IM }
    + behavior that every root client will usually have, across modalities
    + defines a universal event graph

  + Core::Action::{ MM, IM }
    + behavior that every action object will usually have, across modalities

  + CLI::Action
    + of course pull in the above two .., states its BOX


all of this is experimental and exploratory.

  * root runtime has singletons
  * experimentally, error_emitter is used to emit validation errors




## document-meta

  - #history-A: re-housed document from [tm] from [ze]
