[#119] #open get [fm] out of test (see)
[#118]       do we want the ability to have a model-less-action? for now, no
[#117] #open we might want top invocation to be able to emit events with
             the same interface as action adapters, which would change
             the inheritence graph considerably
[#116]       :+#tombstone: "client services" is no longer a thing
[#115]       the `par` method of expags ..
[#114]       (posterity) ..
[#113]       exit statii ..
[#112]       ..
[#111]       what does application even mean ..
[#110]       ..
[#109]       when missing arguments fancy ..
[#108]       ..
[#107]       ..
[#106]       ..
[#105]       ..
[#104]       ..
[#103]       the CLI isomorphic methods client narrative ..
[#102]       :+#tombstone: removed old & complex o.p that parsed '--'
[#101]       #investigation - how to architect.
[#100]       an introduction to a reactive model ..
[#099]       [ branch node for historical documents ]
[#098]       things that should probably subclass interface tree node
[#097] #open get this ellipsis hack out
[#096] #open the (CLI) table narrative ..
[#095]       features that [fa] has that you don't #universal
[#094]       expression agents adjunct notes ..
[#093]       what is the deal with expression agents ..
[#092]       [ CLI styling ]
[#091]       [ entity identifier ]
             ( #moved-from [#here-022] )
[#090]       arity ..
[#089]       the ACS (autonomous component system) ..
[#088]       the meta-meta-properties justification ..
[#087]       #track similar normalization logics (this might be a redundant tracker)
[#086]       #track cases where failure is "fuzzy" (i.e non-atomic),
               ignored for the greater good, for usability
[#085]       [ module as model ]
[#084]       :+#wishlist a `flag` meta-meta prperty
[#083]       use blocks as selective event receiver (optionally) for proc as action
             ( #was: #done workspace `init` action should not default to '.' in API )
[#082]       #track meta-meta-property candidates (list, enum etc)
[#081]       #track experimental extensions to Actor
[#080]       #parent-node:[#013] actors, agents and models ..
[#079]       #parent-node:[#050] the API API components narrative
             ( #was: #done rather than the model action ever having to know about the
             modality adapter, the modality action should make a custom
             adapter class and in that class set the default iambic starter.
             this is what the new hidden-ness of properties is for. all
             modality-specific customization of actions should be
             available thru this means, obviating a need for the action
             to have direct knowledge of the adapter layer )
[#078]    #tracking - need better way to do this (in [ts])
[#077] #open maybe try a positive meta-property with a default instead of `hidden`.
[#076] #open end-client gets [#021] magic for `retrieve` (was: [same for list])
[#075]    #tracking :+#wishlist optionally generate ivar-based iambic writers
[#074]       option parser hack for '-1', '-2' etc ..
             ( #was: #parent-node: [#011] the codifying expression agents)
[#073]       lipstick ..
             ( #was: #done awareness of system environment does not belong in the model - )
             front clients should do this mapping somehow..
             ( was: #parent-node: [#011] selective event listening via methods )
[#072]       where the colon goes on headers! #parent-node: [#002]
             ( #was: #done `is_silo` can probably go away )
             ( #was: modernize this interface )
[#071]       #tracking-tag wrap
[#070]       #tracking-tag when we intentionally expose a mechanical
               ivar as a property
[#069]       #tracking-tag all implementations of `verbose` can probably
               be replaced with selective event listeners
[#068]       #tracking-tag #parent-node: [#021] we like list methods to be
               API friendly and result
               in a stream instead of emitting one event for each item *maybe*
[#067] #open smooth different interfacings with API actions taxonomy
[#066]       [branch adapter] how add modality-only action #parent-node: [#003]
             ( #was: #done cool new build-less events )
[#065]       #track procs are always not-promoted
             ( #was: #done implement unmarshaling for strings with newlines (git-config) )
[#064] #open either rename `desc` to `entity_description` or make
             the syntax smarter without bloating it.
             ( #was: #done marshal issue near regexps with escape-looking sequences )
[#063]       [ isomorphicisms and emergent interfaces ]
               [fa] near [ CLI revelation gone ], [#gv-030] sets the stage nicely)
[#062]       #doc-node the zerk narrative ..
[#061]       #tracking-tag `members` as a universal thing
[#060]       #tracking ways we customize CLI action adapter rendering customization
             ( #was: #done issue with parsing properties )
[#059]       #doc-node names
[#058]       #parent-node: [#057] the default frame
[#057]       #parent-node: [#001] the properties stack
[#056]       #doc-node re-usable silos
[#055]       #parent-node: [#056] the workspace narrative ..
[#054]       #tracking-tag where to increment error count? (both in
               entity and action)
[#053]       #tracking-tag for bound arguments, bound is not truly bound
[#052]       #feature-tracker `path_hack`
[#051]       #parent-node: [#050]
[#050]       #doc-node the API narrative ..
[#049]       #parent-node: [#cb-046] case study: iambic ordering hacks
[#048]       #parent-node: [#024] "#action-preconditions.."
[#047]       #parent-node: [#013] the model entity narrative
[#046]       #parent-ndoe: [#024] the action factory narrative ..
[#045]       [ expect section ]
             ( #was: #done graph has an action so maybe we don't need to pass it everywhere )
[#044]       #parent-node: [#001] the meta-properties justification ..
[#043]       the frontier of a back-less front action
             ( #moved-to: [#pa-008] was tracking abstraction cand. )
             ( #was: the fancy bundle lookup exegesis .. )
             ( #was: #tracking-tag loading hacks )
[#042] #open here is the plan with this one: this BS being done here
             now, make the brazen *app* client somehow do it on its own.
             and instead make the default be handing for `sin` `sout` `serr`
             #tracking-tag mutate formal properties by front client etc ..
             ( #was: #done make persit entity interface symmetrical with delete entity )
[#041]       #sibling: [#021] magic property names case studies ..
             ( #was: #done rename "collections controller" to "silo controller" )
[#040] #open in git-config, for set value, nil as literal value is undefined
[#039]       #tracking-tag whether and where we change case of env vars
[#038]       #parent-node: [#010] the couch collection narrative ..
[#037]       [ this feature of unmarshal ]
[#036]    #watching to go from a literal to a resolved const its kind of awful
             to lose and re-parse the demarcation that is already present
             in it but meh is it worth it to hack the algorithm for this?
[#035]       #tracking-tag events that should not be UI-level events
[#034]       #parent-node: [#026] the deleting narrative ..
[#033]       #parent-node: [#026]  [the update narrative]
[#032]       #parent-node: [#026] the entity scan narrative ..
[#031]       #parent-node: [#026] the retrieving narrative ..
[#030]       #parent-node: [#026] the creating narrative ..
[#029]       #parent-node: [#028] "a universal normal name convention.."
[#028]       #parent-node: [#010] the collection actor narrative ...
[#027] #open #tracking the zero-configuration dream - one day, [br]-powered
               API's should need not define a 'Kernel' / 'Kernel_' nor have
               a dedicated 'API' file - just limit it to a singleton
               method defined on the toplevel sidesysetm that produces
               the daemon or kernel by calling [br])
             ( #was: #done do not throw exceptions for parse errors )
[#026]       #parent-node: [#025] the collection controller narrative ..
[#025]       #doc-node: the brazen four layer model model ..
[#024]       #parent-node: [#025] the action narrative ..
[#023]       #experimental-feature-tracker: ( described in [#024] )
             ( was: #parent-node: [#011] event prototype )
[#022]       [ EDIT: document formal properties  ]
             ( #was: entity identifier. #moved-to: [#here-091] )
             ( #was: #done obliterate `receive_negative_event` and the rest - single
             entrypoint is better. rely on `ok` : false )
[#021]       the API magic result shape narrative .. (was "scope kernel")
[#020] #open  --help and --host
[#019]       [ byte upstream identifiers. ]
             :[#.D]: byte downstream identitfiers.
             ( was: #done turn `is_positive` into `ok` to match HTTP responses )
[#018]       #parent-node: [#013] "the model property ordering rationale.."
             ( #was: #parent-node: [#013] "model ivars..")
[#017] #open environment variables need a general solution, probably one
               where the front client handles this alone.
[#016]       #parent-node: [#013] the inferred inflection narrative ..
[#015]       #doc-node: the kernel narrative ..
[#014] #open `has_custom_moniker` is a smell to exist in entity.
[#013]       #parent-node: [#025] the model
[#012] #open now that the `properties` shell is not memoized, see if etc
[#011]       the unobtrusive lexical-esque ordering narrative ..
             ( was: #parent-node: [#001] the event narrative )
[#010]       #doc-node: data stores
[#009]       #parent-node: [#010] the git config narrative ..
[#008]       #parent-node: [#009] the mutable git config narrative ..
[#007] #open anticpating the issue with losing hooks accross inheritance bounds
[#006]       #doc-node the defaults vs required narrative ..
[#005]       [name]  (compound names derived from model nodes)
             ( #was: #done re-arch expressions agents to work correctly with 'par')k
[#004]       #parent-node: [#002] the help renderer narrative ..
[#003]       #parent-node: [#002] the CLI state processors narrative ..
[#002]       #doc-node brazen CLI
[#001]       #doc-node the entity enhacnement narrative ..