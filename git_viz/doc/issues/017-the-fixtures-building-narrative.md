# the fixtures building narrative :[#017]

(EDIT: this document is all +#archival. the simplified [#007] replaces this.)

## introduction

(EDIT: this pertains to the "build scripts" written largely in zsh, and not
the (perhaps more interesting) fixture client/server, whose top node of
documentation is [#018].)

every "node" and every level of this mini-system will implements its UI in
this one, centralized way unless it has good reason not to: we can infer a
whole mess of names from the invoked script path, and this serves as the
backbone of would-be instance variables of our would-be client objects in
this whole fiasco (again, "at this level").

but first, let's back up a step:



## why all the scripts?

to anser the question of why we are mocking anything in this project is well
outside the scope of this document, but suffice it to say we rely heavily on
the ability to "record" accurately system calls and their real-life responses
in terms of their standard output, standard "errput" and exitstatus.

this "recording" process is something that is done during development time
as opposed to test runtime. (for now, anyway).

we write this "triad" of stdout, stderr and exitstatus (or perhaps just a
subset of it) to disk and version it as needed according to the different
system calls we have, when their shape changes (i.e the options we pass it),
and as-needed as we add more test cases per system call.

so the reason for all the scripts, then, is that they act as "proof" that we
developed this whole project with tests against "real life" output from the
system calls (for some particular environment, namely the one we developed
this on). we create these recordings in this manner because:

• they allow us to quarrantine, inspect & better understand and edge
  cases of the system call responses that may trip us up, down to every
  byte of every output or errput (e.g. dangling trailing newline or absence
  of one, something that bit us once.)
• running our unit tests against real-life "recording" of the system
  is not as clunky, resource intensive, and headache-prone as running
  our unit tests against a real live "asset" (e.g repository). we should
  not need the external "outside" system to be functioning in order to develop
  this or to "prove" its correctness.
• instead we offer the passing or failure of our tests to "prove" the
  correctness of whether or not our system works against these system calls
  with these responses, which is a separate area of concern from whether the
  system calls and their responses reflect "correctness" for any particular
  real-life target environment.
• as part of the #autobleed pre-project, having a robust and modular
  "system recording" facility will be essential; of which this effort could
  be a first practical step. as it pertains to this project (and in more
  concrete terms), these scripts will come in handy as we try to zero-in
  on the (already present) issues we encounter with the "API" changes of
  the particular VCS over its versions, or for e.g cases where the actual
  behavior of the vendor system differns from the reported behavior from
  our particular manpage for that command (a different problem in itself).
• building a new tool with a new (to us) technology is fun.



## why the change to zsh (from bash)?

one goal of this mini-system is to allow the different nodes at different
levels to build however they want. so in fact we only changed to zsh at one
particular level.

the build process for each "asset" is generally spawned in a new process, and
is generally not merely sourced from the parent script; so each such build
script is not necessarily a script at all, but any arbitrary executable.
hence the sub-nodes can use whatever technology they want. so at particular
levels we are not locked into any particular shell per se.

(yes we are making room for one alternative technology in particular, and
it's not ruby.)

but this avoids the question. we switched from bash to zsh first because our
model was the plugin "architecture" of "oh-my-zsh", and then we found this,
which we found compelling: http://spencertipping.com/posts/2013.0814.bash-is-irrecoverably-broken.html)



## why not just use ruby?

zsh's "value prop" is also something that can be a liability: with zsh we
run close to the system. with this "recording" behavior we are after, the
bulk of our implementation involves creating directories and simple files,
invoking vendor executables, and redirecting their output to even more files,
and then moving those files somewhere. this is the bread and butter of the
shell, and it's far less clunkly just to use the shell directly rather than
use ruby (or so the thinking goes).

the cost of this system closeness is that we may loose portability, but given
the narrow audience for this mini-system (probably consisting of one customer),
this is currently deemed unlikely to be an issue in the forseeable near future.



## why not just use 'make'?

we are considering it (at some level at least).



## :#storypoint-5  :#the-name-conventions

of course we use name conventions in our shell script code, and of course
they differ from the name conventions we use elsewhere:

• "process-global-functions" :

  for functions we generally use "names-like-this" and not "names_like_this"
  because a) we can and b) it gives more visual distinction from the other
  classes of things that use "names_like_this". (when we get into [#028]:
  #dynamic-scoping-as-ersatz-vtable it helps to have this visual disctinction,
  because half the time in some documents we call functions thru parameters
  and not directly, and this name change helps emphasize the difference.)

  specifically as it pertains to process-global functions, we use this name
  convention for functions that are made to be somehow reusable by multiple
  scripts and/or contexts.

  they are often but not always autoloaded. these will often have long-ish,
  very qualified names a) to make them easier to find and and b) to avoid name
  collisions with functions defined by the more specialized sub-nodes. we will
  discuss ways to avoid stompable names in #we-can-have-happiness below.

• "-local-volatile-functions":

  if you think it's ugly then it's because you just got here. names that are
  lowercase sepearated by dashes with leading dash are reserved for functions
  whose only scope is within the current "resource" (be it an executable
  script, a "library"-style source-able file, or a function (yes, we use
  functions inside functions. yes we are a girl, yes we play games)). these
  names can be stomped by other same names from other files, so only use them
  knowing this. also, see note below about avoiding stompable names.

  sometimes (even often in some places) they are written expecting possibly
  to be overwritten, almost like parent methods getting overridden by child
  methods in (gasp) OOP. but this approach is certainly experimental and
  certainly not "scalable".

  depending on what kind of file you are in you may see these a lot, because
  when implementing logic, we prefer a style of lots of short functions with
  long readable names.

• "--highly-coupled-tributary-function":

  yes these look like options and that is just an unfortunate coincidence that
  you quickly learn to ignore. (just wait until we pass function names as an
  argument to an option, and they are both the same symbol.)

  functions of this form are written just to break out a small chunk from
  a larger chunk of logic (but isn't every function?). the difference here
  is that for these functions we couple them tightly to the variables in the
  namespace of the caller.

  specifically, we don't bother passing positional parameters to them, we just
  refer directly to the parameters in the outside scope. indeed we even effect
  the "result" value(s) this way. again it's better here to pretend these are
  methods in a class, accessing instance variables.

  when we employ this facility we do so because it requirs less code and
  incurs less penalty of "visual noise", but it is not without its cost: when
  you see these being called from a function, it means that that function
  contains parameters that are referred to from within these "tributary"
  functions, so the particular names and general constituency of the local
  parameters of that function is coupled to all its tributaries, and so is
  easier to break if care is not taken to look at the tributaries when you
  modify the "parent".

  it is recommended only to ever have this coupling span across one level
  per variable name (i.e let's avoid sharing an ordiary local parameter with
  a function's "grandchild" tributary); lest we end up with spaghettii,
  but again, all of this is experimental, so we'll try different things, a
  lot of which will end up ridiculous.

• "variable_defined_within_current_scope"

  we use these a lot, frequently preceded by a 'typeset' statement to make
  it local. (we don't use the "local" keyword for no other reason than our
  introduction to "zsh" (that one big manual) did not introduce us to it,
  but we may change all these one day.)

  also, we may leverage the dubious feature (called a "bug" by some
  documenters) of variable namespaces being inherited downward by functions
  callees.  so think of these as semi-global sometimes. (we use this "feature"
  sparingly but crucially in a few places, almost as a substitute for
  instance variables.)

• "GLOBAL_VARIABLE"

  we are among the very few shell scripters on the planet who avoid using
  these. this whole mini-system is a test of the theory that you don't need
  these; that in fact you should need exactly zero of them.



## :#we-can-have-happiness: function naming conventions in our zsh

an interesting dynamic has grown out of the fact that the custom zsh
functions we write all share the same global namespace: because we (nowadays)
like to write lots of small, straightforward functions with descriptive names,
we thought that our namespace would get hopelessly crowded unles we resorted
to an ugly convention of fully-qualified prefixes on all function names, and
we thought that we would never have happiness.

but then something occurred to us: given that we only have one namespace,
no matter where we are we must be aware of every name ever within our process.
but as long as we always chose the "correct" name for the function we are
writing, then it will always work out: whenever we chose a name for a function
and that name has already been taken, then we should either use that existnig
function or rename both of them! maybe this is why C has remained so popular
all of these decades.



## :#storypoint-20

the below list of parameters is expected to be imported in to the namespace
of every "entrypoint" (e.g. executable script called 'build') file at many
levels of component node in the mini-system. so always consult this list
of names anywhere you are and see if the parameter you want is defined here.

we do not capiatlize the parameter names because that scheme is reserved for
global parameters (of which we intend to utilize zero or one).



## disjoint storypoints from disjoint child nodes (in creation order)

we give these their own section because we can't reasonably use the typical
"storypoint" numbering scheme for disjoint storypoints from different files.
for these storypoints from different files represented in this one collection,
we instead use the "hashtag" style locators because name collisions are easier
to avoid with hashtag- as opposed to numeric-sequence-style storypoint
locators, at the cost of having to come up with a name for the hashtag that is
maximally semantic while still being relatively immutable.



### :#pain-with-regexen-in-find

our manpage for `find` (from BSD, february 2008) explains an `-E` options,
yet the `find` on our system (whatever it is) supports no such option.
(and apparently the regex engine it uses is not of the extended variety -
there appears to be no support for the "kleene-plus" postfix operator '+' on
my `find`). the topic regex works on our system without the `-E` flag, but if
this ever causes pain we should switch to ruby for this, if for no other
reason than to reduce the number of dependencies.



### :#how-asset-building-scripts-are-typically-integrated

as to whether to implement any particular asset build script as a function or
as a standalone executable script, there are benefits to both, there are
benefits to both:

to make a stubby little function file like this one allows the asset build
script to integrate easily with its parent component node. this little file
represents the stepping off point from where the parent node has any knowledge
of how this build script works:

building an asset can be a quite involved thing in its own right, we want
such a build script to have its own variable namespace and indeed its own
entire process, with its own would-be "component node instance" to drive the
UI for for e.g building the sub-parts of the asset.

so whatever we end up doing here and below will be a response to that..

yes we could also build a custom component node to do what we do with that
one line of code automatically, and integrate a filesystem glob into the UI,
but we have to stop the madness somewhere (for now).
