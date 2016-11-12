[#016] #open unbreak [tmx]'s heart - use new API somehow to bring old tmx back
               - integration of sidesystems with TMX should happen in the sides, not TMX


[#015] #wish unify other tmx node-centric services (that big dependency graph)


[#014] #wish investigate and possibly design and possibly implement either
             an adapter to go beside or a rewrite of the globbing facility
             that now uses system `find` to find test files. benchmark the
             two and use the faster one or the more available one or whatever.
             this should stay close to [#013] the drying issue.


[#013] #wish investigate and possibly design and possibly integrate
             a DRYING of everthing here so far with the quickie recursive
             runner. (if nothing else they should be globbing files in the
             same way).


[#012] #wish the cost-driven divvy algorithm (greenlist supreme)..


[#011] #wish update your life to the latest stable rspec


[#010] #wish write a task to update semi-real costs (a bash script loop).
             #depends-on: [#011] update your life to the latest rspec.
             consume rpsec json-formatted output from the test run one
             per node and use its elapses seconds. you cannot (should not?)
             do this in multi-node "process-plans" because of "choking"


[#009] #wish approach a design for a randomize feature (at both the macro
             level (among nodes) and in progressively more mirco levels
             (perhaps files within a node, perhaps examples within a file).
             imagine integration with the costs caculation strategy of [#XXX]
             so that a fleet of process-plans could be designed that runs
             efficiently but is still randomized.


[#008] #wish smarter descriptions for added primaries - can we reach the s.s?

[#007]       [ track legacy thing: help screens testing thing ]

[#006] #open feature-injected features are not reflected in help screens
             [ the glue that glues together the centralest things ]
[#005]       [ the punchlist report ]  (much documentation/theory in-situ)
[#004]       syntax for the "map" operation
[#003]       the help screen narrative ..
[#002]       what is the front model? ..
[#001]       "the problem with tmx" is where it hard-codes assumptions about
             a full or particular constituency of non-essential sidesystems..
             this applies to files in [tmx] and out, including data files/
             development guidance files (like the punchlist, like the
             greenlist), test code files (like the two in [tmx] that tests
             universe-wide integration), and any asset code files (none
             come to mind at the time).
