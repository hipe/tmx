# the minimal yielder universal abstract property :[#096]

## introduction

definitions of methods with the subject name MUST comply characteristics
described here.

we'll call this a "universal abstract property", which is similar but
not quite the same as a :+[#br-041] universal abstract operation.

such a method results in a "minimal yielder". we should not assume
(quite yet) that the purpose of this yielder is to accept a series of
strings, but so far it always has been.

in summary, for all clients that need to accept a series of strings in a
session-less way, those clients should follow this universally normal
name and interface.




## it is both convenient and manifest ..

..to assume a simple, single-method interface for the object resulted by
the subject method.

if we use `<<` as that method,

  • an IO complies to the subject interface (but see the next section).
    an IO is (of course) a popular qualifying object used by clients
    (simple and complex) running in production that want to write
    strings for example to a file or to stdout, etc.

  • an array complies to the subject interface, making it a convenient
    no-library (i.e "in-platform") solution for testing, to serve as a
    "spy" or whatever.

  • a string complies to the subject interface, making it perhaps useful
    (as applicable) as a spy for testing; and perhaps by use in other
    clients that which to have a single string contain the resulting
    contents of a call.

no other method with the desired semantics exists in all the above
corresponding platform classes:

     [ Array, IO, String ].map { |c| c.instance_methods( false ) }.reduce( :& )
     # => [:inspect, :<<]

furthermore:

  • if you want to write your proxy-like "adapter" you can just create
    an Enumerator::Yielder without needing to write your own class.


consider:

  • `push` would be the idiomatic method to call on an array, but this
           message is not well received by an IO nor a string.

  • `concat` is likewise the idiomatic name for this operation on a
             string, but this message is meaningless to an IO, and to
             an array it has a different signature (we concat arrays to
             arrays, strings to strings. what we are after is a method
             that accepts strings down the board.)

  • `puts` would probably be our preferred choice if we knew we were
           working with an IO:

             + it is a semantically perfect counterpart to `gets`,
               which is itself a UAO :+[#br-041]

             + it does the thing with adding newlines IFF necessary

           but we don't know that we are working with an IO, which
           segways perfectly into the next section:




## there's one gotcha when working with strings:

above we PROVED that `<<` is THE compelling choice, ("manifest" even,)
being as it is the only method with the desired semantics that has
universal, out-of-the-box availability across the classes we want.

the gotcha is this: don't use `<<` as if it's the same as `puts` because
it isn't. remember that whereas `puts` lets you be insensitive to
whether you are adding newlines yourself, `<<` does not.

the onus is on the client to manage this.
