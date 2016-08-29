# option parsing :[#015]

## structure of this document

  • introduction & context

  • algorithm overview & objectives - understand the "why" of the algorithm

  • the algorithm itself - in pseudocode with short notes

  • algorithm support - important details in depth

  • "continuations" - code notes (disjoint with each other)




## introduction & context

building on the premises that a) every interaction with any application
is towards the end of invoking an operation and b) in practice the most
common use-cases for niCLI seems to involve first requesting help for
the particular target operation and c) as it has been written so far you
would have to jump through lots of hoops try and create an operation
(adapter) that does not have an option parser that at least serves
requests for help;

to the extent that the above premises hold, we ergo say that it is more
likely than not that for any given operation, under niCLI we will
probably build an option parser for it eventually (but we'll note that
for some invocations for some operations, to build the option parser
will be extraneous as we'll discuss below).

to build an option parser will engage all of the theory we have laid out
in [#027] and then some - it is a relatively "heavy lift": we need to
know the #scope-set which involves determining the formal node category
for every association in the compound stack which in turn involves
loading every model referred to in it.

cacheing is only helpful here if we take into account that a) this is
niCLI so it is not long-running :[#034] and b) as we always metion it,
[#ac-002]#DT3 the ACS tree is dynamic so we have to assume that all
indexing is just a "snapshot" of this moment.

the central challenge then is to effect this heavy lift and not have to
go and do *another* heavy lift when we go over to "procure bound call"
(for now tagged with [#027]). let's make a :"big-index" here that we
will re-use there.




## algorithm overview & objectives

here we introduce the key characters of the algorithm and discuss what we
want out of it in plain language before we present it in pseudocode.



### the option parser

the option parser is generally all the the primitives in the scope stack

  • but with the appropriative required's removed

  • and the bespoke optionals added.

we want the options in the option parser to be in this order:

  • any bespoke optionals first (in the stated order)

  • scope stack primitives from topmost frame to root,
    and then within each frame in stated order.

this way we see every such node as having a "weighted pertinence" to the
formal operation. we assume that bespokes are generally more pertinent
than the appropriateds; and then that for the appropriateds the
proximity of their stack frame generally relates to their pertinence as
well (the closer the frame, the more pertinent the primitive).

((#c4) below is a dog-ear about availability as it relates to the o.p.)



### the arguments array

the arguments array is:
  • primitives in the scope stack that were somehow made required and
  • bespoke required's.

note that for now we do not ever express the trailing optional argument
but we want to leave this door open for the future.

we have not yet implemented the glob but intend to (tracked as [#023]).



### the operation index

formerly called the "big index", the work of sorting and arranging the
nodes above (scope and stated alike) will be stored in an "operation
index", inside of which is a "scope index" that will be re-used for any
operation-dependencies.




## :#algorithm

    traversing the the scope stack from top to bottom (note :E),
    for each formal node in each stack frame,
      if the current node is an operation,
        index it as a potential referent
      else if it's primitive (note :A)
        index it as a potential referent
        add this index to the option parser box

    for each stated formal parameter,
      if it's an appropriation
        if it's primitivesque
          if it's required
            subtract it from the option parser box
            add it to the arguments array
          (note :B)
        (note :C)
      otherwise (and it's bespoke) (then generally, but see figure 1.)
        if it's required
          add it to the arguments array
        otherwise
          add it to the option parser (note :D)
    _

    note A: determining if a formal node is (for example) primitive
    contributes to this being a "heavy lift" because it often loads
    external files (namely whatever the component model is).

    note B: otherwise (and it's an appropriated primitivesque
    optional), we ignore it so that it stays in the index it is
    already in to go into the the option parser. there may be more
    comments inline at the corresponding codepoint.

    note C: an appropriation that is not primitivesque must be of a
    formal operation (a [#027] operation-dependency). we ignore these
    here - they see expression neither in the o.p nor in the args.

    node D: blah blah without description (unless etc) and something
    about value store.

    note E: top to bottom because we wan the more relevant entries
    to appear "physically" higher up in the UI (and we associate
    frame height with relevance as explained earlier).




## algorithm support

### "set" theory -

let's focus on the "stated" set so that we can implement :#"stated values":

  • any name that is in the stated set either is or isn't in the scope set.

  • IFF it's in the scope set then it's appropriated.
    based on the defintion it is then either "app'd req'd" or "app'd opt".
    let's make sure and cover these two (#tB1 and #tB2).

  • otherwise (and it's not in the scope set), IFF this then it is bespoke.
    based on the definition it is then either "bes red'd" or "bes opt".
    let's make sure and cover these two (#tB3 and #tB4).


### storage

we do *not* want parameter values to "live" in multiple places. if the
value is of an appropriated parameter, then *the* correct place for this
value to live is in the ACS tree..




-----------------------------------------------------------------------

## "continuations" (disjoint code-notes)

### :#"c2"

although at first it's tempting to think that depending on how the
operation is implemented (proc or session), we might want to cater the
argument assembly for the particular shape; in fact we always want to
assmeble the actuals into a "random access box":

you would expect to want the random access box for the session, but the
reason we used it for proc-based implementations too is because
proc-based implementations do not isomorph as you may expect: for both
globs and optionals, they get expression treatment that is uniform with
requireds, one "slot" per formal parameter.





### :#"c3"

..specifically, the published API for the o.p calls for it being
defined *in the context* that we would call the "parameter store",
which is associated with a single invocation. for an options-
based invocation of help, we need to interface with the same
o.p 2x (once to invoke and once to summarize, two disparate
code places). the natural choice, then, would be to memoize the
o.p *in* the modality frame. as such it is less awkward to be
able to define the o.p as a separate concern without having it
depend on the particular parameter storage instance.




### thoughts on availability.. :"#c4"

what we will attempt here w/ availability is this: we do not
determine availability at the time we build the option parser. (the
cost of this is that we run the risk of including an association that
is not actually available.)

rather, we evaluate any availability only at the time that any value
is about to be processed for the association. the gain this way is
that the options that are passed to the option parser can turn-on or
turn-off other options (in an order-sensitive way!).

note too that if an association value is expressed multiple times
in an option parser (even with for e.g "-vvv" to mean three verbose
flags), the availability is re-valuated each individual "time" the
option is invoked (where in the example it would be invoked three
indivdual times).

putting the above two points together: if for example you were crazy
you could enforce a limit on the number of times such a flag can
be used, emitting a parse error if it is breached.
_

# (there is a #photo of the whiteboard version of the algorithm)




## :#note-1

for typical use cases we load the stdlib option parser library (`optparse`
and `::OptionParser`) and we use this module 2x: once to build the o.p and
once to catch parse error exceptions that are thrown from it. (we don't love
the use of exceptions as part of the "normal flow" (of handling strange
option flags; to us that's normal), but that's the way the library was
designed and we've got to follow it to be idiomatic within the platform.)

if the client provides a custom option parser (however that happens), then
for now we *still* load the stdlib o.p lib for these reasons:

  - maybe the client's custom o.p implementation will still draw on the
    stdlib o.p to ask it (for example) how wide to make margins etc in help
    screens (so loading the library is not wasted in these cases).

  - our code's (sadly necessary) exception-handling spot is pseudo-hard-coded
    assuming that stdlib o.p exceptions are being thrown, because it is
    usually they who are.

in order to localize all these assumptions, we use the subject ivar instead
of a plain old constant reference to the stdlib o.p module.
