# the CLI action narrative :[#065]

(#parent-node: [#126] CLI component narratives)

## :#storypoint-5 introduction to the instance methods module

welcome to the CLI action core instance methods module. what you are looking
is at present the longest narrative in this universe (that is, skylab).


### the criteria for this node

the criteria for this node is that everything that exists in this file
must exist to support "normal" execution of a CLI action node (for some
definition of normal). for any supra-normal behavior it is recommended
that we consider something like bundles or dynamically loaded facets/
extensions/agents as apprpriate.



## :#storypoint-15 the queue

the value that the queue ivar points to will be used to represent and then
produce the sequence of tasks to be executed by this action. there is now
a [#143] full esssay about this facility.



## :#storypoint-15 (method)

some clients will use the @argv ivar, some won't.

in the call to the option parsing method we pass the 'argv' as an argument
so that clients can play dumb and not use the ivar (it may be more readable
for small applications to use params rather than the ivars).

we check for 'OK__' a lot per [#019] the common triad of result values,
and later we will hook-out to support [#023] proper exit statii (this gets
hit in #storypoint-705 below).

here we implement a public API point of behavior: having resolved zero or more
tasks (actually a scanner that produces them one at a time, possibly in a non-
deterministic manner), each next task is executed and if its result is
anything other than "OK" (true) per the [#019] triad, we short-circuit out of
further processing of tasks and our result is this result. always the result
is the result of the last task executed, or nil if no tasks were produced by
the task scanner.

a corollary of this is that it is impossible to execute multiple tasks more
than one of whom produces an "interesting" result (for example, some arbitrary
business-specific exit status). the only way to have an "interesting" result
and execute more than one task is if all the previous tasks result in "OK".
this is by design because although we want to be able to support the execution
of multiple tasks, ultimately we want to have only one result (you cannot,
after all, exit your process with more than one exit status).

a less evident objective we have optimized for is that once we get to the
point of executing your business method, we want you sitting on top of [#032]
as few stack frames as possible placed by this framework. this is why the task
scanner's elements are executed within the entrypoint invocation method (and
in fact why we created the idea of a task scanner in the first place).



## :#storypoint-20

on this line or at a line right below it we add a constant, but note we do
not add that constant "here" in the current module but rather we add it to
the module that contains this one. you will see this happen several times in
this file. the reason we do this is this:

we frequently make small, ad-hoc helper classes (e.g the class that is
created near this storypoint marker), or just constants. always we strive to
place these in-line with the narrative, typically somewhere near (within one
"screen") after their first use.

this narrative pattern is frequent throughout this universe, whereby typically
we define such small-ish constants immediately after the relevant method(s)
they first appear, and in the same module at that. this pattern is prominent
throughout this library but it is especially gaining traction recently.

but here in this component it has special needs that our narrative pattern
must accomodate:

the way ruby ancestor chains works, if you included a module to "get" its
instance methods in your ancestor chain, you also "get" any constants it
holds as well, whether or not you want them. typically this occurrs to us
without us needing to know about it, but in this case of this component
it may have impact.

in the case of this component it may be that it is a [#035] sensitive,
"cordoned-off" "box"-type module that cannot have constants added to it
without breaking things (specifically all constants in such modules must
represent some business entity, typically, e.g "actions").

hence we create new constants one level up rather than "here" in our module,
which allows us to avoid accidentally "polluting" the client module's
namespace with any extra constants. (this is not just for aesthetics. this
problem breaks code if not accomodated correctly.)

because of how the file is lexically structured (that is, the "here" module
is lexically "inside" of its parent module in this file, as opposed to us
having said "module Foo::Bar" for the here module), we may access the constant
as a bareword even though we must define it using the '::' operartor.



## :#storypoint-25 (method)

mutate the argument (which is probably also in an ivar). what you do with the
data is your business (read: side-effects). result in true on success, other
on failure.

the CLI action core instance methods do not themselves build an option parser
for you by default, because what grammar should they use to parse? to create
an o.p automatically that serves no other function but to render a help screen
and otherwise complains about unrecognized options; this is seen to be an
anti-feature at this level. (however if you want something like this, you can
define it in only a few lines with the DSL bundle.)

at this level the way to hook into the o.p facility is to .. well .. use the
hook-in method (the "builder method") described below.

in the implementation of this method note:
  • if the argv is empty, your builder method won't even be called. this
    may impact you unexpectedly if for example you are initializing ivars in
    your option parser definition blocks (DSL).
  • if no o.p was resolved (which is the default with only this bundle active)
    any "option"-looking args in argv will get passed along unparsed to the
    downstram logic of thid node (that is, the argument facility).
    this above described behavior is part of our :#public-API.



## :#storypoint-30 ugly names

intentionally ugly names are employed by this node for certain methods, and
they have a specific semantics and scope as described in [#119] "the method
naming shibboleh". (in fact these conventions only grew stronger while re-
working this node.)



## :#storypoint-35 (method)

the autovivifier for the option parser is no longer part of our public API
hence it has been given a terse name. the client or bundle wanting to build
an option parser (arguably the most important behavior payload of the CLI
node) should do so with the builder method, a #hook-in point described
below.

we mutex-out subsequent calls to the builder method by checking for nil on
the front and "upgrading" nil to false on the back; such that the user would
have to set the ivar back to nil again to try and trigger a fresh attempt
at a build. this mechanic is referred to as a :#mutable-build-mutex.



## :#storypoint-40 (method)

this hook-in is part of our #public-API, and can result in any arbitrary
result (including false or nil), but if the result is true-ish (presumably
because you want that thing to parse options for you), it must conform to
at least these following interface points, which are a subset of the public
methods of the ruby stdlib ::OptionParser (::O_P):

  • your o.p must respond to a `parse!` that takes 1 array-shaped arg as
    ::O_P does.
    • (in addition, this method may accept a block argument, and if it does
      it will be used to support #dark-hacks that we don't cover here, but
      suffice it to say when you yield to our proc you must pass the right
      shape and arity in.)
  • on parse failures your o.p must raise a stdlib o.p::ParseError as
    ::O_P does. we hate that this is how stdlib o.p works, but it is and our
    primary requirement is to be based around total compatability with the
    stdlib o.p (because in practice it is almost always a stdlib o.p that
    we are using).
  • your o.p must respond to a `visit` that works like stdlib o.p
    • each would-be switch that this method yields must have a `long`, `short`
      and `arg` that look like the equivalent o.p methods. again this only
      relevant for deep, dark hacks.



## :#storypoint-50 (method)

part of our public API, this hook-in is a mid-level entrypoint for this
common form of interface screen, called by the invocation logic or other
operations that want to make a graceful "exit" (but see #storypoint-15 for
an intimation at why we don't actually exit).

any trueish first argument will get its own leading first line in the output.
any trueish second argument gets appended to the first invite line.

if there is a result value indicated at the end here it is because it is
a popular choice. you as the caller should result in whatever is appropriate
for what you are doinng if it is not this value.



## :#storypoint-55 (method)

few patterns have gained so much popularity so quickly in our libraries as
this one. what we are often doing in a CLI is simply just emitting lines of
output somewhere. when the lines are UI-oriented and not payload-oriented we
often want to output them to some kind of stderr stream, but perhaps they are
going to any arbitrary stream, like a logfile. the point is it is not our
business to know.

sticking to the emitter interface and sending output lines to a receiver
using solely `<<` allows us to employ the same interface regardles of whether
that upstream object wraps direct line output to some stream, or perhaps it
is just caching the output to an array for furter processing (in which case,
the array itself responds to `<<` so is suitable to be passed in as the `y`
term in such circumstances).

for such methods, the callee need not (and can not) know anything other than
that lines get written to `y` with `<<`. this abstraction has proven to be
tremendously useful so you will see it everywhere; even outside of this
library.

the benefits of this pattern far outweigh the cost of needing to pass
this parameter in frequently as the first argument (something that [#sl-129]
Martin might take issue with).

this way, the rendering agent need not hold state information about the
output context, which makes this more efficient and less ugly when we
accumulatin output from many children objects in a [#010] tree traversal,
for example.

(note though that if a method is guaranted to result in one line (and
all such methods must have a name ending in a derivative of the word "line");
then this method's signature will not employ this mechanism because it reads
much more nicely without it and is a bit more flexible; not requiring the
caller to first resolve a yielder in order to get information back from the
method.)



## :#storypoint-65 the emitter methods

this section will be in flux, is a point of some experimentation, is one of
the main forces behind this current overhaul, and is the focus of one section
of [#028] the stratified event production model.

specifically we don't know if at the production level of our own events (and
here in CLI all of our events are strings right from the start, at least those
that an action emits itself), we don't know whether or not we want to
differentiate semantically (or "variegate") e.g 'help' from 'info' from error.
for now we err on this side, because it's easy to make this behave the other
way, but the reverse is not true.

and in fact, the 'info' suite of methods would only exist as service methods
(that is, part of our public API), since we would never ourselves emit 'info',
only 'help' or 'error'. this is likewise true of any 'payload' suite we might
build into this. in fact this might be smell to even be considering, because
while support for variegated, semantic event 'channels' is an auxilliary facet
that this library should support, offering specific channel-suites as a
"service" is a bit of a smell. this is something for bundles to look at,
#after-merge.

another point to mention here is that we unabashedly do this thing with
throwing procs around because it gets it used to the idea of thinking of
things like this as true services that can get thown around (like first order
functions). this is one huge shift from the sub-client pattern, wherein we
passed the same args up and up and up through the graph, instead of this
which passed the service (proc) down.

why this is better is because it allows the agent at the beginning of its
lifecycle to resolve all of the services it might need (#todo:during-merge
this is what 'schlurp' is for), to catch incompatabilites earlier. and it is
likely more efficient for any service methods that get called repeatedly,
traversing the graph just once per hot agent, rather than once per method
call.



## :#storypoint-90 (method)

this private method is part of our public API: the client is certainly free
to use this method to build a usage line and then output that single string
anywhere and anytime that she sees fit. this method will deliver the same
(in terms of bytes, not memory) usage line that is used in the rendering
of the default help screens.

(terminology note: "usage" and "syntax" are used interchangably in some
contexts while in other contexts they are not. hint: there may be a
~Syntax class.)

more interestingly, this method sits squarely at a significant precipice
of this node at this point in its narrative. while looking over the lines of
this method, at one glance we can almost see the entire functional surface
area of that this node encompassess. there is:

  1. the expression agent using `say` (and even the lexicon!)
  2. the name function facility (for producing differnt kinds of names)
  3. the option facility
  3. the argument facilty

believe it or not, to cover all of these we will traverse hundreds of lines
of code. and so it bears mentioning now that we are getting to the point
where the narrative jumps will become larger than one screen and it will
become easy to get disoriented from here forwared unless we remember the
above points as our top-level taxonomy, guiding us back on course like a
constellation for an ancient seafarer omg

what's even crazier is that all of that work ends up producing just a single
line.



## :#storypoint-100

as #storypoint-435 may explain, we use #de-vowelating in a particular way.
we define an #ultra-private method, and then expose it as an #API-private
method. we are making a guarantee to the rest of the subsystem that that
method will be available by that name. but because both forms of this method
are de-vowelated, that means they are neither of them part of our public
API, and we reserve the right to change or eliminate them.



## :#storypoint-105 (method) and expresssion agents

`say` is arguably the most important method of this node. perhaps it is the
most important mechanism in the [#010] client tree model. this private method
is part of our :#public-API. we pick this dialog up in [#141] the expression
agents story, because it could get lengthy. (it does, and it has an ASCII
graphic!)



## :#storypoint-155 the lexicon.

(#experimental [#124] #i18n placeholder for now. lots of stubby sillyness
and crazy experiments for now.)



## :#storypoint-205 (method)

the default behavior from this node at this time is to derive the name from
the class, inflecting the string approrpriately.  #todo:during-merge



## :#storypoint-315 (method)

this private "hook-in" method is part of our public API. called whenever
the o.p that is needed is expressly presentational. this acts as both a
boolean value indicating if there is a documenter, and the getter for it.
having an o.p but no o.d is in theory possible but untested (if for some
reasons you had syntax that you wanted to support when parsing but not when
rendering.)

a side-benefit of this differentiation is that it lets us track the
distribution of these two separate but related scopes of responsibility
for the option parser (which are indeed not always fulfilled by the same
obejct [tr]).



## :#storypoint-320 (method)

assume o.p complete, use hack, o.p compat maybe zero length, kept flat &
functiony (#wat)



## :#storypoint-325 (method)

this method is part of our #private-API; that is, it is called elsewhere from
within this subsystem but not outside of it. this method is used to indicate
that a particular switch should not be included when rendering the syntax
string.

we maintain a hash that defaults to true that stores the object id of every
switch that is "invisible" from display; only for the purpose of omitting
common switches like for help, that don't add any real value by being
displayed in syntax strings (if you are already reading the help screen
that the help switch brought you to, for e.g).



## :#storypoint-335 (method)

this private method is a :#hook-in.

there may exist in this univers a switch that responds to `short` but both
of its `short` and `long` each result in false-ish, or the empty array,
or an array with a false-ish first element. such a switch might for example
be as special hack of a switch that is just an RX that exists to expand or
reduce the argv when it is matched. such a thing might exist. hence we check
for it here.

also (and as a separate point of concern for this method), this private
method is a "hook-in" and hence part of our public API. the client may
override this wanting to customize how all or just a subset of all switches
is rendered.



## :#storypoint-405 introduction to arg parsing

basically all we are ever doing with arg parsing at this level is verifying
that the number of arguments passed one of the set of valid numbers of
arguments supported by that particular argument syntax. (this concept is
referred to generally as 'arity' and is something we go crazy with over
in [fa] but not here, in as precise of terms).

this is something that programmers are used to dealing with all the time,
becuase it is exactly isomorphic with passing arguments to methods. (at least,
this is true for the kind of argument syntaxes implemented by this node).
this isomorphicism is one of the obsessions of this library..



## :#storypoint-410 (method)

this method is part of our :#private-API. it is not for general use outside
of this library.

for some action nodes, the question will have to be asked "what argument
syntax is "current" or "active"?. this implementation is a bit of a small
mess, so #todo:during-merge. result is is an object not a string per our
[#095] method naming conventions, but confusion will be forgiven in this case.
(there is another method naming convention at work here, one that will be
described below).



## :#storypoint-415 (method)

this private method is a part of our public API. it may be overidden
(and likely super()'d to) in the case where the argument syntax for a
particular action is some custom implementation. (no distinction is made at
this level between an a.s for rendering and an a.s for parsing.)



## :#storypoint-425 (method)

(right now little is lost and little is gained by caching these but watch out
near box / DSL.)



## :#storypoint-435 (method)

this method is part of our :#private-API.

you can think of it as a #view-template-ish for rendering a particular
argument syntax object into a (possibly styled) string.

in this implementation, result is `nil` if the syntax has no elements,
otherwise a non-zero length, possibly styled string. if a second parameter is
true-ish it must have a range-shape (that is, it must respond to `include?`
that takes an integer argument); if such an argument is present it will be
used to render that contiguous subset of the elements whose indexes are within
that range-ish with emphasis, for e.g to draw attention to them because they
are the subject of a syntax error.

(there is significance that this happens here and not in an auxiliary
"agent"-type object yet.)

(with regards to the method name, get this: an INSANE spin on [#119] the
method naming shibboleth: we use a de-vowelated words in the method, but
they occur at the end and we do not de-vowelate any words not at the end.
this is our way of telling ourselves that the method is API private but
not #ultra-private in the meaning meant in the essay! OMG)



## :#storypoint-450 (method)

this method is part of our :#private-API (a fact that is now encoded in the
name oh boy!). that the root noun of the method name is (an inflected form of)
"text" tells us that the result string (while having been "rendered") is
not styled (that is, it has no ASCII-escape sequences).



## :#storypoint-460 (method)

from its name we see that this is an #ultra-private method (although its API
visibility can be opened up any time as needed). it is a #DSL-method actuator:
it is the other end of a DSL method, the part where our bodies have to cash
the checks that our mouths have written for us.

we check for whether our own class responds to the method because having
included the DSL methods module (or "bundle" depending on who you are) is
by design not a requirement to use the core instance methods ("bundle").



## :#storypoint-605 (method)

this public method is very much part of our :#public-API. any true-ish
argument is appended (with an added separator space) to the resultant string
which may have been styled.



## :#storypoint-610 (method)

this private method is part of our public API. clients may override this
to change the body copy. this is a "renderer" and not a "sayer" because
it is allowed to result in styled strings.



## :#storypoint-705 (method)

this private method is a hook in.

it's really the quintessential model of a ::#hook-in (#todo):

this method is called with a symbol which is one of a set of symbols hard-
coded throughout the API and in-line with the code for now. if this is deemed
as useful we will set all the symbols to constants somewhere.

the function of this method is to turn the symbolic value of whatever the
particular condition is into an "exit status" (that is, an integer)
appropriate for your application.

the core instance methods bundle that this facility appears here in makes no
assumptions about what exit status codes (integers) you want to use (if any)
(a [#023] general facet), but you can hook-in to this method (that is,
overwrite it) to provide your own as appropriate for your client.

one assumption this method does make, however, is that if an exitstatus
is being requested it is because something went awry. this is why we assume
the result that is given. for default clients this value will likely stop the
queue from being processed and hopefully bubble out, causing the topmost
invocation method to result with this value.

note additionally that nowhere does this API actually make a system exit call
with this value (or any) for [#143] reasons. this is also something you would
have to do yourself as needed.

by the way, if you're wondering why we use 'exitstatus' and not 'exit_status'
is because the former appears as a method somehwere in the standard lib, so
it is seen as more idiomatic.



## :#storypoint-755 introducing the param queue

a param queue is an experimental solution to the problem of wanting to
process options and arguments in an order-sensitive way, (in the order they
were received, for e.g.) and also wanting to separate the parsing pass from
the subsequent processing pass, i.e "atomicly". this shares the same concern
as the more important "task queue" described #storypoint-15 above, of
wanting some separation of phase between "parse" and "processing" (or even
between "parse" and "validation").

you will likely need a facility like this if you want both atomic processing
of arguments and (one or both of) order-sensitivity to the options provided
and/or "accumulator" options that have some effect by being used more
than one, other than clobbering whatever came before them with the current
argument value.

(but note that this will all one day disappear because the ultimate goal
is to have these interfaces generated from your API-model.)



## :#storypoint-760 (method)

this private method is part of our public API.
this is certainly a "hook in" because the client may certainly want to
customize how she absorbs (business) request parameters.

assume the value in the param queue ivar is an array of any length.
assume the [#006] ([#sl-116]) error count instance variable is set to
anything. assume the elements of the queue are sanitized (that is, they
represent valid writer methods that can be used to set params): by the time
we get here we must be passed the point of validating whether the param has
a writer, per its implementation. i.e no sanitizing is done at this level.

this facility could use a cleanup of its API; it's a good candidate to be
turned into a dynamically loaded facet or agent #todo:after-merge.

note that in more modern clients, storing the business paramters in ivars
(one per ivar) is never done anywhere at the interface level (the level
at which we are sitting squarely now); but rather this is an operation that
is more suitable to be performed by the various agents at the API level.

however this is here to scale down to the needs of the small client.



## :#storypoint-805 (method)

for each item on the queue, execute it but do not remove it until the
execution was determined to have been successful. allow that the queue may
have been mutated during task execution (namely that it received any
combination of shifting or pushing) during the execution of the task (that
itself came from the queue).

(in this same method we can see that we are not covering for the possibiliy
of the queue having been shifted during task execution (although pushing
"should" work). meh what a bad idea.)



## :#storypoint-815 (method)

this private :#hook-in method is part of our public API. the client may want
to customize this to manage the behavior behind how and whether callables are
built.

ick for now we mutate the queue element since we are processing it now and we
need to store somewhere the name of the method used #todo:after-merge




## :#storypoint-835 (method)

out of the box we make no assumptions about what your upstream should be, but
per [#023] this must be literally true for ok. for the gory details, see
[#022] the CLI upstream resolution narrative along with the corresponding
agent node or bundle or whatever it is.



## :#storypoint-905 (method)

although this method is #ultra-private, it represents the stepping into a
new context. like everything else, in its current form this facility has been
improved from what it was, but it leaves much room for improvement. this is
screaming for the overhaul we are imagining for [#139] the perfect agent
interaction model, but that is not ready for prime time yet (for one thing,
a big part of it is half-finished an in another branch (the semantic channel
method-based handlers) #todo:after-merge.



## :#storypoint-910 (method)

the method callbacks this passes are all #ultra-private for now, but this
could be changed because the whole point is that the client can customize
the behavior for the different events. also this whole mechanic is probably
going to get evolved beyond recognition per the note above.



## :#storypoint-920 (method)

#ultra-private b.c that is its distribution, but doesn't need to be.

oh man, talk about #view-template-ish'es, here goes: we are passed an event
structure that has within it both a syntax slice (think an array of formal
arguments), and full syntax (again same shape). the former is the series of
*all* the required arguments we failed to provide, and is made up of specia
argument objects that include their index into the full syntax.

for one, we only care about rendering the first argument, b.c it is redundant
and extraneous noise to state the rest. for two, if this is the weird case of
a required argument followed by an optional argument we want to be sure to
include the preceding optional argument(s) in the error message; because if
we did not then what we would say would be incorrect as an error of omission.

the effect of all this cleverness is not noticeable unless we have a
:#goofy-footed argument syntax that has optional arguments occuring before
required ones. specs under [#131] the relevant node cover this.



## :#storypoint-1005 help introduction

the help facility is bascially a giant view controller around our model.
this is a strong candidate for agentification that we want #todo:after-merge
and after we reify [#139] our callback model.



## :#storypoint-1010 help

this private method is part of our public API, and one of the payload
behaviors of the library (hence its presence here in the core instance methods
module).

this is a method that may be used as an action. that is, you may see the
symbol ':help' added to the task queue, and what that resolves in to is a call
to this method.

our defeault result is 'OK', which in the context of processing tasks on the
queue means "procede to the next task". we do this for fun and as a proof
of concept to show that we do not give help screen processing special
treatment; but this behavioral fact may have unexpected consequence for
your application.



# :#storypoint-1025 (method)

this method is part of our #private-API.
sadly this is a method with both payload result and side-effects. it makes
the most sense to get the "raw desc lines" and build the sections in the
same pass. but that suggests that the interface should be reworked #todo:after-merge.



## :#storypoint-1050 (method)

assume the desc lines ivar is nonzero-length array. this method exhibits
[#123] dynamic one-line / multiline style differentiation which is a thing.



## :#storypoint-1085 calculate max width

find the narrowest we can make column A of all sections (including any
options) such that we accomodate the widest content there



## :#storypoint-1095

assume extant o.p. (this evolved out of
op#help which is its behavior model)
#assume-previous-line-above
#[059] base?
{ em 'options:' }" # else maybe empty or doc only



## :#storypoint-1105 - section introduction

this section is called "acting like a child". the public "entrypoint" methods
here are part of our public API. they exist to be called by a parent agent
when this agent is serving as a child agent.



## :#storypoint-1110

1) use first desc line if you have that
2) else use o.p banner if that. NOTE not base() (#hack!)
3) else this, unstyled



## :#storypoint-96

nil when no o.p, nil when no visible opts there is currently no unstyled form
but..  one could be made. also this does not currently style but one could be
made.
