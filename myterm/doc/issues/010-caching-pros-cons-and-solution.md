# caching pros, cons & solution

### the OCD

the thing with wanting to cache things is that we can't stand to have to
hit the filesystem and parse the list of available adapters for every
single time we make a reactive model call: across three modalities
with dozens of distinct calls in each modality, it may mean 100-ish
filesystem hits that have the exact same input and produce the exact
same output, from which we then "painstakingly" build the exact same
index over and over.

regardless of how many microseconds we save by caching this work at this
moment, on principle we want the peace of mind of knowing that we can
address this issue and more generally issues like it that could become
scale hurdles. this kind of solution is now available whenever we have
an external system that is relied upon that is "reliable" and
"relatively absolutely static" like the filesystem is in this case.




### but the OCD gets in the way

HOWEVER we must not cache the above work "forever" in a "forever cache"
(singleton) for a couple of reasons:

  • in a real life long-running (iCLI) session, it "feels" more right to
    get into the habit of *not* caching reads from the filesystem, so
    that live changes to the filesystem *during* the interaction session
    are reflected.

  • the general rubric certainly holds in this particular case:
    singletons are bad. [..]

SO we dootily and footily



## solution

because of OCD we will cache the dootilies on testing *only* for now..
