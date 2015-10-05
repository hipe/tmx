# the persistent criteria narrative :[#014]

## introduction & objectives

there is a "criteria" silo with a criteria model. when we got here it
had a `to_stream` action.

for our puprposes a criteria is an array of strings that is a production
of the criteria grammar for the particular application's model layer.

our objective is to develop the following actions:

  • create a new criteria and perist it (given a sluggish name)

  • mutate an existing criteria and persist it (replace) (same)

  • remove an existing criteria (same)

  • stream the currently persisted criteria.




## "development order" vs. "narrative order"

the above bulletpionts that end the previous section occur in an
arbitray "narrative order". we are not sure why we ordered them that
way, but if we had to guess:

  • the non-first items presuppose that one or more items exist,
    which presumably means it was created, hence we think of the
   "create" action as needing to happen first.

  • perhaps we naturally want to to group actions that mutate,
    so we put the only one that doesn't mutate at the end.

  • "removing" sounds like it has some finality to it, so perhaps
    we naturally want to put it towards the end.

the shown ordering of the actions is perhaps the only ordering that
satisfies all the above cited narrative "design vectors"; but this is
just an arbitrary analysis presented to show one possible justification
for one possible odering towards our point..

another ordering might be the familiar "CRUD", whose equivalent for our
verbs would be:

  • create, • stream, • mutate, • remove

the "design vector" behind the above ordering is something like:
'the items correspond semantically to CRUD ('create', 'retrieve',
'update', 'delete')", whose ordering, in turn, is probably some
product of the "design vectors" of:

  • an ordering by descending order of "importance" for many projects, and

  • it is perhaps the only ordering that gets "mnemonic" points for
    being a familiar word.

(random: consider that "mutate" may sometimes be implemented as a
function of a "remove" and "create".)

but anyway, that all a bunch of detail to lay the groundwork for our
main point: **"development order" is not "narrative order".**

based on recent experience (viewable in the digraph at [#038]), we were
moving towards postulating that empirically, the order that is "best"
for development seems to be something like:

  • stream
  • create
  • remove
  • edit

the above ordering is not a product of design but rather it emerged out
of the ordering that circumstance most often dictated that we chose for
similar cases in the past. applying analysis on this retrospectively as
we are now we postulate that the above ordering emerged from the design
vector of "the principle of evently sized bytes", which as a case-study
we will present and then apply now (and note that what come up with
below is not exacty what we had come up with above):




## the principle of evenly sized bites:

having to deliver more interdependent sub-components in one step vs.
another can make the larger step take longer by a proportionally
greater amount of time than is suggested by just the number of
interacting sub-components themselves, based on the presupposition
that desiging, developing and testing one dependency between a pair
of sub-components costs about the same amount of effort regardless
of how many or few such dependencies there are in a step. consider:

  number of interdependant "nodes"    number of dependency "edges"

               2                                2
               3                                6
               4                               12
               5                               18
               6                               22

if the above model is more or less accurate and the described
phenomenon is more or less true, then for example if you can reduce
the number of interdependant sub-components in your step down to two
from six: two to six is a threefold increase in the number of sub-
components, but a ** more than tenfold ** increase in the number of
interdependencies you have to manage in one step.

our assumption is that this theoretical phenomenon is a "multiplier
effect": how you partition the steps could sink or swim a project.




## applying "evenly-sized bites" to the surronding subject

in our particular design case, let's talk about it in terms of our
storage substrate here: the filesystem. the four steps we are ordering
are essentially about writing adapters that CRUD files to/from the
filesystem. let's look at the opertions from  the perspective of how
many "moving parts" (let's say "arguments") each operation has:


    operation                     moving parts

    stream ("list", ->"retrive")  1) the directory path

    remove                        1) the directory path
                                  2) the entry name

    create                        1) the directory path
                                  2) the entry name
                                  3) the file content

    edit                          (same as `create`, but note this operation
                                   can sometimes be implemented be as a
                                   simple macro of `remove` then `create`)

so, for example, to "stream" our "business entities" requires only one
argument: a filesystem path (the directory). however, to create a new
entity will require three: the directory, the filename to use, and the
content to put in the file.

if by a logical leap we can equate "argument" with "sub-component", then
the above ordering is the only perfect ordering because it introduces
the same number of new components at each step, and that number to boot
is the smallest number that it could be: one (assuming that a step that
adds zero sub-components is meaningless).

in this analysis (and likely all future others like it) `edit` is a
special operation left for the end, because of the reason cited: it may
be the case that we won't know whether or not (or to what extent) we
want to implemet `edit` as a simple "sequence macro" of `remove` then
`create`; so it has the lowest cost to defer this decision to the very
end.

so that's a fun twist. here, then is our final (for now) ordering,
based on a sublime marriage of praxis and theory:

    1) stream
    2) remove
    3) create
    4) edit
_
