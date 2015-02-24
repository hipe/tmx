# coverage is a no-fun zone

we cannot determine coverage for any file that is loaded by the ruby runtime
before the coverage agent is started. as long as we use the test runner to
determine (some kind of) coverage for the libraries on top of which the test
runner itself depends (which itself seems super fishy, except that the test
runner is like the quintessence of a perfect use-case for plugins, and the
plugin API hellof needs good test coverage); we therefor write lots of
coverage-related things bare with no dependencies, even though we would
otherwise want certain things. (although note we still do weird things in
order to have modules in their canonical places.)


## #at-this-exact-point

in order to report coverage on the widest possible amount of code
(including the code in this file) *yet* to implement this coverage
facility as a plugin; exactly two files have finished loading once we
get to this point here -> "." (and these two files were loaded
"manually"). a third file is in the process of being loaded: this
one. now that any coverage plugin is running, to get our sidesystem
([ts]) and sub-system (the tree runner) wired for autoloading in the
usual way, we have to do it in an unusual way: more manual loading:
