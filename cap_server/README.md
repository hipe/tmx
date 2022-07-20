# Welcome to "Cap Server"

This is an experiment: an "internal" web app written as tooling.

This started as a little sub-project in [kiss-rdb]. From this we abstracted
[app-flow], at which point we thought it made sense to get this tooling out
of the relatively lower-level [kiss-rdb], and promote it up to its own
top-level sub-project, because of its reliance on a now higher-level module
(the new [app-flow]). (Lower-level sub-projects should not rely on higher-level
sub-projects.)

The objective is two-fold: prototype this idea of a "capability tree" as a sort
of "punch-list" for development of (perhaps) almost any given technology;
and two, [see the objective and scope of [app-flow]].


# (document-meta)

- #born
