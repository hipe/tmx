[#099] #open double-writing with a tmpfile

[#098] #open abstract file-locking work out to the byte stream references

[#097] #hole
             ( #was: abstract tons of this work for the new workspace (may be "finished") )

[#096] #open no more [br]

[#095] #open tests marked #too-big

[#094] #open become insensitive to newlines when referencing nodes

[#093]       #done cleanup `__dupe` interface and implementation
[#092]       #done #list-API unmunge `_insert_item_before_item` et. a.
[#091]       #done #list-API improve the implementation of \`unparse\`
[#090]       #done make association magnetic
[#089]       #done [br] collection / file-based [ file etc ] <= [ttt]
[#088]       #done same issue as below with graph use
[#087]       #done setting a starter doesn't remove the last one

[#086] #open on first test run with an empty "[tmx root]/tmp/", the
             event of creating the tmpdir breaks the comprehensive test run
             (tricky because the test that is the first to build the
             grammar files varies based on "how" we're running the tests..)

             the solution is probably to produce a memoized, frozen hash
             as our `ignore_emissions_whose_terminal_channel_is_in_this_hash`
             that is used for *every* emission tested that ..

             there's a script in [sy] tagged with this ID to help with this.

             (on a separate but related note, `created` is a bad terminal
              channel name. please append a noun to this channel name.)

[#085]       #done #list-API make methods conform to [#bs-029.5]
[#084]       #parent-node: [#024] of node ..
[#083]       #doc-node kernel
[#082]       #parent-node: [#083] the kernel properties narrative ..
[#081]       config shell (lost). part of [#fi-001]
[#078]       #tracking-tag this spot with `const_set`
[#077]       #done services.rb wat
[#076]       [ meaning graph ]  (comments inline)
             ( #was: events need to be modernized )
[#075]       #tracking-tag of hiccup skip Actions module `ANCHOR_BOX_MODULE`
[#074]       #doc-point numerics in sexps #sexp-auto
[#073]       #done rename 'examples' to 'starters'
[#072]       #done when returning false, use the terminal action node
[#071]       #tracking-tag: shift from the `prototypes` paradigm to the 'meh'
[#070]       #tracking-tag `create` flag as a triad: false, nil, trueish

[#069] #open wish for tabular format more compatible with toggl (start stop)
             ( #was: whether or not to be case insensitive when resolving
              nodes, etc. now this is an option in the supporting actor, and
              changing it would be trivial..)

[#068]       #done dot file controller is becoming a god object, also redesign
             the way it executes "tell"s, so it's not as much an action
             obj

[#067] #open CLI is borked for a typical use-case. needs better coverage
             and fixing. (try: `init`, `hear "a depends on b"`) this
             occurred in part because of gaping holes in coverage near
             the higher-level concerns, like creating directories for 'init'.
             ( #was: #tracking-tag lexical ordering stuff, #moved-to [#ba-045] )

[#066]       #done issue with adding a new node on an empty graph,
             new nodes should always come after `node` node
[#065]       #done fuzzy manage dependency
[#064]       ui and impl for destory node
[#063]       #done the --force that rewrites parsers should be different than ..
[#062]      #later meaning reports!!!!
[#061]       #done shallow shortcut to `tell` ?
[#060]       #done #refactor: *all* NLP actions should go thru API duh

[#059]       the algorithm for resolving a prototype document element
             ( #was: restore invites )
             ( #was: #done places where you could prettify custom action invites )

[#058]       #done get abs paths out of conf file, make them rel to the file
[#057]       #done DONE DONE DONE DONE DONE DONE DONE DONE meanings
             2. forgetting them (specs & nlp)
             3. applying them
[#056]       #tracking-tag: can we use tan-man to guide refactorings yet?
               #waiting-on:(#014, #015)

[#055] #open #feature meaning delete

[#054]       #watching it seems like it will probably be dangerous to
             reuse the same parser for multiple parses?, also #tracking-tag
[#053]       #postponed normalizing string here
[#052]       #postponed normalizing double quoted strings
[#051]       #postponed support for 'port' in dot-lang grammar
[#050]       #done just for fun, eliminate all return statements

[#049]       #watch #pattern - four permutations for file creation (dirname etc) (1x)

[#048]       ( #was: #done failing on tan init should do porcelain too )
             ( #was: #watch what is the deal with the non-orthogonal-ass
              event interface for remote list )
[#047]       #done #watch where to specify local/global, or merge?
[#046]       #trend away from Parameter::Definer etc. and towards lamba args
[#045]       #postponed Parameter::Definer (up?), vs Attribute::Definer
[#044]       #branch-down cli tests (but issue wip)
[#043]       #tracking-tag other guys that could benefit from svc
[#042]       #done FileUtils as a service (JSON)

[#041] #open #feature workspace status is furloughed

[#040]       #done make your own SubClient::InstanceMethods to DRY CLI & API
[#039]       #done API::Whatever becomes [m-h] generic
[#038]       #done `text_styler` away!
[#037]       #feature stdout as an `output_stream`
             ( #was: #done reconceive stdout, s-tderr -> infostream, paystream, errstream
               .. (i.e. "PIE" [#sl-113]) )
[#036]       #done `format_error` -> `inflect_failure_reason` (and tests!)
[#035]       #wont `delegates_to` go away as a smell (meh)
[#034]       #done sort out `root_runtime`, client, `parent_runtime`, etc
[#033]       #done `full_action_name_parts` becomes `local_normal_name` (`action_name` ..?)

[#032] #open refactor to use [#br-011] `@_associations_` instead of our own hand-rolled
             [#here.2] - as marked in [br]
             #done rename stdout, s-tderr

[#031]       when this is *set* (literally set, as in to anything), this
             indicates that the action will want to access its defined
             parameters after it begins execution. (many actions don't
             need to reflect on their formal parameters once they have
             begun execution; but in this application many do, because
             reasons.

             ( #was: #done regretify all tests )

[#030]       [ hear ]
             ( #was: #done reconceive api as a service )

[#029]       track classes for entities not yet associated with documents? ..
             ( #was: #done no more api knob (api.invoke -> `api_invoke`))

[#028]       #bad-reference any and all changes to CLI core client
[#027]       overhaul to cli actions base class

[#026]       resolving IO through parameter modeling ..
             ( #was: #done API::InvocationMethods away! )

[#025] #open get rid of convoluted parser enhance
             ( #DONE ancient legacy [ttt] mess-lette )
             ( #was: API::RuntimeExtensions away! #done )
[#024]       [ model ] and #doc-node: the model experiments narrative ..
             ( #was: #done use -h -- we had to etc use bleeding )
[#023]       #deferred combine all Boxxy, consider Boxxy-like solutions
               #depends-on:#018

[#022] #open-ish - this just here to mark this tombstone related to dash
             for input
             #tombstone - something to do with dashes for stdin for input
             weirdly in the "hear" silo
             ( #was: #done end client defaulting patterns (workspace etc) )
             ( #was: workspace directories )
             ( #was: refactor-in headless, and sub-client )

[#021]       the digraph session architecture ..
             ( #was: #done merge singletons into service )

[#020] #open #feature-collection upstream
             ( #was: #done #low-priority nounify cli commands
               x. check -> graph check
               x. push -> graph push
               x. use -> graph use
               x. tell -> graph tell )

[#019] #open where is my optional term going?

             ( was: #done "magic" for DRYING up tests (Regret) #done )
[#018]       #deferred #depends-on:#sl-100 refactor out porcelain ["bleeding"]
               we are gonna hinge this on to treemap for no real reason
               except the *huge* tangent stack we are under
[#017]       #pattern: for to maybe push up to headless
[#016]       [ nascent - see commit ]
             ( #was: #done #pattern: action instance spawns instance of model controller
               .. so make `controllers` knob for clarity )

[#015] #open #feature remove association between nodes (see)
             ( #was: #done UI for dissociate (and prune nodes? - no, out of scope) )

[#014]       unified language ..
             ( #was: #done UI for associate (labeled "depends on") )

[#013]       #track why symlinks (once here, once outside)
             ( #was: unused files )
             ( #was: #DONE UI for chose example, then use example
              1. unify & modernify autoloading
              2. fix api vis-a-vis actions to integrate with autoloading )

[#012] #open #feature common collection controller - ambiguity method not implemented
             ( #was: #done 2012-11-01 refactor UI / NLP to use sexp auto

[#011]       #parent-node: [#010] the peek module name hack narrative ..
             ( #was: make sure complex prototypes can be used with nonzero length lists )
[#010]       [ the treetop input adapter ]
             ( #was: #done 2012-10-27 associate two nodes
               1. sic, 2. redudantly, 3. agent not exist 4. target not exist )

[#009]       document controller notes ..

       #open? :[#here.3]: #feature square word wrap (target an aspect ratio)

             ( #was: #done 2012-10-27 create a node
               1. with one template (3 permutations) 2. with another template (3 permutes) )

[#008]       the treetop load DSL narrative ..
             ( #was: #done 2012-10-10 #rename rename "nt" to "expression" / "rule" )

[#007]       small internal tracking

       #wish :[#here.D]: double-writing to tmpfile for dotfiles (like [sg] does)

             :[#here.C]: what we're calling "sub-invocations"

             :[#here.B]: #watch track all non-primitive values still used in
             our trans-modality API (old)

             ( #was: #done #small #critical models/ dir generated during specs 2012-09-29 )

[#006]       meta property reference (.rb!)
             ( #was: #one-day look into reflection via metagrammer instead 2012-09-27 )
[#005]       #open #one-day look into "statement oriented" processing 2012-09-02
[#004]       #open #one-day look into multibyte regexp 2012-09-02
[#003]       #open #one-day unshield your eyes : google "dotfile grammar" 2012-09-01

[#002] #open implement ambiguity expressor for 'st[atus]' and 'st[arter]'
             ( #was: #done 2012-08-30 rename `remote*` to fit a pattern (e.g. controller )
               examples-controller -> example-collection)

[#001]       [ readme ]
             ( #was: refactor out the repetition among document entity actions:
             resolve one layer where all collection persists happen (i.e
             should collection controllers write files or should actions?) )
             ( #was: #done tan -w ok, #depends-on:(#sl-unwip) )
