# a sixth mock system? :[#030]

## justification

the five other solutions (past and present) introduced at [#028]
leave something to be desired when we are testing an operation that
effects not only several different system commands, but several
different *kinds* of commands, some of which we may want to #pass-thru,
while others we want to mock.

specifically, this list constitutes the design factors that led to
decision to develop this (sixth) solution rather than trying to shoehorn
one or more of the others to fit our needs:

  - allow the DSL (or equivalent) to be expressive enough to define
    several different *kinds* of commands to match, and broad (or narrow)
    definitions of behavior as desired.

  - don't use an external file format (OGDL, YAML, JSON..) as a store;
    it's too much software; too tall a stack; too much API; too indirect;
    and too much isolation from the runtime.

  - but (on the other extreme) make sure your fixture definitions are
    short, readable, and logic-less; rather than custom procs that need
    to do a lot of calculation to match a request to a mocked response.

  - so use a DSL that is the "right" balance of being readable without
    employing leaky abstractions.

  - scale to many commands *for many programs* without 0N lookup time.

  - employ "diminishing pool" where desired, and not where not.




## broad objective & scope

our exact intent is to allow the mocking of calls to the `popen3` method
of `::Open3` of the `open3` standard library of the platform. familiarity
with this method will be useful to make sense of the subject.

a "mock system" (for our purposes) receives requests thru an `popen3`
method and produces a canned, "mock" response in the form of a four-
element tuple: STDIN, STDOUT, STDERR and a "wait" object (which for our
purposes is a simple 2-layer wrapping around exitstatus integer).

currently we do not mess with mocking any behavior against writes to a
STDIN stream so we always result in a dummy value for this component,
effectively leaving us with the mocking of the other three components
as our objective here. :[#here.B]

as a rule we never use and so never detect the form of call to `open3`
that passes a block; to support such a form would be trivial but if we
avoid this entirely, it cuts down on our workload here without any other
real cost.




## more specific scope ("limitations")

although by design we have called the subject a "mock" and not a "stub"
(see fowler [#sl-159]), we don't effect all the behavior that one might
expect from a mock: our mocks typically use the "diminishing pool" pattern
to assert set membership of the request against what is expected, so

  - if a request is made that isn't mocked for, it will fail expressively
    in what is probably the expected manner
BUT
  - if at the end of the test there remain requests in the "pool" that
    weren't accessed, this will NOT lead to an assertion failure. :[#here.C]

also, the order of the requests is not asserted (although if the mocked
cases are defined in the order they are called, lookup time will be
reduced).

mainly, the subject exists to divorce the system under test from reliance
on any arbitrary subset of those external systems the SUT normally depends
on; however its main goal is *not* to assert over the interactions there;
but merely to mock them as needed.




## usage (theory)

### define a category

the system commands you are mocking will fall into "categories" you
define. typically you create one category per system utility/program
you use, but this is up to you. a category is defined only by a proc:
IFF the argument array sent to `popen3` "matches" that proc (i.e if the
proc results in true-ish against the array), then this is the category
that will be used to further process the command.

when there is no category found to match a request, an expressive
failure is raised.

there are (at present) two kinds of categories that can be defined,
"diminishing pool" categories and "times" categories.




## a "diminishing pool" (key-value) category

a "diminishing pool" is effectively a hash that gets smaller over time,
typically because when an element of that hash is accessed, it is also
removed. when we use this pattern in testing it is often because it
enables us to assert that no element of the hash is ever accessed more
than once.

(furthermore, at the end of some given process we can assert that the
pool is fully "dried up" (that no elements are left) but we do not do
that here, as discussed at [#here.C].)

so this type of category allows us to define a diminishing pool of
"cases" (responses), each of which is stored under a "key"..



### define a keyifier

for this type of category you must define a command "keyifier", which
is a proc that when given the command (string array) produces a "key"
(any value) that uniquely and consistently identifies any received
command that you will receive for this mocked system within the scope
of this category.

typically the keyifier is defined to result in a particular positional
argument within the command (like a filename or other similarly varying,
uniquely distinguishing argument), but you may need to provide another
keying strategy as necessary for your use case.



### define the cases

then the remainder of this type of category is a series of `on` elements.
each `on` element is defined by the key for each command you expect to
receive, and a "body" proc that produces a tuple (array) containing the
defining datapoints that make up your mocked response: an exitstatus
(integer), any stdout (string) and any stderr (string). (we could
expand this to allow streams instead of strings if such an arrangement
is ever appropriate for the size of the mocked payloads.) so:

    [ exitstatus [ stdout [ stderr ] ]

if you want stderr but no stdout, pass `nil` for the former.
