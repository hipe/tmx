# the expect omnibus :[#029]

## #intro

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
