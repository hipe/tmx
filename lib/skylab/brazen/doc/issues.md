[#084]       :+#wishlist a `flag` meta-meta prperty
[#083]       #done workspace `init` action should not default to '.' in API
[#082]       #tracking `list` implementations
[#081]       #track experimental extensions to Actor
[#080]       #parent-node:[#013] actors, agents and models ..
[#079]       #done rather than the model action ever having to know about the
             modality adapter, the modality action should make a custom
             adapter class and in that class set the default iambic starter.
             this is what the new hidden-ness of properties is for. all
             modality-specific customization of actions should be
             available thru this means, obviating a need for the action
             to have direct knowledge of the adapter layer
[#078]    #tracking - need better way to do this (in [ts])
[#077] #open maybe try a positive meta-property with a default instead of `hidden`.
[#076] #open end-client gets [#021] magic for `retrieve` (was: [same for list])
[#075]    #tracking :+#wishlist optionally generate ivar-based iambic writers
[#074] #hole ( was: #parent-node: [#011] the codifying expression agents)
[#073] #hole ( was: #parent-node: [#011] selective event listening via methods )
[#072]       #done (was: modernize this interface)
[#071]       #tracking-tag wrap
[#070]       #tracking-tag when we intentionally expose a mechanical
               ivar as a property
[#069]       #tracking-tag all implementations of `verbose` can probably
               be replaced with selective event listeners
[#068]       #tracking-tag #parent-node: [#021] we like list methods to be
               API friendly and result
               in a stream instead of emitting one event for each item *maybe*
[#067] #open smooth different interfacings with API actions taxonomy
[#066]       #done cool new build-less events
[#065]       #done implement unmarshaling for strings with newlines (git-config)
[#064]       #done marshal issue near regexps with escape-looking sequences
[#063]       [ isomorphicisms and emergent interfaces ]
               [fa] near [#fa-006], [#gv-030] sets the stage nicely)
[#062]       #doc-node the zerk narrative ..
[#061]       #tracking-tag `members` as a universal thing
[#060]       #done issue with parsing properties
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
[#045]       #parent-node: [#001] "the meta-properties narrative.."
[#044]       #done graph has an action so maybe we don't need to pass it everywhere
[#043]      #tracking-tag loading hacks
[#042]       #done make persit entity interface symmetrical with delete entity
[#041]       #done rename "collections controller" to "silo controller"
[#040] #open in git-config, for set value, nil as literal value is undefined
[#039]       #tracking-tag whether and where we change case of env vars
[#038]       #parent-node: [#010] the couch datastore narrative ..
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
[#028]       #parent-node: [#010] the datastore actor narrative ...
[#027]       #done do not throw exceptions for parse errors
[#026]       #parent-node: [#025] the collection controller narrative ..
[#025]       #doc-node: the brazen four layer model model ..
[#024]       #parent-node: [#025] the model action narrative ..
[#023] #hole ( was: #parent-node: [#011] event prototype )
[#022]       [ entity identifier ]
             ( was: #done obliterate `receive_negative_event` and the rest - single
             entrypoint is better. rely on `ok` : false )
[#021]       the API magic result shape narrative .. (was "scope kernel")
[#020] #open  --help and --host
[#019]       [ byte upstream identifiers ]
             ( was: #done turn `is_positive` into `ok` to match HTTP responses )
[#018]       #parent-node: [#013] "the model property ordering rationale.."
             (was: #parent-node: [#013] "model ivars..")
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
             (was: #done re-arch expressions agents to work correctly with 'par')k
[#004]       #parent-node: [#002] the help renderer narrative ..
[#003]       #parent-node: [#002] the CLI state processors narrative ..
[#002]       #doc-node brazen CLI
[#001]       #doc-node the entity enhacnement narrative ..
