# the API node narrative

broadly this is an experimental reconception of the [fa] API API, one that
takes what we learned from there and tries to pare it down to have fewer
moving parts. however this one was only distilled out of one small-sized
application (f2tt) and so is not yet poised to replace [fa] whole hog.



## :#storypoint-10

the idea of a "service" here is that it coincides with a long-running process.
if your system is running as a daemon, a persistent service object might exist
for the lifetime of the daemon. this effectively makes it a singleton, and
[#sl-133] singletons are generally problematic to work with, so it is
recommended that you keep the domain of responsibility very (very) light
and where possible stateless.

we work the structure of this service singleton into our API pipeline just
to accomodate any future needs we have for this kind of long-running facility,
problematic as it may be.

the uptake of it is, all API requests will first come in through the service
singleton which will dispatch them accordingly. currently the way it achieves
this is via creating a "session" object and letting it take things from there.



## :#storypoint-15

the "session" (we almost called it something like "request" or "fulfillment"
or "request resolution") is where the work begins of fulfilling this
particular request. its job is to resolve an unbound action (think class),
then build a bound action (think object) having passed it any parameters in
the #storypoint-30 iambic array.



## :#storypoint-20

by default and for now, when you employ this bundle it creates both an
'Actions' module for finding unbound actions, and an 'Action' sub-class
that will presumably be used by you to model your actions.



## :#storypoint-25

if this module has a parent and that parent has a dirname, base your own
off of that, otherwise base it off of where the enhancement came from.



## :#storypoint-30

for reasons of simplicity, we use [#sl-134] "iambic" arrays as the request
structure throughout this facility.
