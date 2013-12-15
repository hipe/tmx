# what is the deal with bundles? :[#092]

a bundle is a means of enhancing a module with a "bundle" of functionality in
a manner that is less complicated, as complicated, or more complicated as
including and/or extending that client module with another module(s); but is
otherwise comparable to this (probably), except that it is also better.

we use a bundle instead of either an instance methods module or a module
methods module for one or more of the reasons that:

  • the behavior we want to extend the client module with would live in *both*
  an instance- and a module-methods module, and we want to insulate the client
  from having to have knowledge of this fact for reasons of encapsulation,
  future-proofin, etc. (the old pattern of [#sl-111] is comparable to this.)

  • rather than adding e.g an instance-methods module to the ancestor chain of
  the client module, we may want to define a set of methods *on* the client
  module *itself*, possibly because the bundle of methods we want to add is of
  such a small number that it doesn't warrant cluttering the client module's
  ancestor chain with a whole other module.

  • the logic involved in preparing the client module for the desired behavior
  is perhaps otherwise ad-hoc in some manner not covered by above.

  • adding a "bundle" of features to a bundle instead of a "god module"
  of (either or both) an instance- or module-methods module is more scalable
  (this is proven below).

  • although your bundle is simple (e.g adding an instance method module
  to the chain), you want it to live alongside other bundles whose application
  mechanics maybe are not so simple.

## when NOT to use a bundle:

  • don't use a bundle when a plain-old base class is a better fit.
  • don't use a bundle if you would rather use a simple functions module.

## when to use a bundle, presented as a comprehensive history of the bundle:

a bundle is a generally suitable way to package any payload for your support
library that would otherwise be put into an instance- or module-methods
module (or both).

a justifiction for bundles is served by an explanation of how they evolved:
before bundles got a proper name and face, they fell under the general rubric
that came to be called "method cherry-picking", an umbrella of strategies
explored at historical [#mh-051].

the first dedicated support node for bundles was born in headless core
and coincided with the "great earthquake" of headless. to understand the
cause of the "great earthquake" is to understand the effect that bundles are
designed to avoid, so we embark on this quick history lesson:

headless had grown to provide a wealth of behavior built around some
optimistic assumptions along several axes [#094]: along the axis of "modality"
(a concept that "belongs" to headless), it assumed that you were making one
or more of an "API" application or a "CLI" application. (more properly,
headless in its scope wants to precede any notion of particular modality,
but in practice the "modality adapter" libraries are being developed in tandem
with the "pure headless" parts, because to do otherwise would be stupid; but
suffice it to say that in strict terms "headless CLI" is a bit of a misnomer,
because a CLI client is techincally headful.)

along an axis of "components", headless (before the earthquake) assumed that
your application consisted of certain components (namely, a "client" made up
of "actions", that might perhaps use some (*shudder*) "sub-clients").

but there is a third axis that we did not yet appreciate when headless came
to its first maturity, and that is the axis of "bundles": with a bundle
defined loosely as "a set of related behavior", each particulr bundle of
headless was sort of smeared all over the place and munged together with other
would-be bundles: if you wanted basic natural language expression functions,
you got that mixed in with string stylers for your particular modality, along
with anchored name-function methods, along with request invocation support,
etc.

in fact, looking back on it this was where the anti-feature of "sub-client"
came from: it was an early effort at being bundle-like. (the thinking was: if
your module should have some but not all of what a headles action or client
has to offer then use a sub-client and we'll cram everything you could
possibly want in there; and then make that a parent module of the others. it
worked well enough for as long as it did, but its ultimate utility proved to
be as a demonstrator of its own obsolescence in the face of scaling, which
has value in itself.)

in this manner headless as a support library had become monolithic: without
first realizing it, it assumed that if you wanted any bundles you wanted all
of them. then in a flash of divine inspiration the conception of the bundle
came raining down from the heavens, manifesting as a perfect storm of giant
icepicks, cleaving apart the monolith that headless had become, splintering
it into the collection of, well, bundles that it is becoming at the time of
this writing. so that's great.

## bundles in practice: \
  how to retrieve them, where to store them, how to make them

### how to retrieve bundles

the API-public way to enhance a particular client module with the bundles from
a particular API node is to send `[]` to the API node with the client module
as a first argument and an iambic list as the remaining arguments, indicating
by "name" the desired bundle(s), with any relevant argument(s) after each
name. (examples are in the following section.)

### how to store bundles

for the particular API node that wants to house bundles, as long as she
follows the above guideline ("how to retrieve them"), she may implement
the logic for the bundles' application (that is, the act of applying the
bundle) however she pleases, to an extent that satisifies all the concerns
outlines below.

this said, in practice for the API node that wants to house bundles, the
recommended way to hold them is to create a `Bundles__` module (and possibly
a `Bundles` module as will be explained below).

the `Bundles` module is simply for exposing particular individual bundles
as accessible to other parts of the universe. the `Bundles` module can be
just a plain old module. no further magic is required of it.

the `Bundles__` module on the other hand will typically want to have an
owner-node-private API with which the owner node will apply an iambic array
to a client module.  currently this can be achieved by enhancing the
`Bundles__` module with a node called `Multiset` (its location at the time
of this writing is [hl]::Bundle::Multiset). this enhancement will assume
that its client is a module, and it will define on that module's singleton
class methods that will apply iambic arrays to client modules.

the reason we call this a "multiset" is because that is the formal name for
the type of datastructure that models the behavior we are leveraging of the
`Bundles__` module: it is an unordered key-value store wherein the same
value can be stored with multiple keys. the ramifications for this are outside
the scope of this document, and haven't yet been fully explored in the wild.

### where to store bundles (case study: expression agents)

as for what particular API node should house a given bundle, each particular
bundle should "live" under the API node that "feels right", based  on a
limited but relatively long set of guidelines..

take for example expression agents. expression agent support needs to
manifest in behavior accross multiple participating components, specifically
the client-ish and its participating actions. hence the "bundle-ification" of
expression agents condenses down into two bundles: one for the "client-ish"es
and one for the "sub-client"-ishes of these clients. for the CLI modality the
expression agent bundle geared towards client-ish-es has gone to live under
"headless CLI expression". on the other hand, the expression agent bundle
geared towards CLI actions (which are sub-clients to CLI clients) lives under
"headless action".

if you are paying too much attention and/or are obsessive about symmetry, you
will have noticed a couple things: 1) the bundle for CLI clients does not live
under "CLI clients" (the API node), contrary to what you may have reasonably
expected. for another thing (2), you may have noticed that "CLI" appears in
the name of the first node but not the second bundle.

why number 1? because we had already created a dedicated expression node
to hold the somewhat voluminous expression agent logic, we chose to place the
corresponding bundle in here as well, folllwing something we will call the
"law of tightest fit":

the "CLI" node has immediately under it both a "client" and an "expression"
node. the node in question (the expression bundle for CLI clients) relates
to both of these nodes. "client" is a "component", and "expression" is a
"facet". our "precedence rules of logical taxonomy" [#094] holds that "facets"
bind tighter than "components", hence the node in question should "naturally"
go under the "expression" node and not the "client" node.

to recap: our two bundles will go to live respectively at
"headless CLI expression" and "headless action". question #2 was: why does
"CLI" appear in the name of the first bundle but not the second one? this is
because at present the expression agent bundle for CLI actions is exactly
identical to that for actions of any other modality (by design); however (also
by design) the same is not true for the bundle modules geared towards clients:
i.e this particular bundle cares about modality at the client-level but not at
the action-level. (this is the very behavior that expression agents are
designed to exhibit.)

confused? so is the author after writing that. fortunately, from the outside
our collection of bundles need not exist in a strict, perfect tree-like
taxonomy for our bundles:

#### bundles may be cross-referenced

(you may want to skip this section until you have read the following section,
about where a particular bundle should "live." this incogruity is left in the
document because the parent node of this node is otherwise placed appropriately
in a top-down narrative, which leaves the incongruity of this node ironically
apropos given the subject matter of this node, which itself won't make any
sense until you have read this node.)

it may be an exercise in futility to try and come up with a perfect taxonomy
for all your bundles in a way that is both scalable to implement while still
being encapsulated enough to allow clients to benefit from using bundles in
the first place.

this is why it is encouraged to make bundles that merely reference other
bundles as appropriate whenever there is any strain felt when deciding where
a bundle "should" live. follow these guidelines when cross-referencing bundles:

• always use the exact same (const) name for the referrer bundle name as for
the bundle being referred to (the "referrant"). if we ever come up with an
exception to this rule we will come back and edit or remove this guideline.
this is to help clients avoid headaches wondering whether or not two bundles
do same thing. (the counterpart to this, then, is that no two different
bundles should have the same const name)

• never achieve bundle reference by direct assignment, e.g:

    module MyCompany::MySubsytem
      module Bundles
        Frobulate = -> a do  # fine: you are assigning a proc to a const
          # here is the bundle logic in its home
        end
      end
      MySubsystem = self
      module SubNode
        module Bundles
          Frobulate = MySubsystem::Bundles::Frobulate  # do not do this
        end
      end
    end

now imagine that 'Frobulate' (the referrant) is actually autoloaded (i.e
lives in another file which is lazy-loaded at the time of first use).

the reason we shun the above arrangement is that in such cases where the
referrant is autoloaded, it gets loaded at the time the referrer code is
evaluated (i.e when the file is loaded) as opposed to the first time the
bundle is used. this hurts us in several ways:

  • coverage testing may suffer, giving false-positives reporting that we
  used a bundle when in fact we did not. unsing the recommended technique
  coverage testing will reveal any referrers that are not used.
  • regression testing will suffer if the referrant node breaks and prevents
  the rest of the system from running even when the referrant isn't used.
  that is, the bundle can become one small leak that takes down the ship.
  • depending on how heavy the referrant node is it will consume resources
  unnecesarily to load it extraneously at each execution (where applicable
  to the modality).

even if the referrant node is not autoloaded it may one day be refactored to
be so (e.g if it gets heavier), and the referrer node should *NOT* be privy
to this decision; i.e the referrer node *should* just assume that every
referrant is autoloaded, and hence only load the referrant at the time of
first use as opposed to eager-loading everything.

• do not cross a privacy boundary to reach a referrant.

for any node that houses bundles there exist immediately under that node
three hypothetical modules named `Bundles__`, `Bundles_` and `Bundles`, each
with their own meanings with respect to privacy. (we say "hypothetical"
because the module should not exist when it would otherwise be empty.)

this architecture convention is a corollary of the "consts with trailing
underscores.." and "extreme detail.." sections of [#sl-050], which will
probably be helpful complimentary reading for this section.

for the node that houses bundles, bundles which are applied via iambic lists,
put those bundles under a module called `Bundles__`. the two underscores
indicate that the constants under this constant are node-private -- that
basically nothing (in this case) should be accessing its child nodes directly.

in cases where a bundle wants to expose itself as the referrant of a reference
from a node that resides below the node that houses the bundle, the referrant
bundle should expose itself by putting itself in the `Bundles_` module (one
underscore).

just to be cute and over-detailed we will go ahead and make this convention
apply also to the situation where one bundle wants to refer to another bundle
housed in the same node - even in these cases the referrant should have an
entry in the `_` module: consts under the `__` module should never be accessed
directly, notwithstanding proximity such as this.

the final module in our triumvirate of privacy, the `Bundles` module, is for
exposing a bundle as part of the public API of that node -- such bundles
may be accessed directly from anywhere in the universe.

• the lingua-france of bundles is that they are proc-like.

whenever a referrer bundle calls its referrant, send `to_proc` to the
referrant. if you really want to, you can live dangerously and skip this
in the case of referrers who are child nodes of the referrant, and you
"know" that the referrant is already a proc, but be prepared for this to
break one day.

### how to make them (bundles)

  • bundles are implemented as "proc-likes": that is, something that must
  respond to `to_proc`. because so often we use a real-life proc to implement
  a bundle, we may sometimes forget to call `to_proc` on the bundle, and that
  is OK as long as the bundle's referrer came form a sub-node of the node that
  houses the referrant.

that is all for now.
