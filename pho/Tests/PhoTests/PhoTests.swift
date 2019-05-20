/*
The documentation fragement called "The bootstrapping problem" explains why
at #birth we are not committing any actual unit tests yet.

In effect, we took the generated unit test file and ovewrote it with these
comments.

.#open :[#882.A] is this.

In lieu of writing any actual tests YET, we will dog-ear with a dedicated
comment (and a pseudo-DSL lol) each test-case we think we need to accompany
the "asset code" we add as we add it (an imaginary TDD rule-of-three if
you will).

Reminder: there is a lot besides just this file that needs to be rectified
to have proper unit tests begun, including at least one other swift file and
and a `.testTarget` named in `Package.swift` named "PhoTests" etc.

When the time comes, run the swift command (as documented by us in this
project) again and cherry-pick these above pieces you need.
*/


/* TEST CASE: if it's not too expensive, show that there exists a library
(imagine it's in C-code) that you can call with its own `main`-like CLI
to call some trivial minimal function and get its trivial minimal response.
(ideally it takes an argument and produces a result that shows that the
argument was seen. bonus points if it's a string.)
*/


/* TEST CASE: show that the above cited minimal function written in C-code
can be called from our swift.
*/


/*
#birth
*/
