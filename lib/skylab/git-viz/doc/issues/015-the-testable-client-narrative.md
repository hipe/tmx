# the testable client narrative :[#015]


## :#storypoint-5 introduction - meet superchargers

we are forever hunting for that elusive perfect balance of testing
infrastructure: too much and we are only testing our test system and not our
system under test. too little and we grow software of low value, software that
misses out on all the value from being grown with tests. (OK that may be a bit
of a tautology, but it's only peripheral to our point..)

this "testable client" bundle-ish, we are calling it a "supercharger". it is
a supercharger because not only can it have module method and instance method
interests, but also its had DSL-ish methods that it wants to give the test
node itself. call it a "classbuilder".

this "payload behavior" is the entire reason for existence of a supercharger:
it is designed to b the simplest soultion that accomplishes these two critera:

  • we want to be able to define arbitrary classes that can be shared
    anywhere from that test node downwards to child nodes.

  • we want these classes that we define not to load at file-load time,
    but at test-time.

that second point might be a bit of a false requirement, but this house was
build on false requirements. the reasoning behind it is this: we want the
loading of the class under test itself to be the subject of a test. we don't
want our whole test suite to halt when it fails to load.



## why "testable client" specifically?

in the criteria above, perhaps some red flags were raised to you: why are
we creating arbitrary new classes in our test nodes? the answer lies behind
the purpose we created the "testable client" supercharger in the first place:

these "testable client" classes here are meant to be **small** (maybe 10 lines
or so) subclasses of components in our system under test. specifically they
are meant to test components (either business components or the in-stream
library components that serve them) that by design have no public interface of
their own, because they are designed to be given a public interface by their
sub-classes.

a "testable client", then, is one such sub-class that you make specifically
to test its parent class. there's probably a name for this phenomenon
somewhere..



## implementation storypoints

## :#storypoint-20

this little memoizer accomplishes this: the class definition proc must only be
run once, and must be run with the context it was created in (you invite a
huge number of problems to do otherwise).
