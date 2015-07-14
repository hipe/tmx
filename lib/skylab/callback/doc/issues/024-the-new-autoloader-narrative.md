# the new autoloader narrative :[#024]


## first and foremost, a caveat:

this subsystem has specs that offer "fair" to "good" coverage of the
functional space of autoloading, but there are known edge cases whose
behavior will only be effected by:

  • running all of the specs universe-wide
  • and/or running the "doc-test recursive" spec generation universe-wide.

there are so many different possible topologies and edge-cases involving
combinations of stowaways, autovivified branch nodes, core-files and
directories with no leaf nodes in them that it may in fact be counter-
productive to try to cover them all with dedicated specs (but maybe not).

(EDIT: below needs the names modernized)

running "tmx regret doc-test" ("trd") recursively on the universe takes about
two seconds, and can be run from the universe root with something like:

  tmx-regret doc-test -r -- -f -vvvv

running doc-test recursive on the whole universe is useful because of the
way it is implemented: it just so happens to push autoloading to its limit:
unlike "normal" autoloading where you start with a constant and need to load a
correct file to resolve the constant, the subject operation starts with
a filesystem path and attempts to resolve one or more nested const values
from that path.

furthermore it does this sort of operation on a relatively large number of
files with a variety of different graph topologies and combinations of
features as outlined above.

because a const name holds more information that a filesystem path name (per
our convention), we have to do a fair amount of tricking to make this work,
tricking which in turn is exercized to its fullest when all of its target
stories are exercized.




## why autoloading?

• because cleaner code. the ideal autoloading facility will minimize the
  amount of load-related code that the businessland code has to concern
  itself with so that when we are reading businessland code we can read the
  code itself and not be distracted with loading-related code.

