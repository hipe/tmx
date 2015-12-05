# the IO spy narrative :[#023]

the IO spy is part of (#parent-node) [#020] the family of IO spy
aggregations ..


## how to use it

objects of this class constitute the member of both the members (sic) of the
[#020] family - 'io spy triad' and 'io spy group'. for the 98% use case it is
expected that you can leverage this node via those nodes rather than needing
to interface with this node directly.


## what it is

(a sizeable introduction occurs in [#020] IO spy aggregations compared ..)

An IO spy is a simple multiplexer that multiplexes out a subset of the
instance methods of the IO module out to an ordered hash of listeners. IO spy
is vital for automated testing, when you need to 'spy' on for e.g. an output
stream to ensure that certain data is being written to it.

typically it's used like this: in places where you are writing to e.g.
$s-tdout or $s-tderr, you should never be accessing these globals (or their
constant forms) directly, but rather they should be assigned e.g to ivars
somewhere and you should be sending messages to the ivars to send message
e.g to s-tdout or s-tdere:

    @out = $stdout
    # ..
    @out.puts "ohai"

in the part of your test where you build your client, assign those variables
instead to an IO spy that has as its only child member (listener) a :buffer
that is a (e.g) ::StringIO. then in your test assertion ensure that the data
in the buffer (::StringIO) is what you expect.

IO spy objects with such a configuration are so common that using the
`new` class method will build on such IO spy object.

  #todo example here using doc-test



## debugging options (:#note-030)

during development, debugging or building a test; having the ability to
see what is being written to a stream in real-time is sometimes
essential. indeed this is part of the intended meaning in our word
choice of "spy".

the typical way we implement a "debug mode" for test insturment is by
passing a `do_debug` boolean value and a `debug_IO` stream, and
conditionally outputting messages of interest to the debug stream
whenever an event of interest occurs and `do_debug` is true.

here we take it one step further: we support a `do_debug_proc`: whenever
an event of interest occurs, the proc is called. the true-ish-ness of
the result determines whether the event of interest is written to the
debug stream.

so note that with this technique as opposed to the previous one,
"debug mode" (as it were) can be effectively turned on or off during
the lifetime of the test insturment, which may be useful to help zero-in
on a problem spot during an especially noisy behavior.

now, given that this is a multiplexer that muxes out to multiple
IO-like streams already, it is too convenient not to leverage this
facility to implement our debugging, simply by adding the `debug_IO` to
be one of the downstreams of the muxer.

so what we do is use the IO filter, wrapped *around* the debug IO, and
we use the `do_debug_proc` to effectively turn the fitler "on" or "off"
based on whether debugging is on or off at that moment.




## advantages that this holds over simpler alternatives ..

.. are discussed in [#020] IO spy aggregations compared ..




## "frame technique" :[#.A]

(EDIT: do we call these "states" now?)

the "frame technique" is a way to break what would otherwise be a
too-large test into smaller tests.

this is an older techinque that we have baked in support for because it
could stand to bring some improvement to tests generally. a "frame" is a
simple, frozen structure representing all the details of an "invocation"
you might be interesting in testing against. its shape is specific to the
mechanism being tested.

by "invocation" we mean something that has various by-products: there
may be not only the result returned from the invocation method when it
was called, but also things like events emitted, or resources written to
during same.

these by-products may have too much detail to be tested reasonably in one
test. we say such a test suffers from poor "granularity". a frame is a
frozen grouping of these by-products so that they may each be asserted
against separately, perhaps in different tests, so that a reasonable
level of granularity is reached.




### implementation

we typically implement frame technique using group contexts: the testing
library's facility of grouping tests (implemented as a module in the
platform, achieved by using the method called `context`).

we say *group* here to distinguish this from the *test* context, which
is the instance that tests are run againt (one per test).

the frame is defined one-per-group-context and is effectively memoized to
be shared within that context: whichever test in the group context is run
first will be *the* test to build the frame (and note there is danger in
this: you don't want the frame to carry any volatile data that was
associated with the testing instance context (which is one per test)).

subsequent tests in this same group context will use the *selfsame
instance* of that frame that the first test used. it is strongly
recommended that frames be frozen (to a correct depth), to avoid
accidental mutation of the frame by one test that would affect another.




### alternatives

the alternative to frame techinque is not to use it, while preserving
the desired level of test granularity: this means to call the same
invocation with the same arguments multiple times, one for each test in
a would-be group context. the overhead of doing so must be weighed against
the overhead (cognitive and othewise) of using frame technique.
_
