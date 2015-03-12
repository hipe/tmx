# the mock sys narrative :[#007]

## introduction

"mock-sys" is a mechanism for writing the results of arbitrary system
calls to disk and then later "playing them back" as if they were the results
of those calls, in lieu of actually making those calls again. it intended
for use in nothing more and nothing less then automated testing, exactly in
the way tha "web-mock" is used to mock the web in such contexts.

its main objectives are simplicity and readability (appologies to OGDL).

(hypothetically "mock-sys" could provide additional value by checking
system compatibility under various software upgrades or arbitrary other
systems; by comparig the real resuls of system calls against the stored,
expected results; effectively providing "external regression testing"
against the outside world. although "mock-sys" was designed from the
ground up to be amenable to such a purpose, it is currently beyond our
scope and immediate interests.)




## immediate history

"mock-sys" is a ground-up rewrite of "mock system" without
the #issues-that-mock-system-has, and with
a #justification-for-why-we-didnt-just-improve-the-existing-library.
given this, we thinking about #what-we-plan-to-do-with-mock-system.




### #issues-that-mock-system-has

what happened was, we approached "mock-system" intending to use it for
new developement. we were floored and aghast at how byzantine it was: to
create new system call fixtures we had to build rbx *and* install zmq.

we vaguely remember why we built it that way those couple of years back,
and we are still glad we did for the experience; however these
requirements are a showstopper now:

the fact that the runtime of "mock-system" was not the runtime of tmx
meant that it had gone stale and was broken against current tmx.

so, for these reasons, we thought a rewrite was in order. in summary
(and to add a few others):

  • we shouldn't need to install an industrial-strength messaging
    library just to build system call fixtures.

  • rbx was a fun experiment but it is impractical for day-to-day
    development to be straddling two rubies.

  • because of the above the test suite didn't follow the
    "hold-your-breath-rule" (to be defined at [#ts-004]), and hence
    its tests all went stale.

  • the ornate bash build system was a fun experience, but suffers
    from being frameworky, and so is generally hard to read and
    brittle, in effort to be supremely modular and re-usable.

  • when it was developed, it was not #three-laws-compliant.




### :#justification-for-why-we-didnt-just-improve-the-existing-library

it is large enough (huge) and old enough that to try and re-work the
existing code base would incur more cost than it would have value. our
improvement on it is effectively a partial platform change. given that
our current objectives are to make it minimally small, we didn't want to
carry any cruft from the old way. its value is that it exists, not that
it is used.




### :#what-we-plan-to-do-with-mock-system

can we put it in a museum? the rainbow kicking, the plugin architure,
it's all kind cool. but actually this is an open issue, is what to do
with all the old code.
