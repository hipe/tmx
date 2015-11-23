# nasty OCD memoize caveat :[#042]

## synopsis:

"dangerous memoize" refers to the act of memoizing a structure
in *one* test context that you use in *another*. it is VERY dangerous if
you don't know what you're doing!

the advantage is that you can use the familiar stack of "fully wired"
API methods that you use in your normal tests to build a possibly complex
stucture (with a possibly expensive build-time) that you can run many small
tests against.

the disadvantage is only if you don't know what you're doing: do NOT
accidentally pull in spies from the one test context where the
structureu under test is built.

the author feels this bit of nastiness is justified if used with caution
because it encourages many small tests without indirectly discouraging
testing a high-level result structure that is possibly complex.




## caveat re-stated:

realize the EXTREME danger in this: the first time the produced method
is called, it produces its result by running the argument proc against
whatever the test context happens to be at that time. each subsequent
time the produced method is called it **re-delivers that same object
even though the test context may have changed**. so do NOT use this
to memoize anything that emits events, for example; or otherwise has
side-effects on the test context when it is "used", because the effected
test context will be stale and inaccesible during those subsequent calls;
perhaps leading to test incorrectly succeeding or silently failing.




## justification re-stated:

the OCD of this is that we don't want to "waste" the effort of lots of
convoluted setup multiple times just so we can make make many small tests
on one object.

the "right way" to do something like this might be to lean off of the
test context itself for produing the object, and lean on other
facilities outside of the test context; but this is not always practical
given the extensiveness (and usefulness) of our current pattern for test
"bundles", which becomes its own issue..
