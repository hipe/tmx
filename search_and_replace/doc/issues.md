[#031]       tagged throughput ..

[#030] #open get regexp to display its source
             ( #after-or-as-part-of custom view controllers )

[#029] #open be the vanguard of a unification of pretty path (there's
             one in [sy] and one in [br]), one that relies on a client
             to tell it what the pwd and ENV['HOME'] is during one
             "session", and one that is more testable.

             as it is it is pretty nasty to (a) hit these without making
             them testable and (b) they won't scale

[#028] #open verbose (by default we should not express zoopie and doopie)

[#027] #open niCLI won't be able to handle a replacement expression that
             looks like an option (i.e starts with "--").

[#026]       (integration test tests a vendor feature ([ts]))

[#025] #flit drop-in from niCLI to CLI, if for e.g there are missing
             required arguments. hypothetically this would be an amusing
             way to "store settings" of an S/R and bring them back up
             for another session with different arguments. this might,
             however, be a bad idea; and in any case should come post-
             #milestone-9.

             it is implemented there should be an option in niCLI that
             prevents this drop-in from happening (or one that allows it
             to) so that non-interactive sessions that are intended to
             be so can stay that way.

[#024] #track complicated client interface (used in [ts]) "wip them all"

[#023] #when-etc use (or don't) for all occurrences of old memoize
             (after benchmarking it)

[#022] #when-etc use (or don't) for all occurrences of `return`

[#021]       [ the interface model ]

[#020] #if-you-like-pain (we first thought of this while implementing
             the last of all the "re-writes" where "hybrid" entities
             became plain old (and clean!) [#fi-007] sessions): for any
             one of these guys (but probably the last one, "matches")
             it would be nice if this was isomorphic with making the
             session class as we have done: rather than that, use A)
             a plain-old-proc in conjunction with B) its declaration
             of a special parameter value source (like before) with C)
             the paramers DSL (oldschool [ac] style) to stipulate which
             of its parameters are optional. all of this can in theory
             replace cases where we have implemented an operation with
             a session-class that has a trivial, 1-method body..
             but this all is an effort that at the least should start
             in [ze] with a dedicated story-ACS.

[#019] #during (or after) #milestone-8 (i.e this rewrite) (has subscribers)

[#018]    #usability-enhancement - location #before:[#017]

[#017]    #usability-enhancement - line numbers #before:[#016]

[#016]    #usability-enhancement - munge "next" over "next file?"

[#015] #open this new regexp 'o' option - what should we do with it?

[#014]    #track #experiment ONLY TO SUPPORT TESTS :/

             for the cases of wanting to test the same file against the
             same search-and-replace parameters but with different
             match replacements variously engaged or not engaged; we
             tried to cheat and use the same edit session in different
             tests. but making the tests order-sensitive like this
             violates the fundamental rules of unit testing against
             the same, and it *did break* (with one test lib and not the
             other no less).

             on the other extreme end, to call the API several times on
             the same filetree with the same parameters is so nasty (system
             calls to find and grep and all) that the more we considered
             it the less let ourselves even consider it.

             another alternative is to write a recursive `clear` method,
             but this effectively re-exposes us to the the same risky
             conditions that got us into this mess - that of testing
             different scenarios on the selfsame object graph.

             so what we were left with was to deep-dup some reasonable
             part of the object graph (the edit session). this is seen
             as the most "elegant" as it is by some order of magnitude
             cheaper than calling the API again, and does not incur the
             above mentioned risks that a recursive `clear` would.

             the only problem with this is that it violates another
             testing rubric - we now have code in our asset tree that is
             only in service of our tests in this regard.

[#013]       the context lines algorithm ..

[#012]       blocks ..

[#011]       #during #milestone-8
             this should be a step towards "releasing" this..
             #blocker this will CONVERT non-unixy newlines to unixy.
             this was an accident stemming from the "optimization" near
             `NEWLINE_SEXP_` and the custom line scanner and will
             require some redesign (either never use a const value for
             these or detect which was used and whether (ICK) the
             sequence changes.)
             ([my] has the beginnings of a sketch for a solution to this..)

             NOTE when the above closes, use this node identifier to
             track the line scanner and "LTS" "theory" in general.


[#010]       document structure ..

[#009]   #investigate consider merging read-only rendering with edit session rendering
[#008]       #feature have the multiple forms save to one file
[#007]       #feature explicit choice of single line v. multiline

[#006] #open tests nastily rely on number of lines of debugging output
             (near [#028] verbose)
             ( #was: #during #milestone-6 descriptions )
             ( #was: #done #feature support for spaces in list items )

[#005]       A-B partitioning
             ( #was: improve architecture so we can pass things like system
             conduits in some way that does not disrupt the elegance of
             the [#ac-027] relationships. )

             ( #was: #feature make this one button with three labels
               instead of three buttons )

[#004] #open re-integrate availability after #milestone-9 (is [#ze-021])
             ( #was: #feature should check mtime before write, abort for
             that file if stale. #wontfix because VCS integration
             obviates this. )

[#003]       [ track a historic node ]

[#002]       unified language ..
             ( #was: dry run )
             ( #was: annihilate all traces of "expect interactive" )
             ( #was: -wip-them-all (in [ts]) *uses* this guy..
             we need to decide how to cover.. )

[#001]       [ the readme ]
