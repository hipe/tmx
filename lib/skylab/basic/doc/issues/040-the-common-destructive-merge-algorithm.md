# the common destructive merge algorithm :[#040]

## introduction

this is an attempt to distill into natural language a pattern that we
have implemented (in various variants) numerous times, in hopes that one
day it might become something like an enhancement module or actor that
presents an API for making this easier that writing our own merge logic
imperatively "by hand" each time.




## prerequisites

this algorithm requires that both the subject object ("mutatee") and
argument ("destructee", defined below) respond to messages with names,
arguments, behavior and results that are in accordance with these [#041]
universal abstract operations:

  • "fetch"
  • "add"
  • "remove"
  • "to polymorphic key stream" [yet to be formally defined]

i.e the above are "#hook-out's" with particular expected signatures
and semantics.




## algorithm

we refer to the subject object as a "container" because the constituent
UAO's are practically the pre-requisites for one; but see "scope" below.

it is recommended that the implementation of this opertion be a method
named `merge_destructively`. we refer to the receiver of the message
as the "mutatee", and the lone argument to this method as the "destructee".

this operation will render the destructee useless. to send the
destructee any messages after this operation would have behavior that is
undefined and liable to be fatally meaningless. (although perhaps well
implemented containers will actually be alright through all of this.)

we do not constrain here that the mutatee and destructee be of the
same class or general shape; but such an arrangement likely corresponds
to the intended use case of this operation, so to do otherwise will
probably lead to behavior that is interesting at best.

so: the destructee will present the keys of the items in its consituency
via a call to is "to polymorphic key stream" method.

  • with each key in this stream:

    • remove the item from the destructee with an appropriate
      call to its "remove" method. memoize the result of this call
      (which we may call "the item").

    • as may be appropriate either universally or per subject, we may
      want to treat nil item values as being equivalent to the
      association not existing. in such cases, maybe redo.

    • sending "fetch" to the mutatee, determine whether or not the
      mutatee has one such item of its own under this key.

      • if the mutatee does not have such an item, send the "add" to
        the mutatee with the current key and item as arguments.

      • otherwise (and the mutatee does have such an item):

        • if the mutatee's item responds to `merge_destructively`,
          send the destructee's item into this method. (note this is a
          recurse.)

        • otherwise ..??.. profit



## scope

although we refer to he subject object as a "container", the potential
application for this algorithm is considerably broad consdering that all
that is needed is for the subject and arguments to accord to the
requisite UAO's. given this, adapters could be writen for a far-ranging
dispersion of sorts of objects, perhaps even all of them.
