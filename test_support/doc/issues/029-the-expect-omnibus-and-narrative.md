# the expect omnibus :[#029]

## :scope (and about newschool v. oldschool near newlines)

this node is for verifying content & style, but not "encoding" - at
this level we are agnostic about what particular newline sequences
(if any) were used to terminate the tested lines by the rationale that:

  A) the strings and regexes in tests are more readable when they
     don't have to express newline sequences, and

  B) god forbid we ever need to deal with non-UNIX-y newline sequences,
     the tests will be more portable if they are agnostic in this way.

(it is certainly appropriate to test against such concerns, just not
at "this" level, by this statement.)

NOTE the nasty part is that when using those parts of the node that we
designate as "oldchool" below, our legacy code will actually *`chomp!`*
the selfsame string that is being tested, in effort to save a byte or
two. the newer predicate-based techniques don't do this because they
recognize that often they are used against a shared "state" structure,
that needs to preserve its newlines for whatever concerns may expect
them.




## :oldchool-newschool-exegesis

most of this node consists of logic that is redundant with parts of
above; that logic that effects the expectations against the stream
under test. however it is necessarily so because of a bit of a
paradigm shift around our test library architecture:

here, a "matcher" is produced by the expectation structure itself.
(it references the expectation structure and also the test context.)
here it is the "matcher" (and not the test context) that does the
verification and assembles the failure message. (sadly, in a
necessarily stateful way thanks to rspec :P)

the disadvantage is that because the verification does not happen
*by* the test context, the verification code is not as configurable
by the client (and re-use is perhaps not as easy for the subject).

but the advantage is this: in our thinking and in our code we now
more cleanly separate the expression of what is expected from how
we procure the stream-under-test. (and granted we can still have
this under the oldschool way too.)

the key is that the expectation doesn't assume it's reading an
emission stream cached in an ivar. with this cleaner separation,
we can "point" the expectation "at" some throughput of our chosing
more easily. this is crucial for enabling us to run our expectations
against shared (a.k.e "memoized") "state" structures.




## oldschool #intro

over the years 'expect' has developed syntactic idioms; that is, almost all
the various implementations of the 'expect' method in our tests have similar
grammar and semantics, yet few of them are totally compatible.

test facilities like this present special philisophical challenges with
respect to abstraction: they typically exist solely to guide and veryify the
correctness of their respective clients through their lifecycle, with all
other software design axioms taking a back seat to this.

because they are a boostrapipng first seed of logic on top of which to grow
the software, we like them to be a super-stable core. they are typically
expected to perform reliably and without the vunerabilities of external
coupling, at the expense of possibly duplicting a large part of what has
been written before.

on the other hand, given that we do this almost the exact same way 8 or 10
times in a row, to some extent and at some point it is certainly sub-optimal
to do this "by hand" for each new application; and so it would be a worthwhile
effort to invest developing a reusable such facility that is itself de-coupled
enough to perform reliably for every other client except itself.

this document is a first-pass effort at surveying their varieties out there,
with hopes at best possibly to one day distill them, and at worst gather
ideas or look for near-perfect abstract candidates, for each net time we
write something like this.




## hook-outs

### :#hook-out:1

these "invocation strings" are an array of strings. they can be frozen
but need not be - attempts to mutate will not be made to them. they can
be thought of as equivalent to an array consisting of one element:
`$PROGRAM_NAME` typically.




## hook-ins

### :hook-in:1

this is used typically to reach a sub-action of a utility.





(EDIT: the rest of this document is written in a shorthand form that will
probably only be meaningful to the author, and probably only for a short time
at that)


## primitive approaches:

  [sg] expect STREAM_I, RX
  [ba] expect STRING



## middle-weight approaches:

  [hl] expect [ 'styled' ] ( RX | STRING )

  [gi] has two

    • a primitive expect
      • channel is hard-coded to method name
      • STRING | RX
    • a decend one:
      • [ 'styled' ] STREAM { STRING | RX }


  [f2] has a typical custom one, which is exemplary for its scope:

    • [ 'styled' ] { STRING | RX }


  [fa] has an antiquated inteface for it

    • one 'expect' call is for asserting over *all* remaining output


## heavyweight approaches:


  [gv]  geared towards "emission" pattern (what pub-sub evolved into)

    • assert on one channel or a compound channel path
    • [ 'styled' ]
    • optionally match against regex or string
    • optionally yields to an arbitrary block

   ( [gv] ignorably also has:
       • a very custom 'expect' for its mock system
       • a simple custom 'expect' for whatever )

  [ta] (IN A BRANCH, SOMETHING INCREDIBLE)



## :#intro-to-gamma

we almost called it "omega", suggesting cutely that we would actually think
of it as being the last solution, but quickly thought better of this hubris.
'alpha' and 'beta' already have collectively semi-understood meanings in the
context of the software lifecycle, so we pick 'gamma' (the greek letter that
comes after "alpha" and "beta") as the codename for this intermediate effort,
one that might hope to become generally re-usable.

the main thing here is to write just enough to tide us over until we get
the branch to integrate that has a similiar (but now perhaps old) pass
at this.
