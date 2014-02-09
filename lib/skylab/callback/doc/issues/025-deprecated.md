## intro :[#025]

## introduction

event factories are deprecated. instead, for structured events make
subclasses. for informational strings/lines etc, make the shape of the
event be indicated by the names of the channels along which you emit the
events.


## old introduction

This is a caching factory that is built around one box module with no
recursion (the box module is treated as being only 1 level deep).

(The box module's only requirement is that it `respond_to`
`const_fetch` -- it is recomended that you use a plain old module
extended with Boxxy to this end, unless you're going for something
extraordinarily clever, in which case glhf)

For a given event stream name it will first see if it
has an event module (think class) that is cache-associated with that
stream name. If not, it goes up the ancestor chain of the stream name
in the graph and starting from the stream name itself and then for
each ancestor stream name, it looks to see if the box module has
an event module that corresponds with the name of the stream. E.g.
(if your box module is Boxxy) for a stream name of `:error`
and a box module `Events`, it looks for `Events::Error` or
`Events::ERROR`, for a stream name `:file_uploaded` it will look
for an `Events::FileUploaded` or `Events::File_Uploaded` *or*
`Events::FILE_UPLOADED` etc.

Now, (and here's the fun / dodgy part) once it finds such an event
module, it assumes you will want to use that same module for every
other stream name that you traversed over during the search,
(so if :wrong_password_error -> :authentication_error -> :error,
and the first one it finds is Events::Error, it will assume that
you want to use that one module for all three of those streams
in subsequent invocations.)

This will run you into trouble if your event stream graphs are not
coherent thru the system for every event emitter that uses this
same factory!

Also, for graphs that are not trees (i.e. multiple ancestors),
this will almost certainly fall over for some graphs, or have
non-deterministic results!! #experimental



## #storypoint-35

now your `seen_a` list is an ancestor chain at least 1 element in
length whose elements are each stream names none of which are
yet associated with an event class. if `kls`, then it is the first
ancestor you hit that had an associated class. if none, then look
each name up with boxxy starting with the first one in the chain,
stopping at any first found. if none found, fail. else blit
that class association to all the *previous* elements to
`seen_a` and leave an latter ones alone! ALGORITHM!!
