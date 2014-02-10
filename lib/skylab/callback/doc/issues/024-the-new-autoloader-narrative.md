# the new autoloader narrative :[#024]

• a fresh take on autolading, gleaning from what we've learned of several
  years (!?) with the old [mh] autoloader stack.

• the primary impetus being the new design goal universe-wide of all boxxy-
  like hacks keeping out of a) mutating the module and b) tainting the code
  with API-specific calls (like "const_fetch").

• in short we want to usher-in the death of "const_fetch" universe-wide, and
  replace it with something functionally the same that is non-invasive.

• the problem was that assumptions were being made across boundaries. no
  framework should ever assume that a module-ish has been hacked without good
  reason.

• hopefully this will have less moving parts and a cleaner implementation.

• at worst we will at least have everything in one unified and concerted
  effort, as opposed to the vast diaspora that autoloading/boxxy is in
  with the older way.


## new cleverness in the "employment" phase

this phase refers to when the client (some module) indicates that it wants to
employ the bundle (this autoloader), specifically having to do with the
syntax of how options ("features") are expressed and how they are parsed,
i.e how their "employment" is "reified".

the focus of the below is more about the novel way we implemented feature
parsing, and less to do with what the features actually are.


• employment features ('boxxy', explicit specification of dir pathname) are
  implemented each as a singleton methods on the autoloader module (currently
  there is only one but this is desiged to be amenable to rearrangement such
  that it makes a stack of modules each "extending" the former, in terms of
  features explained below).

• these "feature functions" are implemented as methods but float around in
  space as if they are procs, which is win-win: we get the narrative
  extensibiltiy of methods but the "first-class-object" nature of procs.

• each such method is passed the x_a and if the feature decides it matches the
  x_a it mutates it accordingly (or perhaps not, in theory) and results in a
  proc that might eventually be passsed the "employer" module as its one
  argument.

• (any such method must result in either a false-ish or a proc-ish. and any
  such proc-ish must accept exactly one argument).

• the only possible outward signal that an error occurred parsing the iambic
  arguments is if there is any remainder to the x_a array after all the
  features have attempted to parse something out of it.


### when such a parse error occurs, argument error message generation is novel:

• one of the things we gain by dealing with methods that are treated as procs
  is that they know their own name

• if the feature method name follows the name convention (which it doesn't
  need to), we can infer that it is either a "'keyword'" or an "<argument>"
  and decorate it accordingly

• we will report that there was an unepected 'W', and that we exepected
  'X', 'Y' or 'Z'; but the "X, Y or Z" will be inferred from those features
  that were not engaged (yet) from the set of all features during this
  parse.

• a more overblown way than this was considered: that each feature be
  implemented as a proper structure in its own right (a class, etc) to effect
  all this "metadata" but this was seen as too overblown at this stage.

• the strategy we have adopted here is seen as neither overblown nor
  underblown, but perfectly blown.


## provided there are no parsing errors with the iambic employment arguments

• atomically and in a pre-determined order, each proc from all the features
  that matched the x_a is reified on the employer module in an order
  determined by the "macro bundle" module.

• whatever the feature actually does to the employer module is of course
  totally up to the scope and domain of that feature.


## in conclusion,

• this perhaps the beginnins of a clever, extensible bundle implementation
  in its own right but for reasons of both bootstrapping and freshenss we
  don't worry now about whether this logic belongs somewhere else (yet)



## understanding 'deferred dir pathname resolution'

it is cheaper and easier to resolve the corresponding ("isomorphic") filesystem
pathname for any given autoloading module passively, on-demand at the first
time a 'dir_pathname' (or related) is requeted of that module; rather than
trying to establish what the dir_pathname is right away for each node that
you enhance as an autoloader.

for one thing we don't build unnecessary pathname objects when we don't need
to. also our hack for inferring the dir pathname from the caller locations
isn't easily portable to different rubies; and to set them "by hand" is so
ugly it almost makes autoloading not worth it.

rather, the current popular strategy is to come up reliably with a dir
pathname only for a 'top' node (for some definition of 'top'), and then
other nodes that need to know their pathname (or may need to know it later),
we just enhance them with the default behavior which is this 'deferred
autoloading'.

to resolve a pathname which has been deferred, the node will first resolve
its parent node thru the usual 'reduce' operation on an exploded string, and
then request the dir pathname of the parent finally, extrude its own
dir_pathname from that.

this requires that each parent node respond to 'dir_pathname' and be able
to resolve its own pathname; which works using the strategy above provided
that each participating node is itself some kind of autoloader.

in any kind of deep graph what this amounts to is a child asking up to its
parent for its dir pathname, and that parent (if necessary) going up to its
parent and so on until one is resolved, and then the flow going in reverse
back down, where each node gets a response from its parent, and from that
can figure out what its own pathname is and tell its child and so on.

elswhere we have a function that does this whole process on a path of a graph,
enhancing each node in the graph as necessary without requiring any
preparation of the graph (except that some top node is found); but we may
deprecate this because of its obtrusiveness.




## implementation: #the-four-method-modules-method

not all enhanced nodes will use all for modules but all will have at least
two and one module will be common to all of them..


### 1. :#the-universal-base-methods..

..are always added to the singleton class ancestor chain of any module that
is enhanced to be an autoloader. any of these methods in this module may be
overridden by methods in modules added nearer in the chain, but these methods
(in some form) must always be present in every autolaoder.



### 2. :#the-triggering-methods

this is currently how we implement the deferred 'dir_pathname' resolution,
which is the default behavior (if no options are passed into the enhancement.)
every method that is part of the public autoloading API is defined here as
simply one that resolves a dir pathname if necessary, (which will by definition
always be necessary) and then "slides in" another module that defines those
same methods and then ** re-calls the same method ** but now with the new
module (method) to intercept the call!

it's a crazy and it's certainly not without its dangers, but when it is
protected from itself has a spare simplicity that we can't get over.

the set of methods that it gets effectively "replaced" with are ..



### 3. :#the-final-methods

the final methods are the actual payload methods that do the bulk of the work
as it pertains to having a dir pathname. for nodes that know their dir
pathname from the start, they need to have only the universal base methods
and these ones, and will have them from the start typically.

elsewise they are deferred and they "slide" this one in "on top" of their
"triggering methods" once they have resolved their dir pathname.




### 4. :#the-boxxy-methods

these are optional and always experimental: they hack 'constants' and
'const_defined?' to do fuzzy inference based on the files in the filesystem
(without loading them!). this is convenient when it works but can potentially
be a headache when it doesn't..

the boxxy methods module has a particular set of skills that it uses to make
each next module it loads also be a boxxy module. for this to work the
ancestor chain must be right in that boxxy must sit in front of the universal
base methods.

this pattern in general is why we must ensure that the universal base methods
must get put on the chain "first" so they are not in front when others are
added that wish to overrride them.




## :#storypoint-50

just because something is simple doesn't mean it's not dangerous: no matter
what you never want to extend an object with the deferred methods module when
it already has the "methods" module in its chain. this will result in an
infinite recursion in our simple algorithm.



## :#storypoint-240

the module is certainly allowed to have some constants set ("loaded") before
the first time it calls a method that boxxy has taken over (namely 'constants'
or 'const_defined?'). and if we make incorrect guesses of what constants the
filenames signify after we already have some constants loaded, welp we just
look stupid that's what.:w



## :#storypoint-265

if you have a newschool base-class and an oldschool child class (e.g
[de]::Version) this comportment is necessary for when the olschool a.l loads
the newschool node.
