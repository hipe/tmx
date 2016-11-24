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

[#039] #hole ( #moved-to: [#dt-xxx] )

[#038]       expect line

[#037] #hole ( #moved-to: [#dt-XXX] )

[#036] #ongoing   indentation in quickie

[#035]       #track `def test_support` (for `\.test_support`) occurrences,
             which *must* all follow this:
             we must use `require_relative` (and not `require` or `load`)
             here, otherwise if our native tests are run after this method
             is called, ruby will load the file redundantly which under
             some autoloaderifications will bork apparently flickeresquely

[#034] #hole ( #moved-to: [#dt-XXX] )

[#033]       #historical #done fix test globbing .. [#xx-009]
             ( #was: #done if you un-orphanize core.rb it presents an issue with autoloader) )
[#032] #open the "counts" report is not covered, verbose mode is borked
             ( #was: white plugin whines weirdly when strange files are in
               lib/skylab ([#xx-007] )
             ( #was: #done folderize plugins ([#xx-008]) )
             ( #was: #done #parent-node: [#015] change syntax to work with contiguous nonblank lines )

[#031] #open sunset io spy `qualified_knownness` for io spy group, re-purpose former to house mocks
             ( #was: #done #universal while regret no longer wires test nodes for autoloading  )

[#030] #hole ( #moved-to: [#dt-xxx] )

[#029]       #track the 'expect' omnibus and narrative ..
[#028]   #watching what do we have to do to get our custom predicates to
             work in both
             ( #was: "possible" #moved-to: [#ta-004]  ("eventpoint"))
             ( #was: #done borked quickie architecture near constants )k

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

[#012] #open [ file coverage ] hasn't been working since whenever, do whenever,
             see other nearby notes.
             (#moved-to: [xx])
             ( #was: [#xx-006] )
             ( #was: #done #parent-node: [#015] setup vs example? )

[#011]       #track fix 'test/' - 'TestSupport' for autoloading?
[#010]       #track "dark hack" this one weird old trick makes ..
[#009]       #subscription - will Quickie ever short-circuit (throw
               exceptions) on individual test-failures like ::Rspec?
[#008]       #track quickie root invocation (runtime/context)
[#007]       #tracking tag of similar places with line / `call_digraph_listeners` structs
[#006] #open test/all: redundancy points, maybe waits for [#tm-056]
[#005] #open #quickie #redundant s-tylize
             ( #was: confessions of an ambiguous grammar .. )
             ( #was: #done test/all should (whitelist) run the tests in the
               provided order, and not the lexical order? (see [#xxx].))
             ( #was: #done rename `all_specs.rb` -> all )
[#004] #open quickie: module names into fashion (and now narrative)

[#002] #open coverage is waiting for [#tmx-011] upgrade rspec
             (and presumably some other things.._

             coverage is a no fun zone ..
             ( #was: #done Constants too )

[#001]       test-suite architecture and conventions..
             (local keywords: regression order numbering scheme)
             (namespaces, modules) (also, cross-reference to [#fi-017])
