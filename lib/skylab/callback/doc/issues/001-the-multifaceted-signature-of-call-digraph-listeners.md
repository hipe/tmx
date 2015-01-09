# this historic document..

.. has been converted to note-taking scratch, to this end: we wish to
turn "event factory" into a grain of sand.




face                q [X] unified, OK
porcelain           Q [X] textual, unified, OK
headless            q [X] isomorphic, OK
callback            q [X] unified, OK

permute             Q [X] isomorphic, OK
dependency          Q [ ] textual, unified, OK
code-molester       Q [ ] structural, isomorphic, OK. (last both)
sub-tree            q [ ] textual, unified, OK. (last both)
treemap             Q [ ] datapoint, explicit OK (last both)




unified 5
textual 3
isomorphic 3
datapoint
structural 1
explicit 1
late 0





# The Signature of Emit :[#001]

(EDIT: this document is historic and is largely deprecated by point [#035])

Life is much easier and more readable if you assume a syntax like:

    call_digraph_listeners type, *payload

where `payload` is often a single string.


However, remember these other important and essential variations of `call_digraph_listeners()`:

  + when the event has no metadata, like `call_digraph_listeners :done`
  + when you are [re-] emitting custom event object, like `call_digraph_listeners my_obj`
  + emissions with structured metadata: `call_digraph_listeners :nerk, ferk: "blerk" ..`

Etc.  For this reason we have to assume that `call_digraph_listeners`() takes one or more
parameters and we have no idea the shape of the parameters.


## what to do about it

In some applications an action will somehow get a hold on a particular
event (e.g. from an API call), and want to re-emit its own "version" of
that event; and by that we mean take the same payload of the previous
event, but emit a new event that has a different stream name and is
under the different event stream graph of that new action.

A hackish way to accomplish this that saves on lines of code *and*
memory *and* execution time is simply if the new event's `@payload_a`
member is simply a pointer to the exact same array of the original
event. This is a big experiment, and will definately pose problems
unles we agree that:

1) `@param_a` should be one-time write only immutable, and should always
be the exact contents of the `rest` args to the original `call_digraph_listeners` call or
equivalent.  Further sub-processing of payload args should be considered
derived properties stored in e.g other ivars.

2) it then follows that useful higher level operations
on the payload (like "message") will be derived properties that will
live e.g in instance methods, and we will have to accomodate that when
the event is effectively changing classes.
