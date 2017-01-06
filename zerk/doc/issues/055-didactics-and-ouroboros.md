# didactics :[#055]

## objective & scope

a "didactics" is an experimentally standard structure meant to
contain and expose (almost) all the components necessary to express
a help screen. to imagine it in MVC terms, if the particular
expression behavior of the help screen is the "view" logic then the
"didactics" is the model.

hypothetically the subject could be used towards expression in
any arbitrary modality that wants to express such a structure, but
for now the only consumer of this is a CLI-expressing agent for
render help screens.

the subject is an abstraction meant to decouple us from both any
particular help screen expression facility and any stringent
requirements that particular "operators" must follow - with an
agreed upon "didactics" structure as an intermediary, it is not the
case that each particular operation (etc) need to fulfill a long
laundry list of reflection methods.

rather, the particular remote application can implement the
production of a standard "didactics" structure in whatever way best
fits the particular remote architecture (for example, a proc-heavy
vs. class heavy model, a shared operator base class or no, hook-in
methods vs. constants, etc). as new "best practices" are explored,
they can be applied without needing to alter the code of the higher-
level client(s).




## the constituency of the membership in detail

here's the four members of the structure, then a critique of each:

  - `is_branchy`
  - `description_proc`
  - `description_proc_reader`
  - `to_item_normal_tuple_stream`



### `is_branchy`

the degree to which this boolean impacts the expression of the
screen is a point of some experimentation. in the old days this was
a very strong structural distinction to make of an interface node;
however these days because of the rough-and-tumble nature of
"argument-scanner"-driven architectures, the expressive distinction
between "branchy" and not is diminishing, but may not have yet
disappeared completely.



### `description_proc`

for the subject node itself. exactly like its forebears, might
one day execute under some "expression agent" with a standard
inteface.



### `description_proc_reader`

this object must respond to `[]` which will receive (in its perhaps
mutiple calls) any one of the symbols produced by the member
described next. the producer of the subject will typically
implement this with a hash or proc, but it could be anything that
responds to monadic calls to `[]`.

these calls must either result in a description proc or a false-ish.
the particular behavior for what the expressing agent will do with
false-ish is not proscribed, but it is guaranteed not to cause failure.



### `to_item_normal_tuple_stream`

an "item normal tuple" is experimentally:
    [ { :primary | :operator }, normal-name-symbol ]

this is modeled as a "streamer" instead of a "stream" so that this
otherwise stateless subject structure can remain so.




## about the exclusion of the constituency of the membership

note the didactics does not maintain any sort of "name" for the
subject node itself. we used to include the string `program_name`
in the membership, but we do no longer for two reasons:

  1. this was the only component of the struct that was
     heavily "modality centric".

  2. we model it as *not* within the responsibility of the "didactics"
     itself to represent the "name" of the operator, but rather as
     a detail of the invocation. at present, name information is
     emitted directly in the `operator_resolved` emission that the
     service emits at the time of resolution.




## notes

### :#note-1

experimental, this is the remote service telling us that it
succeeded in resolving a next opera*tor* from the head of the
argument stream that we handed off to [wherever]. if now or
at any point in the future we will want the associated normal
name symbol (or any derivative thereof), we've got to grab it
now because the argument scanner is mutable and in motion..



### :#note-2

the structure of this selection stack was once simple and lazy.
(it used to be a chain of zero or more symbols and alway as the
"last" element one proc that produced a didactic structure.)
but now it's more a traditional "selection stack" structure, so
that A) we preserve the name object created anyway by the far
remote service, and B) we can put the operator somewhere where
reflection is necessary to ask business-specific things when
customizing expression.




### :#note-3

in opposition to [ac]'s whole "autonomous" "component" philosophy,
we are wedging this in here to see how it feels: we see if the
subject operator has a "parent". (by "parent" we mean an operator
(necessarily "branchy") that lives one level below the subject
operator on the selection stack.)

if the operator has a parent, we let the parent act as a sort of
"curator" that particpates in expressing the subject operator.
in this "curator" model, it is the parent and not the subject
operator that decides:

  - the subject's name (slug)
  - the subject's description (proc)

any parent may then defer back to the child to let it describe
itself.

the advantage to the "curator" model is that the descriptions
that go into one "splay" are all near each other in easy to
read methods (typically); and the parent doesn't need to load
each child node to produce its splay.

the main disadvantage to this model is that we lose the "drop-in"
feel of autonomy, and that built-in to the parent must be knowledge
of child's means of exposing description (where appropriate).

mainly this was conceived so that we can allow our help screen
system to recurse but not have to re-architect our code; and as
an experiment of course.




## connection to history

it's worth mentioning that this is a throwback to a much older
idea called "ouroboros". in fact we have spliced this new content
into the ancient document about the same, whose original content
now follows:




#==TO
# ouroboros - a snake eating its own tail is a thing in cultures :[#098]


## introduction

the whole idea of everything is that we can assemble "reactive units"
together like legos to make "macro" applications from modular pieces.

for this to work, we want these units to behave equally well
whether they are the root or a child node of a tree.




## about this document

this document bridges together content whose sources are years apart. as
it stands now, it is not yet fully integrated into one seamless
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

# :#tombstone: we ate the soul of document [#!hl-069] to obtain its power
