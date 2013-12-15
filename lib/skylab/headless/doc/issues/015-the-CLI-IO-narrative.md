# the CLI IO narrative :[#015]


## :#storypoint-5 introduction

this node serves three uses:

1. its historical first function, it houses the CLI IO adpater whose purpose
   is (from one end) to be a simple structure to encapsulate the holy 3
   streams, (see wikipedia's _Stanadard_streams_ article).
   (at one point we used to pass these three streams around as a unit and
   we may do so one day again, but hopefully not.)

2. also it wraps access to the three streams themselves, so that we don't
   litter our code with globals, and so universe-wide we have a way to
   track and manage access to these streams, in case for example we ever
   need to run under systems without access to one or more of these
   streams for reasons of security, architecture, etc.

3. from the other end there is a higher calling for the IO adapter which
   we leave unstated at present, but when such a time comes as we write
   that doc node it will be here or in a doc node formally related to this
   one.


## :#storypoint-10 (method)

a note about names - here we do *not* observe the [#sl-113] PIE convention
for the names of these three streams: the PIE convention is a higher-level
event-y concern that assigns semantic associations to the different streams.
down here, we just want symbolic names that reference the actual three
streams (whatever they actually are) that are used in the POSIX standard
way of having a standard in, standard out, and standard error stream.

per edict [#sl-114] we keep explicit mentions of the stream globals out at
this level -- they can be nightmarish to adapt otherwise.




## :#storypoint-500

instream is a writer because it may get mutated by the CLI client if for
example it chooses instead of reading from "stdin" to read from a file. this
is the difference between the "instream" and the "upstream": the former refers
to the POSIX stream, the latter is a semantic qualifier, saying "the input
stream (whatever it is)."



## :#storypoint-990 (method)

at first we were like: "life is easier with this behavior written-in as a
default." but then we were all "this will be deprecated" #todo:after-merge
