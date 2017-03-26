[#066]       [ model re-use ]
             it's ghastly. although you could sub-class model actions,
             don't. doing so becomes a liability for the host application.
             only reuse those magnetics exposed as part of the
             microservice model's public API (and as such keep real logic
             out of the actions so it is exposed as potentially exposable
             but not interface-facing magnetics).

[#065]       introduction to a headless dream [ and project "W" ]

[#064]       non-interactive CLI "fail early" notes ..

[#063]       one-off mounting
             [#here.2]: help screen scraper (also tracked by [#054.3])
             [#here.1]: having to do with the "callback module"

[#062]       sometimes some clients want loadable references not symbols

[#061]       [ section ]  (imported from [br])
             [#here.3]: tracking where colons are added
             [#here.2]: the DSL node
             [#here.1]: the main asset node

[#060]       [ no dependencies zerk ]
              [#here.1] - `call` not `gets` in one place

[#059]       horizontal meter (née "lipstick")

[#058] #open make tuple pager ([ze]) fit in with statistics
             new table rendering logic as indicated is redundant with [#this]
             as indicated in this sidesystem.

[#057] #wish how hard would it be to access the hook mesh pipeline and
             rendering guys when making the summary results (in #table)?
             so you could say `o << "Total: #{ wahoo[ f ] }"` and have the
             `wahoo` infer the typeish of `f` and use whatever existing cel
             renderer was established for the others? caveats etc

             ( #was: track table: shorthand version of a total field? probably not. )

[#056]       [ syntaxish ]

[#055]       didactics / ouroboros ..

[#054]       [track help screen test library]
             [#here.4] "coarse parse"
             [#here.3] actually in [tmx], furloughed at writing
             [#here.2] from ancient [br], now "magnetics"
             [#here.1] now "fail early" [#here.1-1] #subscribed-by [cm] (see in-line)

[#053]       feature injection through compounded primaries..

[#052]       argument scanner ("a.s")

[#051]       the moving-target "operator branch" API,
             justified aptly in document.
             the comprehensive manifest of implementors is:

              [#here.G]: one-off adapter
       #open  [#here.F]: freeform  (#not-covered)
       #open  [#here.E]: mutliple entities  (see #open in code comments)
              [#here.D]: other branch
              [#here.C]: autoloaderized module
              [#here.B]: module
              [#here.A]: hash

             was: track simplified boxxy-like producers of primary hashes.

[#050]       [ CLI table notes ]  (closely related: [#tab-001])
             ( #was: the eventual home of unified table support. now: [#tab-001] )


[#049] #open it would nice if ACS-as-operation could express the parameter
             arity of their components somehow

[#048]       common relative-to-absolute filesystem path normalization

[#047]       [ tuple pager ]

[#046]       :#mode-tweaking, :#mode-tweak (frontier is in-situ in [ts])
             this is [ze]'s improvement on [#br-042]
             (there is some documentation of it in [#024])

[#045]       track this interruption handler for iCLI

[#044]       flag

[#043] #wish do something with the `default` for atomic components in
             niCLI. (needs design.) has subscribers.

[#042] #wish #high-value
             iCLI some idiom for clearing an atomic component
             (like entering a blank string). perhaps a `clearable`
             meta-component.

[#041] #wish #high-value
             defaulting across the bundled modalities ..

[#040] #open unify expression agent-ry between niCLI and iCLI

             get rid of [#co-010]; it's toxic

             #after #milestone-9 AND
             #after [#sy-005] unify pretty path
             [#here.1]: the idea of `human_escape` is actually write-your-own

[#039]       iCLI loadable references and customization DSL ..

[#038]       [iCLI performer] ..

[#037]       custom effection ..

[#036]       singular-plural across modalities..

[#035] #open help screens for primitivesques??

[#034]       niCLI is not long-running

[#033]       #API-point the expression of order of nodes for any one UI
             (A) isomorphed directly from the deep order and (for now)
             (B) must be the same order for all modalities (for now)

[#032] #wish maybe one day in niCLI style `<foo-bar>` as `--foo-bar`
             (NOTE - this is have done. when it is an argument it
             "knows" it is an argument. but as for option..)

[#031]       [ track operation dependency customization as a feature ]

[#030]       unified language ..
         #track [#]:#A is about whether a "reasoning" is always exactly one event

[#029]       introducing isomorphic interfaces ..
[#028]       in-situ
[#027]       formal parameter sharing ..

[#026]
             [#here.2]: API-choice for niCLI - emitting one or more `error`
             during during operation means your result will be disreagarded.

             [#here.1]: under API, `true`/`false` are now reserved for
             meaningful boolean.

[#025]       the result shape of operations ..

[#024]       stack frame ..  (mostly lengthy code notes) and..
             ( #was: redundancy in two events. removed the other. )

[#023]       CLI for..
           #track :[#here.3]: glob in niCLI
             ( #was: #open de-generalize the invites )
             :[#here.2]: styling diaspora
             :[#here.1]: styling

[#022]       [ microservices (mostly an assimilation of "isomorphic methods") ]
             :[#here.4]: isomorphic method arguments ..
             :[#here.3]: isomorphic methods microservice and CLI ..
             :[#here.2]: isomorphic methods microservice ..
       #open :[#here.A]: #track whast was lost when we stopped doing summary info
             ( #was: duplicate of [#021] )

[#021] #open #high-value
             availability for iCLI will be added after #milestone-9 -
             this was/is an "essential-seeming" usability mechanic of iCLI
             but it is fact non-essential. it pains us to postpone it b.c it
             was one of the main catalysts of the milestone "era" but alas
             the generated messages convey the same information (less
             elegantly) and there are more immediate concerns to get to
             first.

             ( #was: #track what to do about entitesque .. )

[#020]     #track argument monikers
[#019]     #track flags in o.p
[#018]     #track if you really wanted duplicate names
[#017]     #track the will to change this (in-situ) tailor-made option parsers

[#016]       "bespoke" explained in [#027]

[#015]       option parsing..
[#014]       [ flowcharts for CLI syntax ]
[#013]       [ index ]
[#012]       [ flowcharts for API syntax ]
[#011]     #track whether/how to share across 3 CLI client classes
[#010]       custom view controllers
[#009] #in-progress this rewrite (and new architecture..)

[#008]       coverage assets & liabilities (& other misc small)

             [#here.2-5] borrow coverage
       #open [#here.1]: eventually de-dup this with [#sy-029] OGDL

[#007] "threads" (tracking tags for experimentals towards public API)

             :[#this.G] - waiting for [br] to sunset
       #wish [#this.F] (crossreference to [#050.I]) total cels plus viz
             [#this.5] - this microconvention of nil-vs-false semantics (see)
             [#this.D] - primary value parsing API
             #thread-three - nils vs. false (w/ re: to input)
             #thread-two - `gets` resulting in `nil` == interrupt
             #!thread-one - used to be "hot model", now we use cold model

[#006]       expect screens ..
[#005]       [the view maker maker]

[#004]       iCLI (the bundled modality)..
             ( #was: [the compound adapter] )

[#003]       niCLI (the bundled modality)
             ( #was: [the primitivesque adapter] )

[#002]       API (the bundled modality)
             ( #was: [the event loop] )
             :[#here.1]: as "microservice", maybe will DRY this boilerplate

[#001] #open the readme (needs freshening up)
