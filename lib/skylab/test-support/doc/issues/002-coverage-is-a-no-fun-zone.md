# coverage is a no-fun zone :[#002]


## the main point

coverage is not and cannot be a "clean plugin" - it needs its owns special
handling because of a distinct characteristic that only coverage has:

we cannot determine coverage for any file that is loaded by the ruby runtime
before the coverage agent is started. as long as we use the test runner to
determine (some kind of) coverage for the libraries on top of which the test
runner itself depends (which itself seems super fishy, except that the test
runner is like the quintessence of a perfect use-case for plugins, and the
plugin API hellof needs good test coverage);

as long as that is the case, we write our coverage-related mechanics with
no dependencies at all except ruby.

despite this, for aesthetics, comprehensiveness, and perhaps
future-proofing we still make the coverage mechaincs "look like" a true
plugin as much as we can, in terms of where its files lives. the cost of
this is a couple lines of explicit file requiring.




## #at-this-exact-point

in order to report coverage on the widest possible amount of code
(including the code in this file) *yet* to implement this coverage
facility as a plugin; exactly two files have finished loading once we
get to this point here -> "." (and these two files were loaded
"manually"). a third file is in the process of being loaded: this
one. now that any coverage plugin is running, to get our sidesystem
([ts]) and sub-system (the tree runner) wired for autoloading in the
usual way, we have to do it in an unusual way: more manual loading:
