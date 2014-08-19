# the node controller narrative :[#045]

## :#narration-60

a "close" operation is a macro operation: it is a higher-level operation
built up of lower level operations. specifically we define "closing" as
possibly removing any '#open' tag and possibly adding any '#done' tag.

whether or not something is a failure depends on the definition of success..

we build a new listener where the error and the info handlers are both
references to the incoming info handler. we explain why below.

if either of those operations was unable to complete because of error,
we will also report that we are unable. (but note we do not short-circuit
the processing of the second thing just because the first thing failed.)
(note also this state is unlikely ever to happen because we are using
info handlers instead of error handlers for the error conditions.)

our resulting in error is intended to prevent the file from being
rewritten in such cases.

if either of the operations was not able to complete becuase (in the
first operation) the tag to be removed was not found, or (in the second
operation) the tag to be added was already there; then we do not want
the UI to describe this an an error, because just because one didn't
work doesn't mean the other one will fail too. this is why we change the
handlers to be both the info handler and not the error handler, to
change how such an event will be described.

otherwise, since both opoerations resulted in something other than
false, they each one of them resulted in either `nil` or true-ish.

in the case that both resulted in `nil` ("neutral"), then both
operations were redundant hence that there is nothing to do. (strictly
speaking, it wouldn't be crazy to report this as an error but we don't
bother.) in such cases we do not want to rewrite the file so in these
cases we propagate the `nil`.

otherwise, if either one of the operations was true-ish it is an
indication that the item was mutated in some way per (at least one of)
the tagging operations we were attempting. we propagate that result
outward, which is intended to trigger a file rewrite.
