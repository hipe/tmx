[#020] #open omni "did you mean.."
             precursor to: [#019] & [#018]
             the "did you mean.." expression should reflect the availble
             operations across the whole omni operator branch.


[#019] #wish omni fuzzy resolution
             new tests to cover this
             (related: [#018] the omni help system (design these together).)
             tmx CLI fuzzy resolution for the first token must not happen
             at the level of a single operator branch (for #here these
             three categories). rather, the fuzzy search must happen across
             all N sources in series, for it to work correctly.


[#018] #wish omni help screen/system
             new tests to cover this:
             (related: [#019] the omni fuzzy search (design these together).)
             the tmx help system for its top level must reflect operators
             available from all sources: first the "intrisic" operations
             (test-all, reports, map), then the "mounted sidesystem"
             operators (etc many), then the "mounted one-off executables"
             that exist in [tmx] (in its `bin/` directory). a major implementation
             decision is whether to build the "omni branch" early for all
             invocations or whether to build it lazily, only for "did you mean.."
             a major design decision is whether to express the omni splay
             outright or whether..


[#017] #wish here's guys that don't have "mounting" in tmx that might want it -
             [sa], [dt], [my], [gv]


[#016]       #track - not covered feature of [ze] a.s
             ( #was: unbreak [tmx]'s heart - use new API somehow to bring
               old tmx back
                - integration of sidesystems with TMX should happen in the sides, not TMX )

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


[#011] #wish (precursor to: [#ts-002] coverage)
             update your life to the latest stable rspec


[#010] #wish write a task to update semi-real costs (a bash script loop).
             #depends-on: [#011] update your life to the latest rspec.
             consume rpsec json-formatted output from the test run one
             per node and use its elapses seconds. you cannot (should not?)
             do this in multi-node "process-plans" because of "choking"


[#009] #wish approach a design for a randomize feature (at both the macro
             level (among nodes) and in progressively more mirco levels
             (perhaps files within a node, perhaps examples within a file).
             imagine integration with the costs caculation strategy of [#010]
             so that a fleet of process-plans could be designed that runs
             efficiently but is still randomized.


[#008] #wish smarter descriptions for added primaries - can we reach the s.s?

[#007]       [ track legacy thing: help screens testing thing ]

[#006] #open feature-injected features are not reflected in help screens

             (acceptance: the '-order' switch should appear in the
             test-directory-oriented remote operations)

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
