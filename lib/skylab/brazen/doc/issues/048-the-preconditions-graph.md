# the preconditions graph :[#048]


### introduction to preconditions

frequently the [#025] model silos interdepend on one another. for
example we may have a business silo that depends on its datastore silo
(let's say its a database of some sort). the database silo might depend
on a 'workspace' silo (a workspace being sort of a high level wrapper
around a config file). the workspace silo in turn may depend on a config
file silo in order to manage the parsing and ineractions with the
filesystem. in the below graph the arrows mean "depends on":

                                      ____________________
       _________________             /                    \
      /                 \    +--->  |  whatever database   |
     |   business silo   |__/       |        silo          |
     |   (i.e "widget")  |           \____________________/
      \_________________/                      |
                                                +
                                                 \
                                                  V
                                            ________________
                 _____________             /                \
                /             \       +---|  workspace silo  |
               |  config file  |  <--+     \________________/
               |     silo      |
                \_____________/


note a few things about the above graph: there is no circular
dependency. the nodes that depend on each other form a simple chain.
we can put this in terms of graph theory and say that this is an
"acyclic directed graph".

now, consider the above graph and the app you might write around it.
you want to render a listing of the business widgets? ok, is the datastore
silo produced? if no, well we need a workspace controller to produce it. is
the workpace silo produced? if no, is the config silo produced? etc.

to do this by hand we are left with clumps of this-then-that logic about
workspaces etc in model support code that quickly becomes unmanageable.
the "preconditions graph" is an answer to this.


with the "preconditions graph", each model "silo" indicates its
preconditions (often but not always a `persist_to` identifier) and then
early in the request-fulfilling pipeline, each silo that is a precondition
tries to fulfill its slot in the graph by resolving itself in terms of its
preconditions and so on until we hit a depended-upon silo that has no
preconditions (or at least, preconditions that are hand-writen).



## when preconditions aren't met

so, recursively each silo that is a precondition tries to fulfill itself
as a precondition by trying to fulfill its own preconditions. at any
step if the preconditions aren't met, typically an event is emitted with
an invitation explaining at exactly what dependency the resolution broke
down, and the whole (tall) call stack collapses down and out.

(detection of circular dependencies has been coded for and has been
witnessed but #todo is not yet covered.)


## what we have now

the resultant behavior of this in terms of the application interface is
actually the same behavior the we had without these formal preconditions
graphs, but the way it happens now is much more dynamic, emergent, and
relieves us of writing ad-hoc code in the model support code.


## what we may have in the future

although naive currently, this could be used to drive interfaces that are
generated dynamically around what actions are available at any particular
state. in this way, "the interface" could hypothetically be a direct
result of this function of the dependency graph. the graph itself could
potentially drive the program flow, to an extent not forseen when we
started down this path.
