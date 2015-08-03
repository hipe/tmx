## exit statuses :[#023]

This stands at the intersection of [#019] (the common triad) and
[#023] (exit statii): As a throwback to our humble roots, we want to
accomdate for participating functions that result in an integer that is
to be used as an exit status for the whole process to the operating
system. We also want to accomodate the different but overlapping
sets of results that come from methods participating in
"the common triad", which is an associaton of particular meanings to
results variously of `nil`, `false`, and "other" [#019].

Now imagine a venn diagram between the two: To strike a compromise between
these two without resorting to too much shenanigans, participating
functions folow suit  by following an aggregate convention whereby
a result of `true` means "normal/ok" and a result of "not equal to true"
means "an exceptional early stop, and please use this as a result."

If the method wants to result in an exit code of [#023], then instead
of an exit code for "ok" being e.g. the conventional 0, it uses `true`.

Other methods that play by #019 (more common in this library) but still
want to play nice here will result in either `nil`, `false`, or `true`.

This way, we can determine if there is an exceptional early stop by
simply checking for `true` of results.  If it is not true, we stop
early and simply propagate that result.

Because this is so ugly it is not that widespred, but this had to be
built into the library somewhere so it could accomodate clients that
want to use exit codes all over the place if that's their thing.
_
