[#036]       [ the node ticket streamer ]

[#035]       unified language ..

[#034] #wish "normal category" (currently in [ze])

[#033] #open edge case not covered (see)

[#032]       in-situ - formal parameter stream requested 3 times?

[#031]       a "selection stack" is effectively (when complete) a reference
             pointing to a "fully qualified" formal operation ("action" in
             [br]).

             • it's typically an array (but may be a [#ba-002]#LL linked list)
             • it always has at least a "root" item (representing the start)
             • when complete the top item represents the formal operation
             • every item but the root item must produce a [#ca-060] `name`
             • when complete it is always at least two items long

             the selection stack can be used both in the fancy [#hu-043]
             contextualization of emissions, and it can be used in
             assembling a prepared, callable operation.

[#030]       kind of nasty API point near formal op building (in-situ)

[#029]       [ stream via platform params ..]

[#028]       parameters normalize..

[#027]       ..
             this tracks two separate but related phenomena:

             specifically, the experiment of where a formal operation
             indicates as required (or maybe optional) parameter another
             formal operation (to mean its true-ish result) (a [ze] thing).

             more generally this is also used to track side-effects of
             (and hook-outs necessary for) formals that define their own
             parameter value readers.

             (if this breaks out into its own file, see comments this commit)

             :#A is custom execution of the [#fi-007] session, amounting
             to a system-private API. this tracks patterns near that.

             coincidentally, [#ze-027] is related.

[#026]       `singplur`, `is_singular_of`, `is_plural_of`, argument arity..

[#025]       #after: [#010]

[#023]       tracks places where the assumption is made that we are not
             long-running. if/when "long-running"-ness occurs for an
             application, these are areas that make calculations redudantly.

[#022]       [ reader-writer ] AND theory..
             ( piggy-back a not-yet-defined definition of :"compoundesque" here too)

[#021] #open our n11n partially duplicates the n11n in [fi]
             ( #was: assimilated c15n into [hu] )

[#020]       [ parameter ]
             ( #was: assimilated c15n into [hu] )

[#019]       [ intent ]
[#018]       [ load ticket ]  (as a concept)
[#017]       #when: [#010] finally look at keyword args

[#016] #open will this treatment of "floating" steam-roll existing values?

[#015]       node parse..

[#014]       imperative phrase..

[#013]       #track where we implement custom meta-components
             (#was: for transitive result value, hook-in not hook-out)

[#012]   #maybe implement transitive operations with formals instead of
             method-based implementation..

[#011]   #when:[#sa-019] sub `ACS_` for `Home_` (this idiom didn't age well)

[#010]     #after #milestone-9 decide if we keep this way or not..
             this big campaign (the 9 milestones) (has subscribers here)

[#009]       intro to operations..

[#008]   #possible-feature extension API for the *modifiers* for use in mutation sessions
             (we're not sure we want this yet. this just tracks the idea.)

[#007]       "expressive events" (and the canonic component events) ..
             ( was: assilated c15n into [hu] )

[#006]       construction, composition and eventing ..
[#005]       the master list of sections ..
[#004]       thoughts on ACS isomorphisms ..
[#003]       interpretations to and expressions of an ACS ..
[#002]       tenets and the edit session ..
[#001]       [the readme]
