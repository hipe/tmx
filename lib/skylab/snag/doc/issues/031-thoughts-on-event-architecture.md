# thoughts on event architecture :[#031]

## thoughts on API action event stream graphs

at first analysis the P.I.E standard is a good rubric, b.c if for no
other reason it is familiar and suggests what to do with the events.
*HOWEVER*, from the API side it should be less concerned about the
meanings of things (is this invalid object an error or just info
or a payload?) and more about what they are, in terms of both structure
and semantically as a noun, etc.



# thoughts on event wiring..

## at the mouth of the river

it is tempting to, at the modality client level, simply call_digraph_listeners
whatever events you end with as events out to whoever is listening to
you. The problem is that it is your job ultimately to decide how events
turn into strings - f.w's and libraries will not (nor should they,
yeah?) do it for you.

So for now we flatten events into strings before they leave the mode
client.

## the new frontier of event graphs..

For a given modal chunk of your system that is a source of events
(an API being a perfect example), it should
A) have an event omni-graph that is coherent with itself, that is
an event with a stream name .. NO


## thoughs on UI.. (specifically invitations, e.g)

The modal action is a good place from which to *issue* an invitation to
e.g more help.
1) it is silly and bad design to put such a high-level nerky deep within
a call to e.g `execute` or `process` (even at the end)
2) putting it at the mouth of the river, in the modality client, with
no decoration is bad because you loose the context of the call. what is
nice is to have the modality client actually render and call_digraph_listeners the
invitation, but use e.g the modal action reference in its nerkage.
this is how everyone can be happy.
