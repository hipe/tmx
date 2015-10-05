# understanding the queue - the queue narrative :[#049]

## the original catalyst

the core objective of the queue is to faciliate "atomic"-like, multi-pass,
semi-transactional processing of a request: we want to be able to articulate
a strong distinction between a "parse" phase and an "execution" phase of the
request.

for small command-line apps this distinction is not usually important, but
this library supports more than small command-line apps.

for an example of how an app might suffer from a poor distnction between
these phases, consider the ruby stdlib optparse library's implementation of
`help`: - it writes output and then issues a system exit **as it's parsing
the input arguments**. it probably does this because it is literally the easy
way out, and it is par for the course for simple command line untilites, that call
a system exit whenever they please because they think they are done.

for us this behavior is a showstopper. for one it makes testing near
impossible; for two, it sets a bad example for others; and for three, it
makes it difficult or impossible to integrate such applications into
larger systems.

more genereally it is a requirement that this library never call `exit`
anywhere. whether or not that operation is arguably appropriate for any
library to do generally, it is deemed as squarely outside of the domain of
responsibility for this one for any reason.

also for many many other reasons, if you're doing any heavy lifing from
within an option callback, you're probably gonna have a bad time.

by gathering all the request data together in one pass, and then acting
on it in another pass, we give ourselves the flexibility to decide
intelligently how to reconcile the means by which multiple task may be
execued in series (for example by short-circuiting, or by effectively
re-ordering the tasks before they are performed to manage their
inter-depenant side-effects).
