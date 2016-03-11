[#025]       #parent-node: [#002] "formal vs. actual attributes.."

[#023]       #wish - when the time comes - track inheritence merging

[#022]       #track - the workaround for the change .. (in situ in universe)
             more generally this also tracks the prickly problem of
             how/when we should "normalize" vis-a-vis the main method
             of `process_polymorphic_stream_passively`

[#021] #watch future redundancy - reflect all method-based attributes (in [br])

[#020] #open in-situ

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


[#016]       [ actor ]  (will move from [ca])
[#015]       track assimiliation targets "missing"
[#014]       "the arity exegesis .." (:"parameter arity" & :"argument arity")
[#013]       p8r
[#012]       #done redesign this `with_client` nonsense
[#010]       the external functions experiment ..
[#009]       transplant "parameters" from [hl]
[#008]       #in-situ [ the absorber method maker ]
[#007]       [ SESSION PATTERN ]
[#006]       for retrospective ..
[#005]       [ from ]
[#004]       [ basic fields ]
[#003]       the declared fields narrative ..
[#002]       the attribute narrative ..
[#001]       discussion of all the property libs ..
