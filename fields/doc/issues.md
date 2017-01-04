[#039]       [ defined attribute ]

[#038]       meta-meta-attrirubtes justification ..

[#037]       meta-attributes justification ..

[#036]       failure tree expression..

[#035] #itch 1x (in situ in [hu]) it would be nice to get nothing from
             the actor at all to pollute the namespace of builder
             methods. (edit: probably throu using attrs alone, no actor)

[#034] #hole ( #moved-to: [#co-xxx] )
[#034] #hole ( #was: track redundant or near-redundant polymorphic stream )

[#033]       iambics..

[#032]       any result path (in [#016])

[#031] #open move [#ca-04[56]] to here

[#030] #open dedund this

[#029]       in situ track universal redundancy

[#028] #open do *not* implement with [br] - break this tie..
             ( and [stack] )


[#027]       [store]  (ivar-based, mostly)

[#026] #open struct vs. actor - one is cold one is hot

[#025]       #parent-node: [#002] "formal vs. actual attributes.."

[#023]       #wish - when the time comes - track inheritence merging

[#022]       #track - this tracks two related phenomena, both typically
             marked by the implementation of a `normalize` method:

             1) the workaround (perhaps temporary perhaps not) for the
             change when methodic actor was assimilated by [fi] attributes.
             this is the the prickly problem of how/when we should
             "normalize" vis-a-vis the main method of
             `process_polymorphic_stream_passively`.

             2) more generally it may also be used to track "sessions"
             that do not have enclosed edit sessions, so they need to
             have this `normalize` called at user-determined times..
             (more on this at [#012]:#idea-1.)

[#021] #watch future redundancy - reflect all method-based attributes (in [br])

[#020]       #watch or not to memoize method-based attributes (they are so light)

[#019]       similar implementations

[#018]       let me count the ways we parse ..

[#017]       [#ts-001] describes the "clean", flat way we architect test
             suites generally. but when we need (or really want) "sandboxed"
             modules in which to write plain old constants (just for
             that test), the way we do it is a bit of a nuisance.
             (this is #[#ts-048] an instance of "sandboxed" modules.)

             we will chose some arbitrary module whose namespace we will
             be responsible for in the entire scope of tests that use
             it. we chose the test library node, because meh why not.

             1) we load that module explicitly. (maybe autoloading would
                work, but meh for now)

             2) with that module loaded, we will define the remainder of
                this file within that sandbox module.

             3) we have to reach the `describe` method this way under
                quickie, unless `enable_kernel_describe` but meh.

             4) with the library module we enhance the text context
                (which is what `use` does, but we avoid the overhead..)


[#016]       [ actor ]  (will move from [co])

[#015]       track assimiliation targets "missing"

[#014]       "the arity exegesis .." (:"parameter arity" & :"argument arity")

[#013]       the unification of methodic actors into (here) "attributes"

[#012]       now the "normal normalization" algorithm (and its variants)..

             (from the original [sl] description:)
             this tag tracks code instances of the general algorithm
             (and variant algorithms towards the same end) of
             implementing behavior that implements the validation &
             normalization of actual
             { arguments | attributes | parameters | properties };
             #normalization #algorithm

             ( #was: #done redesign this `with_client` nonsense )

[#010]       the external functions experiment ..

[#009]       meta-attributes ..
             ( #was: transplant "parameters" from [hl] )

[#008]       #in-situ [ the absorber method maker ]

[#007]       [ SESSION PATTERN ]

[#006]       [ struct ]
             ( #was: old reference code from [ta] for for retrospective )

[#005]       [ from ]

[#004]       [ basic fields ]

[#003]       the declared fields narrative .. (this will assimilate to [#013])

[#002]       the attribute narrative ..
[#001]       discussion of all the property libs ..