• because isomorphic simplicity. for some applications it can be useful to
  define a collection of constants each in their own file that represent
  business entities (typically something like "actions" or "plugins").
  by a process we refer to as :#isomorphic-inference :[#.A], we may indicate
  to the autoloader that certain particular modules leverage this
  relationship with the filesystem, such that a directory listing from the
  filsystem can give us hints about the constants that would be defined
  were we to load these files.

  it may be convenient to iterate over the "constants" of such a
  "box module" and have it "just work", yielding each inferred `const`
  even though the files have not yet been loaded.
  (this is #the-boxxy-methods behaviorset).

• because efficiency (for certain use-cases, #experimentally): by the
  #the-boxxy-methods behaviorset described above, we can infer fuzzily that
  certain fuzzy sets of constants probably "exist" (i.e have values
  associated with them ) withouth needing to load all (or any) of their
  respective files.




## goals for ths phase of re-working

gleaning from what we've learned of several years (!?) with the old [m-h]
autoloader stack:

• the primary impetus is this new design goal that universide-wide all
  behavior that might trigger autoloading (whether it be for a #boxxy-like
  or non-#boxxy-like module) must be :#unobstrusive: we must limit ourselves
  to the familiar module builtin methods of 'constants', 'const_defined?',
  'const_get' (no more 'const_fetch' etc).

• expanding on the above point, we want to usher-in the death of "const_fetch"
  universe-wide, and replace it with something functionally the same that is
  non-invasive.

• the problem was that assumptions were being made across boundaries. no
  framework should ever assume that a module-ish has been hacked in some
  particur without absolutely "needing" to do so. and even then still no.

• hopefully this will have less moving parts and a cleaner implementation.

• at worst we will at least have everything in one unified and concerted
  effort, as opposed to the vast diaspora that autoloading/boxxy is in
  with the older way.

• as for implementation, we can reduce number of "trips" to the filesystem by
  making a "directory listing cache" (see #the-conservation-of-entry-trees).

• #death-to-the-peek-hack. we need this to go away, certainly.




#### when such a parse error occurs, argument error message generation is novel:

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


### provided there are no parsing errors with the iambic employment arguments

• atomically and in a pre-determined order, each proc from all the features
  that matched the x_a is reified on the employer module in an order
  determined by the "macro bundle" module.

• whatever the feature actually does to the employer module is of course
  totally up to the scope and domain of that feature.


### in conclusion,

• this perhaps the beginnins of a clever, extensible bundle implementation
  in its own right but for reasons of both bootstrapping and freshenss we
  don't worry now about whether this logic belongs somewhere else (yet)





## :#not-idempotent

(this error is a throwback to back when we used to do a tricky hack with a
"slider" module, a trick that broke when inheritence came into the picture.
we preserve the anti-idempotency today only because it was a thing in
the past and may re-become a thing in the future.)




## :#introduction-to-the-entry-tree

the entry tree is a merging of what were formerly two separate entities:
1) the "directory listing cache" and 2) the #load-state registry.




### the directory listing cache

this cache answer the questions, "does this file or folder exist?" and
"is it a file or a folder?". although it is ultimately an implementation
detail, it is one with far reaching impact on the architecture of autoloading.

this cache hits the filesystem once per relevant directory (on demand) and
then caches the results of the directory listing forever (for the runtime of
the application).

with the rationale that filesystem hits are relatively expensive, this
overhaul to autoloading bases its architectural foundation around the rubric
that we *never* made a reduntant trip to the filesystem for the same
directory listing in a dictum we call :#the-conservation-of-entry-trees.
as it turns out this is an architectural principle that is challenging to
adhere to, given some other parameters in our universe.

no cache-clearing facility has yet been implemented nor has yet been
necessary, but it is certainly feasible to create one if ever necessary.

this cache is then the means by which we determine whether particular files
or directories exist on the filesystem (for entries of that directory); and
what those entries are, if desired in a listing.

this cache reports whether any particular entry is a file or a folder by
simply looking if the entry has an extension, a hack that saves us a trip to
the filesysystem and works provided that we are following our name conventions
for files and folders which is likely always to be true to the extent that it
matters here.

hardcoded whitelisting or blacklisting may occur in order to exclude certain
shapes of filename for consideration as a relevant file or folder (for example
it is sometimes useful to be able to prefix or suffix a filename with an
underscore if you are using that file as a scratch location for code fragments
or otherwise want that file to be ignored by the autoloading facility).




#### :#the-isomorphicism

in its simplest terms this "isomorphicism" is one where if there is a const
missing Foo::Bar_Baz then we can assume something like that it is defined in
the file "foo/bar-baz.rb".

we can use this inferred association in a "forward" manner to load the
correct file for a particular missing constant as we did in the example above
(provided that we follow our own conventions) but also we may use it in a
"backward" manner to infer what fuzzy constants exist given the files and
folders of the filesystem.

the set of constants this entry signifies is not but should be considered
an infinite set: we assume that the file "foo-bar.rb" defines at least one of
the consts "FOO_BAR", "FooBar", "Foo_Bar" and so on ("inifitely"); but we
won't know which const(s) are defined in that file until we actually load it.

the above various constants we refer to as variations on "casing" and
"scheme" (although we don't define rigidly what those two mean). the set of
all of them we may refer to as a "fuzzy const" (although note that it is not
a fuzzy set!).

this incarnation of autoloading is distinct from its predecessors in that it
never assumes any particular casing or name scheme; rather it must load a
file with code that a human wrote in order to resolve what any particular
needed surface name is for a fuzzy constant.

more on this can be found in #find-some-file.




#### :#normpaths and the imaginary root entry tree

all the constants that will ever be defined in the universe are
conceptualized as fitting into one universal tree, which may be conceived as
being something like a sub-tree inside of (or adjacent to) the tree of all
those constants (where the branch nodes of this tree of constants are
necessarily ruby modules).

the nodes of this universal tree are called "normpaths" because they may be
referenced by a "normalized path".

the :#normalized-path is what it sounds like: it is like a filesystem path,
but it may be normalized in a lossy way that facilitates our autoloading
algorithm. it also encapsulates (read: caches) filesystem state and
#load-state as will be explained below.

the name components of a normalized path hold less information in them
than the const names they fuzzily associate with: this is essential to
understanding our autoloading algorithm. normpaths do not uniquely identify
const values, but rather they signify the files and folders that may be used
to load or vivify those values.

furthermore unlike a plain old filesystem node (e.g a file or directory); a
single node in this tree of normpaths may effectively represent one
filesystem directory and/or multiple filesystem files. this relationship
between patterns of filesystem nodes existing (files and/or folders) and
their corresponding normapths is entirely a product of our autoloading
specification:

a single normpath in our imaginary universal tree may effectively represent
zero, one or two files and possibly one directory; probably occuring in these
specific permutations (where the pseudo-notation "~Foo" means "a const like
'Foo' but not necessarily with that casing/scheme" -- so it may also signify
the consts 'FOO' and 'FoO'):

  • a normpath may represent simply the normative file ("foo.rb" for ~Foo)
    in such a case as the filesystem reports as such a file existing and
    not one such below directory. (loading such a straightforward normative
    node may be implemented near #the-file-story in the code.)
  • a normpath may represent simply the isomorphic directory ("foo/" for ~Foo)
    in such a case as the filesystem reports only this directory as existing
    and not one such above file. (the act of autoloading such a node may be
    implemented near #the-directory-story in the code.)
  • a normpath may represent both one such above file and directory in such
    a case as the filesystem reports them as both existing.
  • a normpath may effectively represent such a directory and an existing
    contained "core.rb" file in such a case as the filesystem reports that
    such an above file does not exist and such a "core.rb" file does.
    (the act of autoloading such a node may be implemented by
    #the-corefile-story in the code.)




#### the :#load-state of normpaths

each normpath node maintains a "load state" which is simply a symbol
representing at which point along the loading lifecycle that particular
normpath is currently. this in concert with the fact that normpaths are
(or need to be) effectively long-running memory-persistent objects allows
us to implement our absolutely insane :#branch-node-vivification algorithm:

each normpath node acts as a simple state machine proceding in sequence
through these states:

  [not loaded] -> [loading] -> [loaded]

note it is a simple linear directed graph with three nodes. each state
transitions to either zero or one other state, and conversely each state is
transitiond to from either zero or one other state, and once you are in a next
state there is no going back to any of the previous states.


#### understanding the utility of load-states by knowing their history

the earliest ancestor to this mechanism was a global cache of absolute
pathnames that served as a sanity check: if ever the same filesystem path was
attempted to be used more than once during a const-missing event, it was
assumed to be because a file that was being used to satifsy a const-missing
event triggered yet another const-missing event for that selfsame constant
(or another one in its fuzzy family).

without this mechanism in place such const-missing events from such files
with poorly formed constant topologies would result in infinite recursion as
the file tried infinitely to load itself to resolve its own const-missing.

then during the middle of the overhaul that this essay is a part of, this
mechanism blossomed into something more complex and more useful: we were
revisiting a problem whose solution was an absolutely awful hack in a process
that became known as #death-to-the-peek-hack.

our improved solution to this problem started out as something like this:
no longer do we ever "autovivify" a module simply by virtue of the fact that
a directory exists (because it is impossible to guess its correct casing).

rather, the only way to "vivify" such a node is to load a file that
references that node with the correct casing. because you won't have vivified
the node (module) yet, the loading of one such appropriate file (provided it
follows the conventions) will either define such a node inadvertently (for
example with an incidental module declaration of the topic module even though
it is off-topic for the node the file isomorphs with); or the file may
reference the topic node which will trigger yet another const missing for this
node.

if we keep track of all this above expectation as we load the file, then
we can take special actions when the loading of the file triggers such const-
missing events (specifically, "vivifying" the module at this point now that we
know the incoming const missing casing is the "correct" one). or such cases
that the file does not raise any const missing events, we can inspect the
appropriate lists of consts and do fuzzy matching to determine the correct
casing.

as a first stab at an implementation for the above involved keeping a count
of how many times a normalized path was accessed in order to resolve a const
missing. we would take certain differnt actions whether it was the first,
second or third time the path was being "touched" and this worked (however
messily), and then finally evolved into the load state facility:


#### the load states in detail

it is load states like these that let us keep track of whether the incoming
surface name for a fuzzy const is the "right" one or not, when we are in
the middle of resolving that const name by loading a file. here are the
particular assumptions we make when the corresponding normpath for a const-
missing is in these states:


• when not loaded

for the normative const missing event, at the beginning of this event the
corresponding normpath node has a state of "not loaded". in this simplest
of stories we change the node's state to "loading", then load the appropriate
normative file and then change the node's state to "loaded."

for certain nodes we may have to load a (file) several levels (directories)
deep in order to resolve the casing/scheme and value for that fuzzy const,
which is the #find-some-file algorithm described below.


• when loading

this below feels like it has a certain spare elegance to us when it works, but
when it doesn't it can be the cause of persnickety bugs. this is one of the
more complex points of the autoloading facility, and it should probably only
be learned on an as-needed basis.

if a given nodes's state is "loading" when we receive a const-missing event
for an associated constant name, then we assume we are already in the middle
of processing a const-missing event for that node. **very carefully** we
assume that current const-missing event is coming from within the file itself
that is being loaded (just as we used to use a similar techinque to avoid
infinite recursion in such cases as described above).

in such a case we assume this means that the topology we are in is something
like a tall, narrow tree: the code is written as if the module exists but
no where is the module ever defined. so we go ahead and define the module
now assuming that the casing of the name we have is correct, and we
furthermore "autoloaderize" this newly created module.

the const-missing event for this node results with this newly created module
which "dumps back out" into this file that is in the middle of loading; and
then the file continues on its way, defining whatever topic node it is in the
middle of defining.


• when loaded

once a normpath has been moved into a 'loaded' state, then no further loading
of files can or will be attempted to resolve any const missing events
associated with that normpath. the only way to resolve such an event is to do
a fuzzy lookup and hope that we find an existing const that has a simliar name
(e.g 'FOO_BAR' for 'FooBar'), and result in that value.

the fact that we attempt such a fuzzy name correction in such an event instead
of raising a NameError is so that we can be interoperable with the new
#isomorphic-inference implementation that attempt to remain #unobtrusive.




## :#on-the-ugliness-of-global-caches

because in this universe at this moment in time the top node (but any node
in theory) is neither a new nor an old autoloader, we may *not* use its
internal instance variable space to hold its own entry tree cache.

however we must hold it somewhere because of this new, strict dictum of
#the-conservation-of-entry-trees which holds that we cannot redundantly
create entry trees for any same filesystem path more than once. hence, only
at this corner where we ever make such trees we must maintain a *global*
cache of such trees, lest we create one redundantly.

note that this cache is only necessary because of the const-reduce facility.
in a universe where our topmost node (skylab) does no autoloading of its own,
it would work fine to let each subsystem top-node manage its own entry tree
and so-on down; but as soon as we use const-reduce on any top node, we must
cache it lest we create the same entry tree twice.




## :#must-sort

as it always has been going back to the dawn of this trick (before it was
even called "boxxy"), it is crucial that we normalize the list of directory
entries that comes back from the filesystem, in terms of its order. if we
don't, we will get an "erratic" order on different systems which makes this
problematic to test and can lead to flickering errors.




## :#find-some-file

### TL;DR: we never autovivify..

instead we search downward and load *any* first file found under the dir, and
in so doing reconcile many consequences.

before we load the file, with each (nested) const that we expect to be set
set by the file (in a linked-list style structure) associate with it this
chain of expected nodes.

then when we load this, it will (hopefully) trigger the series of anticipated
const_missings for this same node we are trying to resolve now.


### the full story

new autoloader had a good goal when it set out to do its thing, but its
initial pass at autovivification was still fundamentally flawed. the crux
of the whole thing is "vivification" is always problematic (depending):

• const names and file names are not perfectly isomorphic. specifically, in
  our name convention [#hl-156] (maybe?) it is one-way lossy: you can always
  infer the filename from the const name, but there are exponentially many
  possible const names for one filename:

• and moreover there may exist multiple const values with different casings
  (different names, but the same "distilled stem") in the same file.
  (we now sometimes call these "fuzzy siblings.)

• for example either "FOO_" or  "Foo_" could exist in "foo-.rb", or both, or
  neither. (but per our name convention it is reasonable to infer that there
  is at least one const /\Afoo_\z/i defind in that file.)


given the above, if you assume that a module exists given that a directory
exists, you must never create it yourself because it is impossible to know
beforehand what actual name to use.

• you could somehow load some file that itself references / produces the
  module (or non-module const value) for you.

• but the above isn't always convenient: in a tall narrow tree, we don't
  want to have to create an orphan file just to establish what the name
  is for a module whose only purpose is to contain other modules.

the system can work out if always you are referencing autoloaded consts from
hand-written code, consts which themselves use the "correct" const name.
however if you are loading a node tree dynamically from a filesystem tree
(which is the essence of the "boxxy" experiment), you have a tricky problem
for particular shapes of tree:

                 [ My_App ]
                       |
                 [ ~ mod-foo ]
                       |
                 [ ~ file-bar ]

the tilde ("~") means "we don't know the correct casing for this name or
the correct name scheme." so for example "mod-foo" might be MOD_FOO or
ModFoo or Mod_Foo. (and in practice any one of these is an equally good
guess.)

so the working experiment is this:

  1. you are at a node (a module) whose correct name you have (which should
     be ipso facto true if you "have" any node in the first place).

     • you want to load a node for whom you have the stem but don't know the
       correct casing or scheme (let's say it's [ ~ mod-foo ].

     • that node doesn't have a corresponding "leaf" file ("mod-foo.rb"),
       or a corresponding "core" file ("mod-foo/core.rb").

  2. before we give up and raise a load error, we'll try this ridiculous
     thing: recursively downward for each node, keep looking for *any*
     file to load. any first file will do. raise a load error if you don't
     find one, but if you do:

  3. load the file. then see what happens..



## :#stowaways (:#the-weird-thing-about-stowaways) :[#.B]

### the stowaway can be a means to avoid creating an orphan

sometimes "stowaways" are used to avoid creating "orphan" files: consider a
code-node that takes only a few lines to define. we don't want to create an
entire file with only a few lines in it: it is a waste of resources both
digital and wet, and furthermore it incurs an aesthetic penalty.

(we are not using the literal meaning of "orphan" (i.e "child without parent")
here. rather we are using the sense as it is applied in typography, referring
to a dangling line of type that is very short (for example one word). here
:#orphan means a code-node that is very short.)

in such situations we often go one of two directions: either we stuff the
orphan "upwards" as a "stowaway" into its parent node, or we stuff it
downward as a stowaway into one of its own child nodes.

we offer no detailed justification here for why one would chose to go one
direction over the other, but the short of it is one may have less moving
parts and the other may be more modularized.

in the case where we chose to "stow the orphan away" into a deeper node, often
that deeper node is the main reason for existence for the would-be orphan
in the first place.

in such a case the orphan const and the host file are no longer related by
#isomorphic-inference: the autoloader must be told explicitly that the place
to find the value for this particular missing constant is in this particular
file.

loading a stowaway of this category is relatively straightforward: it should
be effectively the same as autoloading the host node.


### the stowaway can also be used to define the node in a bizarre location

other times, however, we may use stowaways in order to define a node in a
nonstandard location, that is, one that "breaks" #the-isomorphicism in an
arbitrary way.

a challenger may occur with 'post-processing' the loaded file that contains
a stowaway unless we remember this: the path-parts to the relative path of
a stowaway do not necessary correspond to constants that that stowaway
defines.

because of this the way we "post-process" a loaded stowaway file is different
from how we post-process for e.g the autoloading of a directory-style node.
specifically in the topic method we traverse each entry in the chain, and
if one such expected node is defined at that entry we process it as normal,
but as soon as one entry is found that does not appear to have a correspoding
const defined for it, we short-circuit the rest of this process.



### :#stow-1

the path that we load does not necessarily have corresponding isomorphic code
nodes: this is half of the use of stowaways. but in the case that it does we
set them to 'loading' now. in the case that it does not then we use these as
execution mutexes only.



### :#stow-2

the stowaway either does or does not have a correspding filesystem node (held
in the entry tree) that it isomorphs with by name. if it does then the
filesystem node is probably a directory and not a file and the code node is
probably avoiding making an orphan (i.e very short) file. in such cases the
dir pathname that will be generated anyway is probably "correct". otherwise we
must correct the dir pathname that will be placed in the module.

we make a fake entry-like normpath in the entry-tree to give us some mutex-
like sanity here and to comport with the rest of the API



### :#stow-3

we make a mess of a mockery here so that a) the rest of the system doesn't
need to know about stowaways and b) we can sanity check the load state of
these nodes and assoc them with normpaths as we do for the others.



### :#the-inconvenient-truth-about-stowaways

in this universe we may use stowaways to accomodate the broken isomorphicism
between a const called "TestSupport" and a directory called "test", one that
exists for both historical and aesthic reasons (although I don't remember
specifically what our reasoning was for avoiding the use of the name 'Test'
for modules generally).

in this same kind of area spec files do a very locally idiomatic but
widespread thing where they use 'require_relative' upwards in a chain, up from
the spec file upwards to the top-most 'test-support' file in that subsystem.

the concert of these two facts means that test-support files may be once
loaded by the stowaway loading facility, and then redundantly "loaded" again
when our test files require them (because the 'require' facility doesn't know
what has already been loaded). this is certainly a showstopper ever to load
the same file twice.

generally we prefer to use 'load' instead of 'require' in the autoloader
because 'load' is more low-level and will fail more loudly if we load a file
redundantly. however, to work around the issue above we use 'require' and
not load, but for now only for stowaways.

if for some reason this same probelm were to affect the more general universe
where autoloading is used we would make the same chage there; but as it
stands the general universe generally uses the autoloader and rarely uses
'require'.




## what are hybrid boxxy nodes? :[#041]

they are modules that define some constants "in line" (like normally) in
the file that belongs to the subject node; but would like for others to
be define alla boxxy with constant inference. when we do this we track
them with this identifier.
