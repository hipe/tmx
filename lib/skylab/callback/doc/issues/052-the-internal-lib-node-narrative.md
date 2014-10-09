# the "lib" adapter layer narrative

## about this document

we are able to compose about half of this document from excerpts of recent
commit messages. rather than spending our resources re-wording ideas that are
still relatively fresh (which is to say un-incubated), we will for now present
those excerpts intermixed with new content.

those paragraph below that are such excerpts are the paragraphs preceded by
"•" bullets. hopefully we will mainstain some semblence of narrative coherence
thru all of this.



## the "lib" facility in the context of today

in light of recent efforts to port portions of our subsystems forward to
"rbx" compatibility we got a pointed lesson on the age-old truism about
tight coupling being a libility. this gave us a newfound appreciation for
the utility of our widespread "library adapter layer", hence this document.

• "tight coupling" here means pulling in the side-system directly as we often
  do in the top-node of any sub-system and certain "fundamental" side-systems
  it thinks it 'needs' to operate.

• so the thing is, this mess with migrating to rbx, if it happened before it
  can happen again: it is not the case that we should presume it is safe for
  virtually all "subsystems" to wear the same hat, namely "skylab.rb"

• the new pattern is: *every* "outside" dependence happens through the
  "library" adapter layer. from inside out this insulates the system from
  outside change by giving one layer of indirection and a centralized
  interchange, in theory assuaging future pain of refactoring.

• as we need "subsystems" to be compatible under 'rbx' (or 'jruby' or
  whatever; no literally whatever) we don't have a mini dependency hell to
  untangle: in a piecemeal manner we can one by one (in this example) unplug
  the subsystem from the oldschool autoloading and plug it in to the new-
  school autoloading (but replace "autoloading" with "facility X").

• this has an interesting corollary benefit: the innards of [hl] need not and
  should not know where particular library nodes live in external subsystems.
  the "Library_" module then acts as a layer of indirection, insulating the
  innards from the kinds of changes we are going through now; and outwardly
  providing a contract/ manifest of the external things we need"

• this "contract" (from both directions) lives in one file, which has
  foreseeable benefits and disadvantages both that we hope to weigh variously
  with this experiment.

a benefit of the above point is that (assuming the library has no uncovered
(unused) code), at a glance we can see all of the external dependencies that
the subsystem has, not only in terms of what the sidesystems are (and stdlib
and gems) that it needs, but what sub-parts of those side-systems it needs.

(this last point is a benefit we did not utilize as fully in the old
"Services" era of this pattern.)



## the new "litmus" test for this kind of purity

this might be overdoing it, but a "litmus test" to determine if your subsystem
has de-coupled itself to an absurd degree from the rest of the ecosystem is
this: for each "side-system" that it utilizes, do a search for that const
in your subsystem. ideally (and we mean that with all its negative
connotations), you "should" see those consts appear exactly once: in your lib
node.

the rest of the instances of that side-system being used by your subsystem
"should" occur thru the function-points of your library node.



## history

this pattern started as the pattern of us working with a node called 'Services'
that held one constant for every outside "service" that the subsystem depended
on.

(#todo: it would be fun to track the early history of this)

we renamed it from "services" to "lib[rary]" because the term "services" got
overloaded, and b) wasn't quite the right term.

in its philosophy and underlying semanatics it has remained largely
unchanged since its beginning, but over the years we have formalized its
purpose, come to better understand its utility, and employed some variations
of its implementation.



## "Lib_" and "Library_" end in underscores

per our [#hl-079] name conventions, such a name indicates that the node is
protected by the node that contains it. we employ this convention here because
"library" nodes are not for the outisde world to know about: they are an
implementation detail of that subsystem.

because almost by definition, the parts of the library are used by many child
nodes of the subsystem top node (or whatever sub-top node it is that "has" the
library) the library is protected and not private. (it would have to be an
inappropriately large class or module indeed that needs a private library all
to itself, so a private library is something that it is safe to say you will
never see; much in the same way that a private library in the real world is
almost (but not completely) an oxy-moron).



## "Lib_" vs. "Library_"

"Library_" is for the old-school implementation where we use a const-missing
"hack" to (somewhow) load a ..er.. constant when it is missing, on demand.
there exists a variety of ways this has been implemented, but at its core it
is a const_missing hack.

"Lib_" the a newer style where the library is simply a module that contains
constants that point to procs. the procs are often some kind of memoizing
thing that loads the external resource on demand and caches the result.

it is up to the discretion of the subsystem which style to use, but it is
stronly recommended that you do not mix styles in the same library. (but it
is OK to have many libraries in different places or with differnt names in
the same subsystem. this is part of the reason we use these two different
names.)


• the "Lib_" style may be perceived as more "direct" and less "magical" and..

  • when someone says "what is going on here", they may be more likely to
    answer their own question with this style

  • because a lib module is nothing more than a hash-like collection of procs,
    they can be thrown around easily as functions that are first-class objects,
    making it trivial to nest different 'lib' nodes in the same big subsystem,
    and to 'inherit' downwards certain elements from super-libs to sub-libs.


• the "Library_" style may be seen as easier to read

  • because in the case of modules you don't have to use the [] to
    "dereference" it

  • but note that the difference is negligible in the case of proc-likes
    (as opposed to module-likes) in your library, where you will be using
    the '[]' (or 'call') anyway.


In practice, the strong convention has become to use a "Library_" node for
gems and stdlib libraries, and "Lib_" for libraries and API "portals" for
going from inside the subsystem out to other sidesystems. this is because
given how relatively little the former changes and how relatively frequently
the latter does, we use the former for its readability and the latter for
how amenable to change it is.

_
