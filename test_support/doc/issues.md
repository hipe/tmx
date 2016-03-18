[#049] #open change `state_` to something more appropriate in expect event

[#048]       described in [#001], this tracks "sandbox" module implementations

[#047] #open subscribers to quickie ever supporting a negate operator
             ("should not")
[#046] #open when doc-test rewrite, see subscribers
[#045]       permute (as a doctest action)
[#044]       lexical scope vs inheritence (as it pertains to us)..
[#043] #open modernize doc-test templates
[#042]       "dangerous memoize" (was "nasty OCD memoize") caveat ..
[#041]       static file server ..
             (#was: sidesystem class now in [tmx] & [sli])
[#040]       is find nearest TS file broken?
[#039]       #parent-node: [#030] #tracking a `Subject_` parameter function
[#038]       expect line
[#037]       #tracking tag warnings wishlist (#parent-node: [#014])
[#036] #ongoing   indentation in quickie

[#035]       #track `def test_support` (for `\.test_support`) occurrences,
             which *must* all follow this:
             we must use `require_relative` (and not `require` or `load`)
             here, otherwise if our native tests are run after this method
             is called, ruby will load the file redundantly which under
             some autoloaderifications will bork apparently flickeresquely

[#034] #open #parent-node: [015] "re-architect.."
[#033]       #historical #done fix test globbing .. [#xx-009]
             ( #was: #done if you un-orphanize core.rb it presents an issue with autoloader) )
[#032] #open the "counts" report is not covered, verbose mode is borked
             ( #was: white plugin whines weirdly when strange files are in
               lib/skylab ([#xx-007] )
             ( #was: #done folderize plugins ([#xx-008]) )
             ( #was: #done #parent-node: [#015] change syntax to work with contiguous nonblank lines )

[#031] #open sunset io spy `qualified_knownness` for io spy group, re-purpose former to house mocks
             ( #was: #done #universal while regret no longer wires test nodes for autoloading  )
[#030] #open #parent-node:[#015] the doc-test recursive spec needs mock fs
[#029]       #track the 'expect' omnibus and narrative ..
[#028]   #watching what do we have to do to get our custom predicates to
             work in both
             ( #was: "possible" #moved-to: [#ta-004]  ("eventpoint"))
             ( #was: #done borked quickie architecture near constants )k
[#027]       #parent-node: [#015] peek hack explained .. (was templo)
[#026]       #parent-node: [#015] the view-controller narrative ..
[#025]       #parent-node: [#015] output adapters.
[#024]       #doc-node the graded verbosity narrative ..
[#023]       #doc-node #parent-node: [#020] "the IO spy"
[#022]       #parent-node:[#021] "when to extlib and not to extlib.."
[#021]       #doc-node the core node narrative ..
[#020]       #doc-node the IO spy composite types narrative ..
[#019]       #node-point "tree walker" (became [#!gone:hl-176] then [#sy-018])
[#018]       #quickie #in-situ
[#017]       #doc-node #regret narrative
[#016]       #parent-node:[#017] why we do not include parent anchor module..
[#015] #open this tracks the rewrite (nodes waiting on it)
             #doc-node the doc-test narrative ..
[#014]       #parent-node: [#015] how nodes are generated ..
[#013] #hole ( #was: #historical #done #inquiry-point choke point etc )
               (#relates-to [#ts-013]) ([#xx-004]))
             #done 351 extra tests (but this issue 2 states ago .. oh boy)
[#012]       #doc-point #in-situ (the particular importance of result values)
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
               proivded order, and not the lexical order? (see [#xxx].))
             ( #was: #done rename `all_specs.rb` -> all )
[#004] #open quickie: module names into fashion (and now narrative)
[#002]       coverage is a no fun zone ..
             ( #was: #done Constants too )

[#001]       test-suite architecture and conventions..
             (namespaces, modules) (also, cross-reference to [#fi-017])
