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
