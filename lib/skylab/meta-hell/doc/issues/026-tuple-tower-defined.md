# tuple tower defined

in the same manner that we explore the isomorphicism between switch statements
and e.g hashes, we here are amusing ourselves with something ..

imagine a list of functions (a "tower"): the first (topmost) function in the
tower is "seeded" with some value, that is, we call it. its result will then
feed into the next function, which gets called with those tuple of results
as its argument. and so on. the number of elements of the tuple may change
as necessary from function to function. the catch is, always the first element
in each result tuple will only be used as a boolean flag to indicate whether
or not to short-circuit the tower. in such an even of a short circuit, only
the second element of the tuple is used as the final result of the whole
function.

this allows you to write a dependant chain of functions in this manner without
having to name them, which may have some benefits, of possibly cramming
lots of readable logic into a small space..

it might also be stupid
~
