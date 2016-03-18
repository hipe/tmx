[#156]       codepoints tagged with this tag exhibit this pattern:

             besides just memoing what the particular value was we also memo
             that this method called at all. this allows us to differentiate
             between it having been set explicitly to false-ish vs. it having
             not been set at all.

             (the same could be achieved thru `instance_variable_defined?`,
             but such a way introduces more risk for hard-to-trace failure
             though typos. alternately we could have two variables
             instead of one, but it deemed too noisy.)

             setting it to false-ish says explicitly "i don't want an X".
             when it is not set at all, the receiver can detect this
             case lazily and effect whatever it deems as default at
             whatever future point.

[#155]       scope stack trick..
[#154]       #bibliographic-reference:
             _Crow's Foot Notation_ (short document for coure material),
             G Benoït, Ph.D; Simmons University
             http://web.simmons.edu/~benoit/lis458/CrowsFootNotation.pdf
[#153]       [ example ]
[#152]       ([sl] code wormhole #in-situ)
[#151]       heavy models .. wired models [..]
[#150]       whining about ruby implementation of struct ..
[#149]       method cherry-picking ..
[#148]       the touch method function ..
[#147]       the method touching experiment ..
[#146]       justifying the `dupe` method ..
[#145]       #bibliographic-reference: _The Art of Unix Programming_,
               Eric S. Raymond, 2003
[#144]       #moved-to: (HERE) [#023]
[#144]       ( one more tag for ) this patern spawn-like dup and extend
[#143]       #parent-node: [#137] "branch and divide.."
[#142]       #bibliographic-reference: _Cocoa Programming for Mac OS X_,
               Aaron Hillegass & Adam Premble, 4th ed., Addison Wesley
[#141]       #placeholder (working title: "the gobstopper mock cycle")
[#140]       #parent-node:[#137] off-lining and on-lining ..
[#139]       #parent-node:[#140] "un-refactor.."
[#138]       #parent-node:[#137] "the golden plow.."
[#137]       #doc-node: workflow patterns ..
[#136]       #parent-node: [#137] "the golden two-step.."
[#135]       #facility-tracker: #exit-statuses
[#134]       #classification-tracker: nodes that are known "islands" - known
             to be covered only by tests but nowhere in production
             ( #was: #moved-to: [#fi-033]  (was: #structure-tracker #iambics) )
[#133]       #future-bibliographic-reference why #singletons are bad
[#132]       #bibliographic-reference: xUnit Test Patterns: Refactoring
               Test Code, Gerard Meszaros, 2007
[#131]       #tracking-tag all extlib - we are trying to avoiding these.
[#130]       #doc-point  all the letters of the alphabet ..
[#129]       #bibliographic-reference: _Clean Code_, Robert C. Martin, 2009
[#128] #open this is strictly a development, pre-alpha version
               (especially) as long as you are using skylab/tmp!
[#127] #open unify inflection module methods interface
[#126]       #tracking-tag singleton obj with class made just for readable errs
[#125]       #doc-point #workflow -- when you make overzelous, premature chage..
[#124]       (available)
[#123]       #convention #pattern sub-product module 2-level pattern
[#122]       oh boy. "tracking tag for everything not thread safe."
             ( #was: #done #low-priority phase out ROOT_PATHNAME for Skylab.dir_pathname )
[#121]       #pattern of CLI.new, API.invoke as facades hehe inv. of [#109]
[#120]       #tracking-tag backticks that could be robustified
[#119] #open #tracking-tag #pattern of def.self some_thing instead of DSL
[#118]       #track everywhere that you determine sidesystem composition
             ( #was: unify find command in multiple places (moved to [#sy-016]))
[#117]       #pattern of defaults (if not nil, etc) (near [#116])

[#116] #hole ( #moved-to: [#fi-012]. #was: normal normalization )

[#115]       #pattern of functionalizing things
[#114]       #pattern of "stdin, stdout, stderr" as constructor to CLI clients
[#113]       #pattern of PIE standard
[#112]       #pattern of emit error
[#111]       (was [#109]!) #pattern self.extended mod pattern
[#110]       #convention hipe's rules of order for delcarations in a class ..
[#109]       this whacky #pattern of using a class as a namespace
[#108]       #low-low-priority #pattern normalization
[#107]       #low-priority 2012-11-02 this lexical scoping issue
[#106]       :+#pattern: the spawn pattern (currently described in [#sy-016])
             ( was: #done 2012-10-28 autoloading vis-a-vis const awareness )
[#105] #open 2012-08-18 play with test/all_specs.rb -w
[#102.901.3.2.2] #doc-point #open 2012-06-12 towards an event wiring pattern ..
[#101] #open 2012-06-08 when doing gem install with rdoc, "stack level too deep"
[#100.200.001] #open 2012-06-12 all.rb: fix @delegates tags
[#096] 2012-03-30 @closed: code-molester: files are not paths
[#095] 2012-03-29 @closed: static fileserver refactor
[#094] 2012-03-28 @closed: tanman: refactor: this shit is a mess (still).
[#093] 2012-03-28 @closed: tanman: status
[#092] 2012-03-19 @closed: tanman: refactor into api, test all
[#091] 2012-03-17 @closed: tanman: local .tan
[#090] 2012-03-16 @closed: porcelain: table: column type inference
[#089] 2012-03-15 @closed: tanman: remote: remove
[#088] 2012-03-15 @closed: porcelain: table
[#087] 2012-03-15 @closed: tanman: remote: list
[#086] 2012-03-14 @closed: porcelain: meta attrib modules
[#085] 2012-03-14 @closed: tanman: correct event handling so tan can detect errors
[#084] 2012-03-14 @closed: integrate all stable into porcelain stable
[#083] 2012-03-14 @closed: attrib-definer: new home
[#082] 2012-03-14 @closed: code-molester: improve section handling
[#081] 2012-03-14 @closed: code-molester: integrate
[#080] 2012-03-13 @closed: gsu: fix
[#079] 2012-03-10 @closed: porcelain: bleeding namespaces
[#078] 2012-03-09 @closed: porcelain: bleeding (usable)
[#077] 2012-03-08 @closed: asib: put
[#076] 2012-03-02 @closed: porcelain: simply and reveal tree rendering
[#075] 2012-02-16 @closed: porcelain: aliases, descs for namesp, acts
[#074] 2012-02-26 @closed: porcelain: get tree into stable from 026 branch
[#072] 2012-02-26 #historic: borrow
[#071] 2012-02-26 #historic: fsm: passes with some specs
[#070] 2012-02-25 @closed: face cli: compat back / fwds with porcelain
[#069] 2012-02-25 @closed: porcelain: compat w/ face cli
[#068] 2012-02-24 @closed: porcelain: without syntax uses method sig
[#067] 2012-02-20 @closed: emitter can emit arbitrary number of arguments
[#066] 2012-02-18 @closed: porcelain: namespace native and compat
[#065] 2012-02-18 @closed: porcelain: default args
[#064] 2012-02-18 @closed: we must deep copy tag cloud!
[#063] 2012-02-18 @closed gsu: fix it to use new porcelain
[#062] 2012-02-18 @closed [cb]: touch events
[#061] 2012-02-18 @closed [cb]: fix issue with deep trees
[#060] 2012-02-18 @closed tmx: merge issues
[#058] 2012-02-18 @closed muxer: rename things
[#057] 2012-02-18 @closed porcelain: events
[#054] 2012-02-17 @closed code molester: make values accessor
[#053] 2012-02-14 @closed code molester: pure refactor: deepening
[#052] 2012-02-11 @closed code molester: for fun write a config parser
[#051] 2012-02-11 @closed set program name explicitly, streams
[#050] 2012-02-11 issue: change implementation of search to take lambdas
[#049] 2012-02-11 @closed add "bleed" feature @closed:2012-06-08 haha
[#047] 2012-02-07 @closed all: mark all closed issues as closed
[#045] 2012-02-07 @closed all: get *all* tests green, modifying scripts if necessary
[#044] 2012-02-07 @closed issue: add issue show
[#043] 2012-02-06 @closed porcelain tree: common base path
[#042] 2012-02-06 @closed cov: add --rerun
[#041] 2012-02-24 @closed muxer: custom event classes
[#040] 2012-02-04 @closed porcelain: actions have descriptions
[#038] 2012-02-04 @closed add script to show fake ticket numbers
[#037] 2012-01-31 @closed move tree renderer to porcelain
[#036] 2012-01-31 @closed experimental compat between face & porcelain
[#035] 2012-01-30 @closed cleanup and refactor of tests
[#034] 2012-01-27 @closed child classes can override properities from meta-parents
[#033] 2012-01-27 @closed SPEC tarball-to add Guard related things
[#032] 2012-01-25 @closed SPEC move-to and refactor
[#031] 2012-01-24 @closed Porcelain::TiteColor (we use it everywhere)
[#030] 2012-01-24 @closed SPEC version-from task
[#029] 2012-01-22 @closed static file server, BUILD_DIR, things like this
[#028] 2012-01-06 @closed add show --patch feature
[#027] 2011-01-04 @closed work on coverage
[#026] 2011-12-27 MUXER, simplecov, hellof shits
[#025] 2011-11-22 @closed added little -d option
[#024] 2011-11-10 @closed fun little kurse cusrses progress bar thing
[#023]       #track #universal the "dup and mutate" pattern: achieve an effect
             akin to the "curry" operation on a proc, but with an object
             that is treated as an actor; by duping the object and
             modifying the dup (which in turn can be duped and modified
             again and so on.)
             (see also [#003] which spawned off of this..)
             ( #was: 2011-11-22 @closed hacking dependency to let it get uglier )
[#022] 2011-11-01 @closed ascii tree viewing utility like we've written like 5 times before
[#021] 2011-10-30 @closed build more dry run into config make make install
[#020] 2011-10-29 @closed various small fixes and improvements
[#019] 2011-10-28 @closed added --all option to git-push
[#018] 2011-10-26 @closed add xpdf installer (xpdftotext)
[#017] 2011-10-25 @closed rbenv (ruby) installation shell scripts (BOOTSTRAP TMX)
[#016] 2011-09-27 @closed add cool nginx installer task and support
[#015] 2011-10-29 @closed add task to install php from source
[#014] 2011-09-20 @closed git-push-all takes host argument now
[#013] 2011-09-20 @closed some git push all refactors or something
[#012] 2011-09-20 @closed rename git-push-all tmx-push or something
[#011] 2011-09-15 @closed build out some tests for dependency
[#010] 2011-09-11 @closed start to get dependency out of face
[#009] 2011-09-09 @closed attribute definer is (re)born. derking around w/ dep.
[#006] 2011-08-28 @closed aliases have namespaces too
[#005] 2011-08-27 @closed death to old filemetrics
[#004] 2011-08-24 @closed the birth of dependency graph, Open2 wrapper for face

[#003]       spawned off of [#023], if you have a lower-level object
             (a "performer") that needs to read more than one or two
             parameters from the higher-level object (the "client"),
             this hack can save lines of code while sacrificing
             idiomacy ("clarity") - make a plain old dup of the
             higher-level object, and send `extend` to that dup with a
             module (the would-be perfomer class). now use the dup
             as you would any ordinary performer.

             this couples the performer entirely to that subset of those
             ivars in the client (in both constituency and name) so
             always keep such a hack in the same file, and use it only
             for small performers.

              ( #was: 2011-08-23 @closed filemetrics ignores blank lines, comments )

[#002]        "now.dot" (salvaged from [hl])
              ( #was: 2011-08-20 @closed F-ace craps near namespaces )
[#001]        universe dependency visualizations
              ( #was: 2011-08-17 @closed filemetrics rearchitecting )
[#000] 2011-08-13 @closed filemetrics refactor near linecount feature
