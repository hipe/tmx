# understanding the queue - the queue narrative :[#143]


## :#storypoint-05 introduction to the queue

"the queue" is a core facility that is for now available for now only under
the CLI client component. it is not be confused with the parameter queue
which is an unrelated concern.

as for this queue, we refer to it simply as "the queue". we don't give this
queue a more specialized name (e.g "task queue") because given its primacy
to the the inner workings of the component, it deserves to have an entire
single word dedicated to it.



## the scope

significant portions of the queue's interface are :#API-private which means
it is subject to change radically at any time, or even be obliterated
completely. we follow strictly our own name conventions for reflecting the
API-visibility of methods in their names, as is or will be described in [#119].



## the purpose

the core objective of the queue is to faciliate "atomic"-like, multi-pass,
semi-transactional processing of a request: we want to be able to articulate
a strong distinction between a "parse" phase and an "execution" phase of the
request.

for small command-line apps this distinction is not usually important, but
this library supports more than small command-line apps.

for an example of how an app might suffer from a poor distnction between
these phases, consider the ruby stdlib optparse library's implementation of
`help`: - it writes output and then issues a system exit **as it's parsing
the input arguments**. it probably does this because it is literally the easy
way out, and it is par for the course for command like untilites, that call
a system exit whenever they please because they think they are done.

for us this behavior is a showstopper. for one it makes testing near
impossible; for two, it sets a bad example for others; and for three, it
makes it difficult or impossible to integrate such applications into
larger systems.

more genereally it is a requirement that this library never call `exit`
anywhere. whether or not that operation is arguably appropriate for any
library to do generally, it is deemed as squarely outside of the domain of
responsibility for this one for any reason.

also for many many other reasons, if you're doing any heavy lifing from
within an option callback, you're probably gonna have a bad time.

by gathering all the request data together in one pass, and then acting
on it in another pass, we give ourselves the flexibility to decide
intelligently how to reconcile the means by which multiple task may be
execued in series (for example by short-circuiting, or by effectively
re-ordering the tasks before they are performed to manage their
inter-depenant side-effects).



## the API in general terms

the operations that the client may perform on the queue are supposed to
be based (conceptually at least) around the three familiar verbs of the
eponymous data structure (see wikipedia's _Queue_(abstract_data_type)_).

however we have a bevy of customizations and fine tuning for this to work
with the various ways we interact with this queue. for one, we rarely
just "dequeue" (in fact it is not a supported operation). thank goodness
we are working in a single-threaded world, because dequeuing happens in
two steps: first a "peek" then a "release". this is because we never dequeue
an item until we are completely done using it (although this may change).

around the peek-like and dequeue-like operations we have many permutations
that wrap the call with particular assertions about what is expected to
be at the front of the queue.


## :#storypoint-120 case study in one name

to give you a hint, there is currently a `peek_any_some_element_i` method.
this graceless name tells us five important things: for one, because there
are no "tersified" words (abbreviations), we know this is part of the public
API of this node. because the verb is "peek" we know from queue terminology
that it shows us something at the front of the queue. because it says "any",
we know that it is not guaranteed to have true-ish results; that is we can
assume that it will result in `nil` if the queue is empty.

the fourth and fifth points here are bit of semantic liberty: for starters,
the "_i" at the end tells us that if something trueish results from this
method, it will be a symbol. ("i" is for `intern`, a method and term related
to symbols (from "%i()").)

"some" is typically the converse of "any" - "some" typically means that if the
noun-thing is non-existant then an exception will be raised. but in this
case we said "any" so nothing will ever be raised, right?

in this case when we put all this together, what it means is that this method
is part of the node's public API, and if the queue is not empty this will
give us a peek at the last result and in so doing, assert that it is a
symbol (and otherwise raise an exception). if the queue is empty the result
is nil. whew!
