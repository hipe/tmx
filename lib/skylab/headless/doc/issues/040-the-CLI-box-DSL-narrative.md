# the CLI box DSL narrative :[#040]

:#storypoint-88

welcome to the CLI box DSL. familiarity will be assumed with any concepts
presented in any [#137] CLI box narrative.

the "never say never" rubric has lived at the head of this file for more than
a year now because when we started this node, we liked the idea that it would
be the last ever ground-up rewrite of such a thing, but we knew that to
entertain such a notion was just wishful thinking.

in the context of our "client tree" model, a component called "box" is
concerned with managing children nodes in terms of operations like rendering
the collection to screen, dispatching requests by resolving a particular one,
and handing when one such child cannot be resolved (in terms of actuaing UI
behavior).

as for the "DSL" part such a box, the essential concept behind this is
twofold: one, we will expose an API of private "class methods" that are
used to define each particular child node at this level. two (and most
essentially), the central thesis statement of this experiment is: "can a
clean isomorphicism be drawn between the public methods of a particular
class and its collection of supported "commands"?". this remains a space
of active inquiry in this universe.

to get pseudo-formal for a second, the grammar ends up looking something
like:

    class Foo
      Headless::CLI::Box[ self, :DSL ]  # EXAMPLE - not yet implemetned #todo

      NODE_DEFINITION *

      NODE_DEFINITON : NODE_MODIFIER * COMMAND

      COMMAND: ( a public method definition )
    end

the above is to say, a DSL-enhanced box class contains zero or more node
definitions. a node defintion is be zero or more node modifiers followed
by one command. a command is (simply) a public method definition.

so note that by this defintion, the empty class by itself is still a valid
box node, as is one with only one public method definition..



:#storypoint-77

(this point may be simply an improved restatement of the issue behind
#storypoint-1, which is legacy and needs review after this the close
of this broad topic #todo:before-merge).

when it comes to wiring a class for autoloading from within the `[]` enhancer
implementation such we are, the most "straightforward" way this typically
accomplished is to call caller_locations( 1, 1 ) within this first callframe,
and pass ourselves with that location object to someone like MetaHell::MAARS[].

(the core function of the autoloader is to turn missing constants into
pathnames using this location structure as the 'dir_pathname' to infer paths
for constants).

when this works, it works because the assumption is made that wherever the
`[]` call was made, that line of code lives in the file that is the
"home" path for that node (and in fact we allow some flexibiilty here:
the module in question may even call this method from a parent node (that
is, as a '#stowaway') and the autoloader will attempt to infer the correct
path still).

in the case of the node seeking to employ this "box DSL" enhancement,
[#todo:befor-merge this actually belongs in the outstream]



:#storypoint-1

this deserves some explanation: we use Boxxy on our action box module
because that was exactly what it was designed for: to be an unobtrusive
hack for painless retrieval and collection management for constituent
modules. now the point of this whole nerk here is to _create_ such a
box module and, *as the file is being loaded*, blit it with classes
that are generated dynamically to model all of your actions from
methods as they are defined. that's the essence of why we are here.

while some actions (e.g. clients) may not need an autoloader, if
there's any chance they do it must be wired properly, and that is
convenient do below when the modules are created rather than at some
later point (e.g after the file is done loading, as recursive a.l does)

BUT it is also nice to be able to extend a *base (action) class* with
this DSL extension and have it work in *child* classes. While we could
do some awful hacking to make the autoload hack work for subclasses
as they appear in other files .. just no.

All of this is to say: 1) that is why we include a.l above, and
2) this is why we have some conditional nerking around below, to charge
the module graph with autoloading only if it has signed on for it.

(btw you would do that via either extending a.l explicitly on your class
*before* you extend this .. *and* i think the client DSL will do it
for you too if that fits your app.)



:#storypoint-6

the bread and butter of this module is the following methods that simply
dispatch the method calls to a terminal action class being built.



:#storypoint-3 (method)

if the arg is anything other than just a proc, we propagate it to the
class we are building (imagine it is a single string of description, for
e.g).

when a block is provided the handling is complex: evaluate the desc proc
in the context of the parent object, b.c that is where you would have defiend
helpers (also, it won't do it now, it will do it later, which is good because
the block might access helpers that need metadata about the action,
which isn't complete yet! hence hacks to check against collapsed stae).



:#storypoint-8 (method)

the essence of this module is this 'method_added' hook



:#storypoint-7 (several methods)

what you're looking at here is one big narrative block that makes both
the terminal action class and the box module to hold the actions.
this storyblock ends when the surrounding block ends.



:#storypoint-2

this is some gymnastics: the implementation method is not defined in the
action class but in the semantic container class.



:#storypoint-5

this is an experimental way to get through to the box class itself, because
otherwise we can't use some DSL methods on the box class itself because
they have been re-assigned to write to the child class we build.



:#storypoint-94

this is the core of this whole dsl hack. because we are DSL we override
Box's straightforward implementation with these shenanigans (compare!)
this method is the entrypoint for the collection of methods in this
file that rewrite box i.m's `action` and `args` (the names)



:#storypoint-95 #todo this is going away

an ancestor module may hold that it is always a leaf per its definition of
"is leaf". we override this to define it as a simple attr reader. this means
that out of the box, (since this ivar starts out at nil) we are not a leaf,
hence a branch.

we allow this property to be hackisly mutable, which serves as our outward
representation about whether we are to be considered as a leaf or a branch
at that time (because if we are collapsed, we assume the same value for
the same property of the child we collaapse to.) for better or worse this
is how it works.



:#storypoint-96 (method)

we hate this method. the particular surface form for our invocation invocation
string is dynamic based on whether we have yet mutated or not. this is awful.
'hot' is a local idoiom that means "live action". note we need to put the
method name of the particular action on the queue.



:#storypoint-60

undoes the collapsation. oh lord k.i.w.f. this is called from children
corroborating with us in our crimes.



:#storypoint-80

#hook-ins to facilities to customize them. in render order then call order.



:#storypoint-50

these two are "hard aliases" and not "soft" ones so if you need to
customize how the o.p is created you have to override them individually.
this is for a box creating its child leaf o.p



:#storypoint-98 the worst thing ever. (permanntly tracked in file with #jump-2)

check this awfulness out: when we build our desc lines we call for the
`summary_line` of each (visible) child. the summary line of each child, in
turn, may call *its* `desc_lines` which in turn calls *its* version of this
method, which in turns causes this object to "collapse" around the child..
When all this whootenany is done, we have to make sure to uncollapse so that
we don't report child parts as our own. this is the worst thing everl.



:#storypoint-99

fragile and tricky: you are e.g. the root modality client. you received an
invoke ['foo', '-h'] which then called dipatch, who then enqueued the method
name :foo.  Since we don't actually use the method to process help (for that
is what we are now doing, we 1) remove that method from the queue and then
2) add our block to the queue that processes the help.



:#storypoint-100

This is the DSL so we've gotta provide a `bop` implementation -- there is a
delicate, fragile dance that happens below because we want to be able to
leverage instance methods defined in the parent and have this work both as a
documentng and parsing pass.



:#storypoint-101

method visibiliy does not API visibility equal. this is a public method that
is API-private. because we only ever call it directly from this same node
(file), we give it an intentionally ugly name to make refactoring easier and
discourage its use otherwise (without renaming it.)

understand that there are two agents: there is the child "hot action" and
the parent "hot action". the child is expected to build an option parser,
but when that option parser parses options, it's got to write them into
to the parent. that is why there is a lot of context switching here.
