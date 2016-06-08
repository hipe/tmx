# the event predicate narrative :[#021]

## introduction :#storypoint-005

this is a 'courtesy' class used by other libraries, not this one.

Emigrated from porcelain, this is the test-framework-agnostic core (or "nub")
for e.g an ::Rspec custom matcher. A few lines of wiring would be necessary to
adapt it to e.g ::RSpec to make it a custom matcher there, hence it is just a
"nub" and not a full-out custom matcher (which is done intentionally so as to
not couple our core (and perhaps overwrought) logic too tightly to one
external testing f.w).

This 'Nub' is a "type DSL" - it is based around the premise that the same
things we *always* test about a list of events can be expressed most tersely
and readably by using a list of values each of which has a class among
::Fixnum, ::NilClass, ::String, ::Symbol, ::Regexp (yes, we throw the duck
out the window).

(this whole idea is probably riffing off of the syntax for rspec's
`raise_error` matcher, which takes a number of different kinds of arguments,
asserting different kinds of expectations.)

For example if a certain event should have a text representation equal to a
certain string, ::String is used for that. If its text representation should
match a certain regexp, that is the use ::Regexp serves. (::Symbol represents
the expected stream name of an event. ::Fixnum indicates the offset of the
event we are talking about. ::NilClass is used to indicate that this event we
are referring to, we expect it to be the last event in the list of events).

In theory the core lifecycle of one such nub should consist of:

  1. construct a nub object with 1 argument: an array of primitive types
  where each element is one of the 5 classes above.

  2. call `match` on the nub object, passing that an array of actual
  Common event-looking objects. It will result in trueish or falseish,
  based on whether the expected did or did not match the actual,
  respectively. (Note the two arrays, expected vs. actual, are *not*
  parallel in any way. It is just coincidence that they are both
  arrays.)

  [3.] IFF the above was false you can call `failure_message_for_should`
  and it will give you a lingual-ly clever string explaining the failure.

  [4] You should be able to call `descrption` any time after `match`
  and it will describe the whole criteria, again being linguistically
  clever.



## :#storypoint-055 for wiring it to an ::Rspec custom matcher

these are expected to be called in the order MATCH [FAIL_MSG] DESC;
`handle_match`, `handle_failure_message_for_should`, `handle_description`



## :#storypoint-500

NOTE - experimental syntax

what does nil mean? the mnemonic is "i expect a nil value from the actual
event array at the last explicitly stated index (expressed with a ::Fixnum).
It is _the_ way to assert the expected exact number of events in the actual
list. Using `nil` without an explicitly stated index before it is undefined.

So, an expectation array of [0, nil] says "the value of the event array at
index 0 should be nil (hence the array should be empty. there should be no
events). Since the index that is implied is the last valid index of the queue
(i.e length - 1), an arguably poor way to state something might be:
[ :foo, 1, nil ], which effectively states "the last event should be of
`stream_symbol` :foo, and oh by the way, since at index 1 we expect `nil`, it
means that there should only be one event in the queue."  #experimental

(what would of course be nice is that an expectation array of [nil]
represent the expectation for a zero-length actual array.)
