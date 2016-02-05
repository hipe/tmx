# parameters normalization :[#028]

this is a central "basin" for a family of distinct operations with
similar sub-operations (and is part of the super-family of #[#br-087]
normalization algorithms).

shared sub-operations include:
  • checking for missing requireds
  • defaulting

at present this does no "soft" failures but this may change. :#A

we prepare "actual" arguments

  • into a variety of target-specific shapes
  • from a variety of input sources


the possible target shapes:

  1) produce an "actual parameters" list (array) for a plain-old
     "platform" proc or method.

  2) write values "into" a session-like object using (what look
     like) `attr_writer`s.

the possible input sources:

  1) an argument stream, off of which we will parse "passively"
     (stopping error-lessly at any first unrecotnized token)

  2) a "parameters value reader" that allows random-access to
     "epistemic" meta-data about whether which values are known
     and if so what the value is.




## :"head parse"

as long as the current head of the argument stream corresponds to
the name of a formal parameter, shift that name and (assumed here
to be present on the stream) value element off the stream and
replace the value in the sparse hash with this value. (i.e continue
until no more stream or the head of the stream is not recognized.)

having only one formal argument is a special case: in this
arrangement we NEVER recognize named arguments, i.e the term
in the argument stream MUST be not named (i.e "positional").




## "why we skip certain acceptances"

when we say "random access" below we mean: the operation is
implemented as a class. for each would-be invocation of the
operation we start with an instance of that class. each prepared
value that we produce here is sent one-by-one (non-atomicly, mind
you) to that instance through its corresponding plain-old
(ostensibly) `attr_writer` method. (this is exactly [#fi-007]
"session" pattern.) if we get to the end cleanly we can `execute`.

with operations implemented in this way it is typical to
initialize all non-required parameters in the `initialize`
method. in its way this is the simplest implementation of
"defaulting".

now, we might or might not be in "random access" mode here. (we
might just be building an arglist for a proc.) but if we are,
we want to send the prepared value IFF it was provided or there
was a default and the default was exercised (to any value). we
must skip the acceptance of this nil value otherwise, lest we
overwrite the kinds of defaults described above. whew!
_
