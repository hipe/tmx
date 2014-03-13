# the CLI client narrative :[#056]

`Face`
  + wraps around ::OptionParser by default
  + renders styled help screens and the usual help UI
  + arbitrarily deeply nested sub-commands (namespaces)
  + nodes (commands and namespaces) can have aliases
  + fuzzy matching
  + command argument syntax inferred by default from method signature
  + some built in 'officious' (allà stdlib o.p) like -v, -h

historical note - this library by this name came before headless and
before porcelain (both `bleeding` and `legacy`, indeed it was the first
client library for `tmx` itself) and it did not age well; but then saw a
comprehensive, ground-up test-driven rewrite (TWICE) after those two fell
out of fashion. it will hopefully be merged into headless one day because
now it is close to perfect.

unlike its ancestors, `Face` eschews use of spurious, exuberant,
extraneous, or frivolous modules. instead it aspires to a minimal and
clean class graph with three classes, a graph that is the embodiment of a
rigid and complete trinity of balance, whose goal is to be extensible
while not sacrificing simplicity of design and clarity of comprehension.

in practice there are more than three classes but conceptually this
"triforce" is intrinsic to the design here (illustrated in [#040]).

as for the structure of this file, we may sometimes follow something like
"narrative pre-order" ([#hl-058]), whose effect is that classes and
modules are re-opened as necessary so as to fit method definitions within
the appropriate section, to make a rousing narrative, and to make it
semantically modular, if we ever need to break it up. within that structure
we often follow a top-down outside-in order.


## :#storypoint-40

an object of a subclass of the `CLI` class is *the* "modality client".
it is the first node to "see" resources like ARGV and $stdin, $stdout,
stderr ; and is the only node in this ecosystem to "be given" such
resources from the ruby ecosystem directly.

this `CLI` class itself is a would-be #abstract-base-class - it is not
meant to be instantiated directly and to do so has undefined results.

this `CLI` class in its implementation is a specilization of the `Namespace`
class with some extra added functionality for being the topmost (or rootmost)
node (for some context) in the application tree. except where noted, all
description of `Namespace` below will apply to this class here, so please see
that for further description of the `CLI` class.



## :#storypoint-75 - method

the only public method. #existential-workhorse. accords with [#hl-020]



## :#storypoint-175

`pre_execute` - #called-by self in main execution loop, #called-by
n-amespace facet when ouroboros is happening. about it: we "re-touch"
(that is, `pre_execute`) before every execution for fun, sanity, grease,
and design - ostensibly so that the p-arent can change the identity of
these resources late and during runtime while b) we can still have them
be simple ivars and not long-ass call chains. (also, the point is moot
insomuchas CLI's are not long running processes anyway!)

in this entire library (without extrinsic facets / extensions), of the
whole matryoshka stack [#040], the only resource *we* need is @y: the
standard error stream line yielder (makes sense, right?).



## :#storypoint-185

the `Namespace` class is an abstract base class - it is meant only to
be subclassed. to instantiate object from it directly has undefined
results. the `Namespace` class is the central embodiment of a DSL in
this library - it is the interface entrypoint for employing [#041]
`isomorphic command composition`, that is, public methods that you
write in your class become commands in your user interface. as such,
except where noted, the "n-amespace" of instance methods (public, private,
and p-rotected) of this class is preserved entirely for "businessland"
concerns - that is, the developer user determines them, not this
library. again as such, for instance methods, you will only find one
defined here - `initialize`.



## :#storypoint-210

`use` - the `use` directive states, "i will be using the following
methods provided by my mechanics layer up here in my surface layer."

as explained in this class's head comment, we pledge to provide no
instance methods at all to your namespace subclass [#037]. however
in practice it can be convenient to have a few private methods defined
here on your "surface" (or "shell") class for doing things like
creating common o.p options or styling help screen text. the
`@mechanics` object (itself a command) provides such facilities
but it can look ugly (and presents scale issues) to have any trace
of that in your UI code. the `use` facility, then, simply defines
private delgator methods on your shell to services provided by the
mechanics layer.

(covered in cli/api-integration/with-namespaces_spec.rb)



## :#storypoint-240

(remember, no need to call up to super. we have no superclass.)

(lazily, only once the surface is created do we check and see if a
custom kernel class has been subclassed, defined, whatever, and
if not; we subclass a default mechanics class (descending from the
appropriate base class) and put it there. whichever class was resolved
from the above is the one used to enhance this surface and resolve a
@mechanics instance.)



## :#storypoint-250

the abstract representation of a n-amespace. before you build any actual
things, you can aggreate the data around it progressively.

the CLI client class (like many other entities here) internally stores
*all* its "businessland data" in a "character-sheet"-ish object
(sometimes called a "story" when it is in regards to a n-amespace).
A n-amespace's story consists of properties and constituents. the
properties are things like the n-amespace's normalized local slug name
and aliases. the constituents represent the n-amespace's child nodes
(either terminal commands or other namespaces (themselves a special kind
of command)). we say "represents" because actual n-amespace classes or
command objects are not necessarily built at declaration time. instead,
we may have as our constituents one sheet for each of this node's child
nodes. (deeply nested namespaces are then stories inside stories yay.)



## :#storypoint-335

(this class broke out of Namespace itself and became a standalone
class during [#037], to address the concerns therein. its funny name
ending in an underscore means it is not part of the public API, nor
stable. it follows [#hl-073] extrinsic / intrinsic ivars.)



## :#storypoint-365

(use the `initialize` of p-arent - (sheet, parent_services, slug))

`find_command` #existential-workhorse #called-by-main-invocation-loop
#result-is-tuple. assume `argv` length is greater than or equal to 1.
remove at most 1 element off the head of `argv. #result-is-tuple. if
command can be resolved, a *h-ot* subcommand is the payload element of
the pair.



## :#storypoint-670

we can't / shouldn't just shoot messages upwards directly with `send`.
for one, because of the pledge to keep the entire method namespace
reserved for businessland (except `invoke` in the case of topmost), we
simply cannot go adding "mechanical" methods willy nilly to there.



## :#storypoint-1005

we don't know if we love this or hate it. originally it was easy and
had high novelty value to let this isomorphicism extend all the way to
to this level but then it looked more ugly then elegant, but again now
it seems like it might be ok because it is in accord with the whole
spirit of this thing. meh who cares its just CLI [#004].



## :#storypoint-1360

`get_summary_a_from_sheet` - # #called-by-p-arent documenting child #experimental
*lots* of goofing around here - this terrific hack tries to
distill a s-ummary out of the first one or two lines of the option parser
-- it strips out all styling from them (b.c it looks wrong in summaries),
and indeed strips out the styled content all together unless (ICK) that
header says "usage:" #experimental proof-of-concept novelty hack.
not actually ok.



## :#storypoint-1845

this is where it
happens for the `Namespace` class itself, which does *not* have its own
story (because stories are for holding "businessland" data, and the
Namespace class itself has no such data of its own to hold as explained
above.) however, because we define `method_added` in this file for this
class, when we add any methods subsequently to the class (like in
facets), we probably do not want the `method_added` mechanism to be
engaged at all, hence we define one such ivar for the class itself, and
subsequently use this ivar as a flag to indicate whether or not we want
to react when methods are added. (in the past this same ends was
achieved more opaquely with hacks like defining `method_added`
dynamically on the businessland subclass; but this alternate solution
here is seen as more transparent and less invasive.)



## :#storypoint-1855

`self.with_dsl_off` - in cases where you want to create (or re-define
existing) public methods on your client class that no *not* isomorph into
commands, define them inside such a block. see spec `dsl-off_spec.rb`.
use of this facility is considered a #smell, and as such the only
reasonable use for this is for something like overriding and extending
the one existing necessarily public method - `invoke`; something done
to wrap the invocation in extra UI, e.g. displaying an invitation to
more help when there is a soft failure.



## :#storypoint-1865

`self.dsl_off` - sadly this does not do exactly the same as above -
we use this alongside the canonical one location of the call to `private`
in a class so that we don't gather any extraneous data about (private)
methods added. in theory it has no functional effect, it is just to make
debugging easier by gathering less data (and is a micronic optimisation.)



## :#storypoint-1870

Scooper_ encapsulates *all* of the low-level `method_added` hacking
we do for `isomorphic command composition` [#041]. because there is
exactly one scooper per n-amespace class, it does not really need to
scale out much; hence we write it in the below style for fun and as
an experiment.
