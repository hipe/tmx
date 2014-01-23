# the partbuilding scripts narrative :[#028]


## #storypoint-1

this asset wants its child part scripts to know their 'adverb'; that is,
whether they are part of an 'all' build or a 'part' build (or future adverbs).
this is some future-proofing, in case for e.g an 'all' build does something
different at the part level than a 'part' build in the future for any
particular part-building script.

the component node library doesn't propagate such terms as these terms
downward for us; that is part of its point: to consume such tokens at each
step downwards so the component node can remain blissfully unaware of its
context (which may always one day change).

but in this case this 'adverb' as a symbolic name might come in handy. so
with these lines we "hiccup" the term so that it appears again on the array
(but this time at the back not the front), so that when the component node
lib shifts one such term off, the other one is still there and gets passed
down.


## #storypoint-2

typically the list of parameters the particular partbuilding function is
called with correspond to the previous storypoint; namely X



## :#dynamic-scoping-as-ersatz-vtable

in zsh we of course do not have classes or objects; nor should we want them.
but without our familiar paraphernalia we feel vexed about what to do with
this single global namespace for functions. interestingly we can write some
functions anticipating that the functions they call may have been overwritten
arbitrarily to customize the behavior, but this novelty does not scale past
one would be "object".

we do have "dynamic scoping", a crazy feature (that some documenters consider
a bug) whereby if you refer to a variable in a function, and that variable is
not local to that function, the lookup will propagate upward to each caller
of each function and so on, looking for a call frame (or whatever the call
it) that defineds that variable locally (or in the base case, globally).

just to drive ourselves really crazy we are conducting an experiment whereby
we rely on dynamic scoping to facilitate scalable customizability: a library
will popoulate global variables (that should be considere immutable) with
names of functions it define that contain default behavior for things.

these variables are then just acting as pointers to functions, but consider
them "behavior slots" if you like. as the library needs to perform some
behavior (or simply signal some eventpoint), it doesn't call plain old
functions outright but rather calls functions using these "behavior slot"
variables.

then, the real magic happens when the calling function simply sets **local
versions** of these variable names with names of other functions that
customize the behavior as necessary (usually with names of functions defined
nearby, preferably right near by.)

still we have a limited function namespace, but if we name our functions
isomorphically along with the component node (in other words, roughly
following the filesystem); then this whole tecnique can be manageable
and scalable if a little verbose.


## :#when-to-use-volatile-functions

notice we name this function here as a "volatile"-style function as described
in [#017]:#the-name-conventions; in contrast to all the "dynamically scoped
behavior slot" functions going on around us and described immediately above
in this document.

we do this here because of the product of two reasons: 1) calling a function
$like_this looks funny and will throw people off, so we save this technique
only for when there is any chance we would actually want to levarage the
dynamic scoping to get scope-local behavior.

2) we have a API contract that "assets" will always be built in their own
process. sincce this is the case, we may at some point decide to re-write
the process-global (as all are) function "-partlib-help" in a custom way
for this asset. this would then not affect other assets that are built because
they are built in their own process that presumaby wouldn't run the code that
rewrites this function.

building this knowledge into the place it is called is sort of sad, but it
is a trade-off that buys us the win not to introduce the more confusing
surface phenomenon of $calls_like_this.

this technique may be repeated later in these narratives.
