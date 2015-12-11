# (quick definition of "modality") :[#002]

we lean so heavily on this term in this universe that it has become
something of an idiom. rougly it means "kind of interface." it is an
attempt to model a taxonomy of user interfaces.


    |                                                        NLP AI agent
    |
    |                                          Desktop GUI
    |                                       Mobile/Tablet/Phablet
    |                                     Watch!
    |              Web
    |
    |    CLI
    |
    |  "API"
    |
    | (complexity of implementation -->
    +----------------------------------------------------------------------

our obsession is with what these disparate "modalities" have in common..





# introduction

    Invocation__
      ^    ^
      |     \--------------- Action_Adapter_
      |                           \
    Branch_Invocation__            \
      ^            ^                \----->  Adapter_Methods__
      |             \                        ^
      |              \                      /
    Top_Invocation__  \----- Branch_Adapter__

    (the associated "class-digraph.dot" also depicts the above.)


This model grew out of literally years of rewrites.

the first node created is the top client. the main function of this node
is to resolve one of many child nodes to field the request. the top
client will dispatch the well-formed request to one of its children.
this child will be a leaf node or a branch node. when branch node this
process will be repeated recursively until a leaf ("terminal") node is
resolved.

the top node and the non-top branch nodes are similar but not the same.
the top node is like a non-top branch node with some added
responsibility and public API methods. likewise the non-top branch node
will have behavior that is different than the top node, namely that the
former has a parent and the latter does not.

leaf nodes always have parents and never have children hence they are
different from the other two kinds of nodes discussed so far. however
all three have behavior in common, namely that they all parse options
and output help screens.

hence, 'invocation' is the abstract base class to rule them all. 'branch
invocation' is yet another abstract base class childing off the first,
that implements the branch-specific behavior. the top client and the
non-top branch nodes each have their own class childing from that.

for the terminal (leaf) nodes, we have yet another concrete class
childing from the basest base class. since the "concrete" leaf and
branch nodes both have some behavior that is common to them but not the
top node, this behavior is put into a ("mixin") module.

it's that simple.




## :#an-optimization-for-summary-of-child-under-parent (:A)

in practice so far, something like only 1 out of 50 adapters
needs to build its own expression agent when that of its
parent is already built and available. possible reasons it
would still need to use its own expression agent might be:

  • that it renders surface representations of its formal
    properties (in the first two lines!)

  • that it uses an expression agent class (or other
    instance) different than that of its parent.

the reason we sidestep this unless necessary is for the 49
out of 50 cases, we can avoid doing unnecessary (and
relatively costly) property catorization (and the less costly
building of the new expag) just to get those 2 lines.




## the "error level" can increase but not decrease :#note-075

for the lazy. every action invocation may trigger multiple events, but
can only result in one exit status. we derive the exit status from the
events. how to reconcile the two is the subject of this soliloquy:

it may be that we set an exit status with each of several polarized events
we receive (events where `ok` has been set to true or false). if
this is the case, what are we to do if we once set an exit status to be
some error code, and then subsequently set it to be 0 (success)? or if we
once set it to be one error code, and then later set it to another?

our "meh" solution for now is that in the case of collision, we
effectively allow the exit status (or perhaps more fittingly "error level")
to be increased but not decreased. at best it will prevent us from masking an
error with a subsequent success. at worst it will mask less specific
errors with more specific errors.

but the bottom line is, if a client needs more precise control of what
the exit status is, relying on inferred exit statii is not the way to do
it. and because exit statii are the domain of CLI (and perhaps some
arcane sort of API), and these are conceived of as modalities, precise
control of exit statii is then beyond the scope of this project, whose
goal is to generate modality-specific interfaces as a byproduct of the
model and its behavior.

to put it another way, if we can't find a meaningful and direct
isomorphicism from model state to interface state, then we don't really
care about it.

the reason we use `instance_variable_defined?` instead of setting the
exit status ivar to nil in the initialize method is so that it is left
unset so we can more easily track when & where we fail to set it.




## experimental generated syntax aesthetics :#note-575

experimental aesthetics - when there is nothing filling the
trailing optional arg "slot", let a would-be option fill this spot.

the general trend here is to try to get properties out of the options
and into the arguments if possible. it looks nicer and reads more
cleanly, and is a fun and silly challenge.

(a) if we mucked around with globbing arguments already, then don't
bother here. you can have multiple trailing or leading optionals (a structure
we will never produce here) but you can't have one 'many' argument in
conjunction with any other non-one-aritied arguments.

(b) when there are as yet no args at all, we have nothing to lose by
putting one of the opts into the last "slot" of the args.

(c) even if there are alreay args there, we assume that none of them are
already globbing or optional, because otherwise they would have been handled
by the "many" logic earlier, or not fallen into the arg list in the
first place because the qualifier for this list is that the property is
"actually required". in such cases EXPERIMENTALLY we go ahead
and make the transformation to put the last option in with the args as a
trailing optional.




## method note about help screen rendering :#note-930

contrast with leaf implementation (covered). without this, this adpater
renders exactly as a terminal action, which has slightly different styling
than we want: we want the invite line to invite the deeper usage, and
hence we do not need the option section explaining the options (because
it is redundant.)

incidentally, at writing this *is* the only method that appears
necessary to exist in the branch adapter class that it does not inherit
from the graph already. i.e, without this one method, the branch adapter
class would be purely a composite of subclassing the one class and
mixing in the other module (see "[#]/figure-1").





## property categorization (:E)

a central feature of [br] CLI, property categorization is a concrete
manifestion of the whole underlying [br] experiment, one that traces its
lineage years back to [hl]: the model models its actions' properties
with metadata that is processed by "modality inference" to make design
decisions about how to express the various properties using appropriate
modality-specific mechanics.

in an imaginary simple implementation that still exhibits our main
objective, each property would either be optional or required. each
former would be expressed as a CLI option, and each latter as a CLI
argument.

while this would work for some actions, it has some aesthetic and some
functional shortcomings:

  • under some circumstances, the (any) final would-be option can be
    expressed as an optional positional argument (more on this below),
    which is more usable.

  • properties with polyadic argument arities (i.e those that take
    more than one value) are most usable when they are expressed
    (when possible) as globbed positional arguments.




## :#note-610

sadly we still have some cases to filter out. in the cases where
properties are actually "officious" options (things like --version and
--help, actually more like actions than options); we don't want these to
become arguments. this could stand to be improved.




## Spot-1

fields that take optional arguments are a nastly class of formal
properties that we only support because we have to because of their
analog in option parsers that support them. they have no known analog
in other modalities.

  • because of this we prefer to conceptualize them as two
    different mututally exclusive formal properties with the same
    name, one being boolean-like and one being argumentative. but
    that's a personal choice that has no palpable consequence.

  • perhaps ironically the very existence of this class of formal
    properties being supported by option parsers is what led us to
    develop the theory of argument arity and parameter arity.

from here (or anywhere) the only way to know which form of the formal
parameter was employed is to test if it is equal to `true`. (this
because of the stdlib optparser.)

this sort of situation is what our "known known" structure was made for:
the clientstream will know *that* this formal property was engaged by virtue
of the existence of the known known. to know *whether* the one form or
the other was used it can infer this from the true-ish-ness of the
value.




## :#GEC - generated event contextualizations

this has now become a "redundancy pool" with:

  • [#hu-043] the API Action inflection hack (a "feature island") -AND-

  • our [#083], a "feature island" -AND-

  • [#ac-007] a small implementation there (the newest)

so that's *four* implementations of pretty much the same behavior,
with *two* that are #[#sl-134] "feature islands" meaning they have test
coverage but aren't used anywhere in production.
_
