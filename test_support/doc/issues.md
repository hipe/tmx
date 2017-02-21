[#048]       described in [#001], this tracks "sandbox" module implementations

[#047] #open subscribers to quickie ever supporting a negate operator
             ("should not")

[#046] #hole ( #moved-to: [#dt-xxx] )

[#045]       permute (as a doctest action)
[#044]       lexical scope vs inheritence (as it pertains to us)..

[#043] #hole ( #moved-to: [#dt-xxx] )

[#042]       "dangerous memoize" (was "nasty OCD memoize") caveat ..
[#041]       static file server ..
             (#was: sidesystem class now in [tmx] & [sli])
[#040]       is find nearest TS file broken?

[#039] #hole (#was: lend/borrow coverage, moved to [#008])
             ( #moved-to: [#dt-xxx] )

[#038]       expect line

[#037]       fixtures

             [#here.1] (not referenced) [#sy-008.1] expects the two files in
               this tree to have identical content: fixture-trees/one
               [st] expects that same tree to have only those files.

             ( #moved-to: [#dt-XXX] )

[#036] #hole
             ( #was: indentation in quickie )

[#035]       #track `def test_support` (for `\.test_support`) occurrences,
             which *must* all follow this:
             we must use `require_relative` (and not `require` or `load`)
             here, otherwise if our native tests are run after this method
             is called, ruby will load the file redundantly which under
             some autoloaderifications will bork apparently flickeresquely

[#034] #open what is the r.s equivalent to this? [ canon ]
             ( #moved-to: [#dt-XXX] )

[#033] #hole ( #was: #historical #done fix test globbing .. [#xx-009] )
             ( #was: #done if you un-orphanize core.rb it presents an issue with autoloader) )
[#032]       ( assorted plugin issues )
             ( #was: :[#here.A]: the "counts" report is not covered )
             ( #was: :[#here.B]: verbose mode is borked for counts )
             ( #was: white plugin whines weirdly when strange files are in
               lib/skylab ([#xx-007] )
             ( #was: #done folderize plugins ([#xx-008]) )
             ( #was: #done #parent-node: [#015] change syntax to work with contiguous nonblank lines )

[#031] #open sunset io spy `qualified_knownness` for io spy group, re-purpose former to house mocks
             ( #was: #done #universal while regret no longer wires test nodes for autoloading  )

[#030]       (assorted quickie meta)

       #wish :[#here.4]: maybe drop quickie onefile into recursive runnner..

             ( #was: :[#here.C]: quickie plugin arch needs rearch - too confusing )

             :[#here.B]: recursive runner (plugins) help screen
               (when open, was the need to cover it)

             :[#here.A]: quickie core features help screen needs covering (#done)

             ( #was: #moved-to: [#dt-xxx] )

[#029]       #track the 'expect' omnibus and narrative ..
[#028]   #watching what do we have to do to get our custom predicates to
             work in both
             ( #was: "possible" #moved-to: [#ta-004]  ("eventpoint"))
             ( #was: #done borked quickie architecture near constants )

[#027]       track adapters for test suite solutions
             ( #was: #moved-to: [#dt-XXX] )

[#025] #wish consider using plain old glob instead of find, compare viability,
             performance. replace if better, or make adapters out of them.
             (for the thing that finds test files)

             ( #was:  #moved-to: [#dt-XXX] )

[#025]       slowie..
             ( #moved-to: [#dt-XXX] )

[#024]       [ the "subdivide" script ]
             ( #was: "verbosity" module REMOVED because ancient )
             ( #was: #doc-node the graded verbosity narrative .. )

[#023]       #doc-node #parent-node: [#020] "the IO spy"
[#022]       #parent-node:[#021] "when to extlib and not to extlib.."
[#021]       #doc-node the core node narrative ..

[#020]       #doc-node the IO spy composite types narrative ..

[#019]       #node-point "tree walker" (became [#!gone:hl-176] then [#sy-018])
[#018]       #quickie #in-situ

[#017] #open super-randomize: break test execution up into N workers,
             based on per-sidesystem (or unit) cost calcuations!
             ( #was: the regret narrative )

[#016]       #parent-node:[#017] why we do not include parent anchor module..

[#015]       #to-benchmark (in-situ in [dt])
             (#moved-to: [#dt-001])
             reminder: "benchmarks" are in [sl]

[#014]       file-coverage [ big tree ]
             ( #was: #moved-to: [#dt-XXX])

[#013]       file coverage implementation notes ..
             ( #was: #historical #done #inquiry-point choke point etc )
               (#relates-to [#ts-013]) ([#xx-004]))
             #done 351 extra tests (but this issue 2 states ago .. oh boy)

[#012]       file coverage (stub file of a public introduction)
             (#moved-to: [xx])
             ( #was: [#xx-006] )
             ( #was: #done #parent-node: [#015] setup vs example? )

[#011]       #track fix 'test/' - 'TestSupport' for autoloading?
[#010]       #track "dark hack" this one weird old trick makes ..

[#009]       track ways in which quickie might differ behaviorally from rspec

             :[#here.F]: `-doc-only`, apparently not present in rspec

             :[#here.E]: before all blocks give you NO context

             :[#here.D]: we are so great because we mock caller locations
               we are so great

             :[#here.C]: in reporting "Run options", we report all the
               relevant "reducers" that were provided on the command line,
               as opposed to r.s which apparently reports only those in the
               .rspec (or equivalent) file. (we deal with no such file.)

             :[#here.B]: multiple *tags* are AND'ed together,
               but multiple line ranges are OR'ed together. discussion:

               for practical purposes this makes the most sense:
               `--tag=focus --tag="~slow"` probably wants to narrow the
               search, not widen it. (that is, AND, not OR).

               but to AND together multiple line ranges certainly makes
               no sense, because that would always match nothing.

               furthermore, such a "reducer" of tags and such a "reducer"
               of line ranges, if present together, are AND'ed not OR'ed.
               (saying "everything after line 50 that is not wipped" is
               probably more broadly useful than saying "X OR Y".)

               of course the logical but absurd extreme of this would be
               to support the same kind of syntax of the unix `find`
               utility, which we're piddling around in our heads as an
               idea.

         #open the above is open while we don't know exactly what r.s does
               in this regard. it is closed when we can document its
               difference, or that there is none.

             :[#here.A]: (not referenced anywhere)
               will Quickie ever short-circuit (throw
               exceptions) on individual test-failures like ::Rspec?


[#008]       lend coverage / borrow coverage / referenced elsewhere small

             [#here.4]: referenced by [ze]
             [#here.3]: with [ta], [ze]
             [#here.2]: with [ze]
             [#here.1]: with [ze]


[#007]       (mostly) internal tracking

      #open  [#here.D]: quickie root invocation (runtime/context)
               (a not-covered code sketch/vestigial abandoned feature)

             [#here.C]: #in-situ

             [#here.B]: hand written help screen parsers for tests

       #track [#here.1]: track similar implementations of "line" structs (1x here 1x univ)


[#006]       the quickie recursive runner microservice ..
             ( #was: test/all: redundancy points, maybe waits for [#tm-056] )

[#005] #open quickie recursive runner '-tag=~wip' doesn't work (try it in [sn])
             ( #was: #redundant s-tylize. wontfix - it's ok to be redundant here)
             ( #was: confessions of an ambiguous grammar .. )
             ( #was: #done test/all should (whitelist) run the tests in the
               provided order, and not the lexical order? (see [#xxx].))
             ( #was: #done rename `all_specs.rb` -> all )

[#004]       quickie ..

[#002] #open cover and finish "pending" feature to be feature complete

             ( #was: coverage is waiting for [#tmx-011] upgrade rspec )
             (and presumably some other things.._

             coverage is a no fun zone ..
             ( #was: #done Constants too )

[#001]       test-suite architecture and conventions..
             (local keywords: regression order numbering scheme)
             (namespaces, modules) (also, cross-reference to [#fi-017])
