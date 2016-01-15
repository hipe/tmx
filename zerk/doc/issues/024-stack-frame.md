# stack frame :[#024]

(code notes/algorithms)


## "why linked list"

like for the API modality here and for somewhere in
[ac], our parsing is stack-oriented both in implementation and in the
resulting representation. (and in this platform when we say "stack"
we usually implement it with an array.)

however, experimentally we are implementing the stack as a linked-list.
a property of this arrangement is that every stack frame can access its
0-N parents (that is, frames below it). as such, any top frame can
always access the whole stack.

this was useful when we were trying to get the top frame of the
selection stack to build the option parser; but as we are no longer
attempting that, this is now just an auto-didactic exercise, and a
safeguard if we change our minds back and attempt this again.




## "on avoiding wastefulness"

TL;DR: you have to index every frame of your selection stack eventually.

to understand where the below discussion is coming from, assume that
to build an association structure that you end up not using is wasteful
and bad. now:

assume you have provided meaningful and full names that select a
selection stack that is N frames tall. (N is always at least 2.)

frame 1 is always the frame representing the root ACS. (this frame was
not resolved by names present in the argument array. this frame is
always a given.)

frame N is the frame representing the formal operation.

what remains are zero or more "non-root compound" frames.

because of how the [#ac-022] reader works, if a meaningful and full name
was provided for each of the frames that needed resolving (i.e 2-N), then
the reader was able to use its "random access" function, and so we only
built associationesques that would end up going towards the selection
stack. i.e none were "wasted".

now imagine that instead, only partially matching names were provided
for one or more of the frames 2-N. (we might say it has "dropped-in"
to "fuzzy mode".) because the streamer produces streams that produce
*nodes* (and nodes are not associations, they are more like [#ac-018]
"load tickets"), again we don't necessarily have to build associations
that are "wasted" because we can use the isomorphic name functions of
the the nodes without having to touch the association.

HOWEVER (and here's the rub): once you have a complete selection stack
then you will need to "go back over" each compound frame of this stack
to build the option parser for the "scope" it creates (as to be described
in [#015]).

option parsers are derived from primitivesque associations. to figure
out whether an association's model is primitivesque, you have to build
the association (not the same as building the component). that is, the
method that defines the association has to be called. you can't infer
the shape of the model from the name of the method defining the
association (yet)).

as such, assuming an optimistic model where requests (whether fuzzy or
not) tend to result in complete selection stacks, for such cases you
will end up doing the work of indexing every frame in your stack anyway.

(the reason this challenge exists at all is in the inherent
interplay between the design tenets of [#ac-002]#DT3 "dynamicism"
and [#ac-002]#DT4 "conservatism", both of which are important.)

also this will all be effected by #mask'ing and [#017] tailor-made
option parsers.
