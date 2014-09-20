# the four layer model model narrative :[#025]

## introduction

let's get right to it:


        +----------------------+
        | a (model) controller |
        +----------------------+
                   ^
                   |
       +-------------------------+
       | a collection controller |
       +-------------------------+
                   ^
                   |
         +-------------------+
         | a silo controller |
         +-------------------+
                   ^
                   |
           +----------------+
           | the silo shell |
           +----------------+


each object at each step come from the object at the previous (below) step,
except for those models that chose to skip intermediate tiers (the middle
two may sometimes be munged depending on things like the datastore paradigm).




### 1. the silo shell..

.. is long running, stateless, cannot fail, and "lives with" the kernel.
a silo shell springs up to life by virtue of there being a model
node present (that is, some files on the filesystem in a particular
place).

unlike controller objects which can fail and be hard to get to sometimes,
this shell is a reliable node that we can always reach from the kernel in
order to start to do things related to that model (stack).

for our purposes here we may think that the silo shell exists
primarily to help spring to life the objects at the next tier..




### 2. the silo controller

that's collection*s*, plural: get used to noticing whether or not there is
an "s" at the end of that word. the distinction is one we will need to make
a lot as long as we keep using these names.

the silo controller is indeed a controller, which means (for this
discussion) that it is wired to do some sort of interfacey things: it
holds a reference to what we call an "event receiver", and it may emit
events to that receiver. this stands in contrast to the silo
"shell" above, which does not emit events.

the job of this particular controller at this tier is to produce the object
at the next tier: a "collection" controller.

the reason we have a controller class dedicated to doing just this one
task of producing a collection controller is that sometimes just
producing that collection controller itself is a lot of work during the
course of which a lot can go awry.

for a crude example, a collection controller might exist to model the entity
data that happens to live in a table in a relational database. it would
be the collection*s* controller whose job it is to make sure that the
database exists and that there is a connection to it and so on.

typically these silo controllers will operate at this level: to
make sure that the connection (in whatever form it takes) is made to the
datastore (in whatever shape it is, even if it is just a config file).




### 3. the collection controller [#026]

this is the controller where things can finally start to get interesting.
(see [#026] the dedicated doc node for the full treatment on this.)
your "collection" instance reprents in the abstract all your
objects of that model for some particular scope. its job is to
manage all of the goings-in and puttings-out of that collection. it is
an integral part of (all of?) the CRUD verbs, in conjunction with ..




### 4. the (model) controller

depending on how we do things we may or may not create a model
controller class separate from the model class, but here it is: this is
the thing that..
