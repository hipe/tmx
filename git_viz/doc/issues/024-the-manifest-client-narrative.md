# the manifest client narrative :[#024]

(EDIT: this document is all +#archival. the simplified [#007] replaces this.)

## introduction - the client is the right kind of simple

this "client" is a simple (as simple as possible) ruby script. users of the
script need only know that it is executable and is run from a shell. the fact
that it is written in ruby is arbitrary and an implementation detail.

it connects to a zeromq "port" then send requests to and receieves responses
(as available) from the [#018] "manifest server" (or "system call server",
or "fixtures server" -- we're not sure what we're calling it yet). all of the
hard work is done by zeromq which makes this a sheer joy to work with.



## the shape and rhythm of our output in general

because this node acts as a little middleware that lets shell scripts talk
to our server, our responses from this script are designed to be something
that is easily read by those scripts. so our responses from this node look
like this (get ready): we call_digraph_listeners to stdout a sequence of tab-delimited lines
representing the manifest entries filtered by the options provided in ARGV.

make no mistake, the nodes of our n-tiered, distributed architecture
communicate to each other via command-line parameters and tab-delimited
output. we have chosen this path (experimentally) because it is the cleanest,
simplest (and still robust enough) way that we have yet come up with to talk
to our server from our shell. and to any extent that it works robustly while
allowing us to send the information that we need to send without jumping
through hoops, it's a tribute to the architecture being the right kind
of simple.

having the "protocol" for our API be of a substrate that is this 40-year
old technology buys us the following wins:

  • limited only to libraries in stdlib ruby (that is, no "external"
    libraries), we can have one ruby in one process talk to another
    ruby in another process (and I mean "MRI" talking to rubinius talking
    to jruby, what have you). just think about that for a second.

  • why stop there? we can swap-out ruby for any other technology that
    is current with this 40-year old technology, and it could be made to
    fit with arguably the least amount of pain vs. any other such substrate.

  • because these shapes are decidedly human-readable in both directions,
    these nodes are their own client for the purposes of visual testing,
    manual testing, troubleshooting. i.e, it is easy to test these components
    in isolation because of how trivial their interfaces are.

  • this shape allows us to mock these nodes trivially. (but consider for a
    moment why we are not going to go down that route presently.)


## the shape and rhythm of our output in particular

the first "field" of our emitted "rows" is always a channel name: one of:
"trace", "debug", "info", "notice", "error", "payload". we won't necessarily
be using all of these channels, but every channel that we do ever use should
be from this list. (come back and edit this list here as necessary).

(from the backend, semantic "chunks" of result are called "statements",
and one statement will usually translate to one row here, so we may use
the term "statement" rather than "row" here).

of the above list of 6 categories of statements (or "channels") all but the
last kind will typically consist of only two fields: the first field is a
string specifying this channel name (as it always is), and the second field
is a string with an unstyled, human-readable, screen printable message.

as for the "payload" statement, such a row may consist of something like
seven fields: 1) the channel name (again, the first field is always this),
2) the string "command" (this is a "shape specification" to future-proof
ourselves, to allow ourselves to call_digraph_listeners polymorphic shapes of payload alongside
each other other than just commands in the future. but for the present
way may be able to just ignore this field.)

the remaining five fields are the relevant, normalized and formatted
elements of the command as reported to us from the manifest server.
what those fields are is explained in [#018]:#the-fields-of-a-record-command.


### we don't call_digraph_listeners to stderr because:

we do not ever call_digraph_listeners to stderr from this node because to capture both stdout
*and* stderr from a shell script, while certainly possible, would not be easy
(if possible at all) while processing the output from this script in a
streaming, line-by-line sort of way as we are doing. (note too that we will
"capture" the exitstatus of this script as well.)

because we are already communcating back to the shell script using these
"channels", anything that we would normally want to write to stderr we just
send over the appropriate channel (which happens to go over stdout).
