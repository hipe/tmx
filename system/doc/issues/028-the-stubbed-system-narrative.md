# the stubbed system narrative :[#028]

## purpose & scope

in one sentence, this facility is a means for "stubbing" the results of
calls to `popen3` on a "system conduit" that is produced by this
facility. the reason this is useful to us is that (by design) *all*
system calls happen through this method, and if we can "stub" calls to
it, then we can "stub" the system. stubbing the system, in turn, is
useful to us for a couple of reasons:

1) in unit tests it's generally accepted as good practice to stub
interactions with outside system to a) reduce coupling to outside
systems and b) to improve latency. i.e, unit tests should be able to run
as a standalone "unit".

2) with a featureful enough library we can do something we call "two-way
assertion", something we won't cover here (for now), but is suggested by
old body copy below.




## expanse

at writing there are or were *five* (5) mechanisms for creating a
stubbed system.

  1) the first (byzantine) stubbed system of [gv]. very deprecated,
     if not sunsetted completely.

  2) "readable-writable". ironically or not, a simplificaton of the
     above but is now seen as too complicated and might deprecate too.

  3) "inline static" based, which is so short and simple you can almost
     understand its inteface by reading its code.

  4) "inline pool" based, which is like above but diminishes and has
     function-based resolution.

  5) "snippet" based, which stores its "snapshots" in files but uses
     a platform format rather than OGDL..




## current state

in asset code and in tests the taxonomy has not been fully rearranged to
reflect the delineation of the 4 different facilities offered here.




## readable-writable

"stubbed-system" is a mechanism for writing the results of arbitrary system
calls to disk and then later "playing them back" as if they were the results
of those calls, in lieu of actually making those calls again. it intended
for use in nothing more and nothing less then automated testing, exactly in
the way tha "web-mock" is used to stubbed the web in such contexts.

its main objectives are simplicity and readability (appologies to OGDL).

(hypothetically "stubbed-system" could provide additional value by checking
system compatibility under various software upgrades or arbitrary other
systems; by comparig the real resuls of system calls against the stored,
expected results; effectively providing "external regression testing"
against the outside world. although "stubbed-system" was designed from the
ground up to be amenable to such a purpose, it is currently beyond our
scope and immediate interests.)




## immediate history

"stubbed-system" is a ground-up rewrite of [#gv-023]
"stubbed system" without the #issues-that-mock-system-had, and with
a #justification-for-why-we-didnt-just-improve-the-existing-library.
given this, we thinking about #what-we-plan-to-do-with-stubbed-system.




### #issues-that-mock-system-has

what happened was, we approached "mock-system" intending to use it for
new developement. we were floored and aghast at how byzantine it was: to
create new system call fixtures we had to build rbx *and* install zmq.

for a sense of the byzantine scope of this stack, you may want to skim:

  • [#gv-017] the fixture building narrative
  • [#gv-018] the system call fixtures narrative
  • [#gv-021] wtf is a rainbow kick (this is still cool)
  • [#gv-022] the shutodown timer narrative
  • [#gv-023] the stubbed system narrative
  • [#gv-024] the manifest client narrative
  • [#gv-027] the freetags feature
  • [#gv-028] the partbuilding scripts narrative

what it amounted to was an exercize in overdoing the architecture for
what we told ourselves at the time was a "good" reason, but really we
were just looking for an excuse to play with concurrency and server
architectures.

that's all fine and good for the massively false requirements it had
created for itself, but today we just want a stubbed system. this now
legacy system is a showstopper for our requirements today:

the fact that the runtime of "stubbed-system" was not the runtime of tmx
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




### :#what-we-plan-to-do-with-stubbed-system

can we put it in a museum? the rainbow kicking, the plugin architure,
it's all kind of cool. but actually this is an open issue, is what to do
with all the old code.
