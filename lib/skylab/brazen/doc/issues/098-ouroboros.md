# ouroboros - a snake eating its own tail is a thing in cultures :[#098]


## introduction

the whole idea of everything is that we can assemble "reactive units"
together like legos to make "macro" applications from modular pieces.

for this to work, we want these units to behave equally well
whether they are the root or a child node of a tree.




## about this document

this document bridges together content whose sources are years apart. as
it stands now, it is not yet fully integrated into one seemless
narrative. not all the dots below are connected as they should be..




## some history

the "classic" model of our applications is something like this: a
top-level "invocation" (or just "client") is something like a branch
node, made up of nothing but child nodes.

each child node at this level, in turn, is (typically) yet another
branch node. finally, *its* children are each (terminal, "leaf" node)
actions or other branch nodes.

at a concpetual level at least, each one of the would-be classes for
these nodes descends from and/or is composited from each other:
an application is one big giant action; an action is one little tiny
appication, and so on:

                 +-----+    +---------+    +--------+
                 | app |--<>|  model  |--<>| action |
                 +-----+    +---------+    +--------+
                                |              ^
                                +--------------+


    fig. 1 - in the classical (er) model, an app has many "model" nodes.
    each model node has mnay actions. the model and app (not pictured)
    are themselves like actions.

classically, exceptions could be made to these truisms: it is possible
to make an application (call it a utility) that consists of nothing more
than one action, etc.

(historical interjection: what we now call "model" we used to call
"namespace". we let the old name remain in the historical text below
because there is still some semantic merit to it as a name.)

let's say you have an application with a total of five terminal commands,
and four of them are nested accross two namespaces. your graph might be:



                                 +-[ act1 ]
                                 |
                       +-[ ns1 ]-+-[ act2 ]
                       |
               [ app ]-+-[ ns1 ]-+-[ act3 ]
                       |         |
                       |         +-[ act4 ]
                       |
                       +-----------[ act5 ]

    fig. 2 - a typical small-sized application topology





## boundaries :[#.A]

in a "reactive tree", typically these sorts of resources are shared:

  • a filesystem
  • stdin, stdout, stderr
  • an environment (as in variables)
  • ARGV (provided your pipeline plays along)

and typically these sorts of components are not:

  • the invocation array of slugs
  • event handling logic





## for posterity, the original comment -

( This grain of sand is all that remains of the once vast [fa] empire: )

    # here we have "ouroboros" - a particular hot action's particular sheet
    # is a very important thing - it determines all of the below properties
    # from its sheet, which in turn go on to determine largely the action's
    # behavior. "ouroboros" is an experiment in combining some aspects from
    # the action's intrinsic inner ("head") sheet and some more superifical
    # aspects from the `mod_ref`-having namespace ("tail") sheet that first
    # references the node and puffs it into life. The upstream client maybe
    # wants to give the child node e.g a different slug or different aliaes
    # than what it has in its inner sheet. One wrong way to accomplish this
    # would be to mutate the intrinsic sheet. In an imaginary world this is
    # very bad, for reasons. A less wrong but still wrong way would be that
    # you write for each such property an ad-hoc getter in your client that
    # ancicipates there maybe being e.g an ivar having been set which holds
    # the strange value for that property. But the wrongmost way of all is:

    # (NOTE here are the different terms we have used at various times for
    # the two sides of the duality:
    #   tail = surface   = extrinsic = outer = higher = upper = hi
    #   head = intrinsic = intrinsic = inner = lower  = lower = lo )
