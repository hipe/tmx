
# the CLI box DSL narrative :[#129]


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


:#storypoint-2

this is some gymnastics: the implementation method is not defined in the
action class but in the semantic container class.



:#storypoint-6

the bread and butter of this module is the following methods that simply
dispatch the method calls to a terminal action class being built.



:#storypoint-8 (method)

the essence of this module is this 'method_added' hook



:#storypoint-7 (several methods)

what you're looking at here is one big narrative block that makes both
the terminal action class and the box module to hold the actions.
this storyblock ends when the surrounding block ends.




:#storypoint-3 (method)

if the arg is anything other than just a proc, we propagate it to the
class we are building (imagine it is a single string of description, for
e.g).

when a block is provided the handling is complex: evaluate the desc proc
in the context of the parent object, b.c that is where you would have defiend
helpers (also, it won't do it now, it will do it later, which is good because
the block might access helpers that need metadata about the action,
which isn't complete yet! hence hacks to check against collapsed stae).



:#storypoint-96 (method)

#hybridized. our invocation string is dynamic based on whether we have yet
mutated or not.



:#storypoint-5

this is an experimental way to get through to the box class itself, because
otherwise we can't use some DSL methods on the box class itself because
they have been re-assigned to write to the child class we build.



:#storypoint-50

these two are "hard aliases" and not "soft" ones so if you need to
customize how the o.p is created you have to override them individually.
this is for a box creating its child leaf o.p



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

'hot' is a local idoiom that means "live action". we hate this method.
note we need to put the method name of the particular action on the queue.



:#storypoint-60

undoes the collapsation. oh lord k.i.w.f. this is called from children
corroborating with us in our crimes.



:#storypoint-80

#hook-ins to facilities to customize them. in render order then call order.


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
