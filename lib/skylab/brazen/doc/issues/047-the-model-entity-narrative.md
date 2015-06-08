# the model entity narrative :[#047]

## introduction

we use the "Entity" metaproperty-powered property-modeling library to
create a custom extension module here.

the extension module we create here models meta-properties that have
business-specific utility for us in this app, but as well these
meta-properties will be used to model the properties of entities and
actions in other applications.




## :#note-360  "entities are not actors"

setting property values to ivars is not recommended because 1) the ivar
namespace is volatile as the framework changes, 2) it is unreasonable to
expect for you to have to keep track of the list of "taken" ivars. this
is explained more fully at [#018].

however, if you want to live dangerously and have your code break horribly
in the future, have a whack at this little hack, but please let's use
it sparingly for now as we wait for a better design to emerge from the
ashes of hacks like these. also, see caveats below.


### discussion

** in theory ** once your action or entity has control of the execution of
a request, the framework may be done relying on any behavior of the entity
at all, so again ** in theory ** maybe after this point the ivar
namespace should be free to use, which if this is true, this hack is
then hypothetically OK to use #experimentally.

regardless, as a safeguard a runtime error is raised if a non-nil-holding
ivar would otherwise be clobbered by this. this is the part that
guarantees that your code is not necessarily future-proof.


## subsections

( :.A, :.B are inline )
