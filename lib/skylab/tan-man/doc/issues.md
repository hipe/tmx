[#075]       #tracking-tag of hiccup skip Actions module ANCHOR_BOX_MODULE
[#074]       #doc-point numerics in sexps #sexp-auto
[#073]       #done rename 'examples' to 'starters'
[#072]       #done when returning false, use the terminal action node
[#071]       #tracking-tag: shift from the `prototypes` paradigm to the 'meh'
[#070]       #tracking-tag `create` flag as a triad: false, nil, trueish
[#069]       #tracking-tag fuzzy-finging regexen - case insensitive?
[#068]       #done dot file controller is becoming a god object, also redesign
             the way it executes "tell"s, so it's not as much an action
             obj
[#067]       #tracking-tag lexical stuff ..
[#066]       #done issue with adding a new node on an empty graph,
             new nodes should always come after `node` node
[#065]       #done fuzzy manage dependency
[#064]       ui and impl for destory node
[#063]       #done the --force that rewrites parsers should be different than ..
[#062]      #later meaning reports!!!!
[#061]       #done shallow shortcut to `tell` ?
[#060]       #done #refactor: *all* NLP actions should go thru API duh
[#059]       #done places where you could prettify custom action invites
[#058]       #done get abs paths out of conf file, make them rel to the file
[#057]       #done DONE DONE DONE DONE DONE DONE DONE DONE meanings
             2. forgetting them (specs & nlp)
             3. applying them
[#056]       #tracking-tag: can we use tan-man to guide refactorings yet?
               #waiting-on:(#014, #015)
[#055]       wtf
[#054]       #watching it seems like it will probably be dangerous to
             reuse the same parser for multiple parses?, also #tracking-tag
[#053]       #postponed normalizing string here
[#052]       #postponed normalizing double quoted strings
[#051]       #postponed support for 'port' in dot-lang grammar
[#050]       #done just for fun, eliminate all return statements
[#049]       #watch #pattern - four permutations for file creation (dirname etc)
[#048]       #done failing on tan init should do porcelain too
[#048] #watch what is the deal with the non-orthogonal-ass event interface for remote list
[#047] #watch where to specify local/global, or merge?
[#046]       #trend away from Parameter::Definer etc. and towards lamba args
[#045]       #postponed Parameter::Definer (up?), vs Attribute::Definer
[#044]       #branch-down cli tests (but issue wip)
[#043]       #tracking-tag other guys that could benefit from svc
[#042]       #done FileUtils as a service (JSON)
[#041] #watch i don't like how status is implemented with the arrays
[#040]       #done make your own SubClient::InstanceMethods to DRY CLI & API
[#039]       #done API::Whatever becomes MetaHell::Generic
[#038]       #done text_styler away!
[#037]       #done reconceive stdout, stderr -> infostream, paystream, errstream
               .. (i.e. ("PIE" [#sl-113])
[#036]       #done format_error -> inflect_failure_reason (and tests!)
[#035]       #wont delegates_to go away as a smell (meh)
[#034]       #done sort out root_runtime, client, parent_runtime, etc
[#033]       #done full_action_name_parts becomes normalized_name (action_name ..?)
[#032]       #done rename stdout, stderr
[#031]       #done regretify all tests
[#030]       #done reconceive api as a service
[#029]       #done no more api knob (api.invoke -> api_invoke)
[#028]       #bad-ticket any and all changes to CLI core client
[#027]       overhaul to cli actions base class
[#026]       #done API::InvocationMethods away!
[#025]       API::RuntimeExtensions away! #done
[#024]       #done use -h -- we had to etc use bleeding
[#023]       #deferred combine all Boxxy, consider Boxxy-like solutions
               #depends-on:#018
[#022] #open refactor-in headless, and sub-client
[#021]       merge singletons into service
[#020]       #done #low-priority nounify cli commands
               x. check -> graph check
               x. push -> graph push
               x. use -> graph use
               x. tell -> graph tell
[#019]       #done "magic" for DRYING up tests (Regret) #done
[#018]       #deferred #depends-on:#sl-100 refactor out porcelain ["bleeding"]
               we are gonna hinge this on to treemap for no real reason
               except the *huge* tangent stack we are under
[#017]       #pattern: for to maybe push up to headless
[#016]       #done #pattern: action instance spawns instance of model controller
               .. so make `controllers` knob for clarity
[#015]       #done UI for dissociate (and prune nodes? - no, out of scope)
[#014]       #done UI for associate (labeled "depends on")
[#013]       #DONE UI for chose example, then use example
              1. unify & modernify autoloading
              2. fix api vis-a-vis actions to integrate with autoloading
[#012]       #done 2012-11-01 refactor UI / NLP to use Sexp::Auto
[#011]       make sure complex prototypes can be used with nonzero length lists
[#010]       #done 2012-10-27 associate two nodes
               1. sic, 2. redudantly, 3. agent not exist 4. target not exist
[#009]       #done 2012-10-27 create a node
               1. with one template (3 permutations) 2. with another template (3 permutes)
[#008]       #done 2012-10-10 #rename rename "nt" to "expression" / "rule"
[#007]       #done #small #critical models/ dir generated during specs 2012-09-29
[#006]       #open #one-day look into reflection via metagrammer instead 2012-09-27
[#005]       #open #one-day look into "statement oriented" processing 2012-09-02
[#004]       #open #one-day #one-day look into multibyte regexp 2012-09-02
[#003]       #open #one-day unshield your eyes : google "dotfile grammar" 2012-09-01
[#002]       #done 2012-08-30 rename remote* to fit a pattern (e.g. controller)
               examples-controller -> example-collection
[#001]       #done tan -w ok, #depends-on:(#sl-unwip)
