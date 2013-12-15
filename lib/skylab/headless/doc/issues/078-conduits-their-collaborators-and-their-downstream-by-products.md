# conduits, their collaborators, and their downstream by-products :[#078]

(EDIT: most of this has been superceded by bundles, but it's still
interesting, if you're me)

the goal of this node is to present the folowing terms, and relate them to
each other: `conduit`, `flusher`, `story`, `kernel`, `metaservices`.

in several places in the skylab universe we make use of `conduits`
`flushers` and `stories`, so they bear some explanation. the remaining terms
are emergent for the current project, but my bear-out broader application.

## `conduits`

the "conduit" construct is a popular choice for implementing the kind of DSL
where all of the declaration happens inside of an `enhance` block. we
typically create one such conduit class for each such DSL. to "read the
values in" that are in such an enhance block, we create one such conduit
object and instance_exec the block on it. in this way the expressions
available in the DSL exactly correspond to the public instance methods
of the conduit class. the conduit has a narrowly defined scope of
responsibility and is very short-lived: it is only used for implementing the
surface shape of the DSL, and not for storing its passed values or doing
anything with them. we hence call it a "conduit" because its only purpose is
to be a conduit of information from the (developer) client to the underlying
library. you can think of it as a method signature to a function call.
(Conduit's earliest recognizable ancestor was called "Joystick".)

Although the conduit classes themselves are API-private (being after all an
implementation detail), their public method interfaces constitute *the*
public API at the outermost level of the libraries that use them.

## the `story`, in constrast to `conduit`

the Story, then, is the model of the information gathered during that DSL
block from the conduit. The story object is the internal datastructure that
keeps track of whatever client-specific customizations happened during the
DSL block. (we have also called this 'Metadata' elsewhere. you can safely
substitute this term anywhere you see "Story" if you prefer it.)

unlike the Conduit, the Story is not (or should not) be thought of as mutable
hence it does not need to concern itself with maintaining an interface for
being edited (* at least not as far as you know).

conversely, Conduit's only job is to be written to, so it need not concern
itself about maintaining any private methods or complex internal state that
must be encapsulated.

the separation between Story and Conduit is important - it gives us a
separation of concerns, and a layer of insulation.

the separation between Story and the client (user developer) classes is also
important - it externalizes our storage of data so we don't crowd the ivar
namespace; as well it also externalizes any support method needed for (ideally
read-only) methods (e.g reflection methods), which in a plugin architecture,
are just about the most important thing! ^_^

## a `flusher`?

sometimes we may use what we call a "flusher" whose only job is to apply the
information gathered after having run the block over the conduit. a flusher
may be used in lieu of a story (in cases where we don't need to keep the
metadata for long) or in conjunction with it (in cases where there is some
amount of non-trivial logic necessary in order to enhance the given module,
logic that is outside of the scope of responsibility of both the conduit and
the story.

## `kernel`? `metaservices`?

these are expermental constructions - we might call something a "kernel" if
it is kept in an ivar and implements a lot of the detail and heavy lifting
for the class being enhanced..

we then call it `metaservices` if we also go and expose the `kernel`-ish to
the outside world for reflection. ("stories" have been used to this end
before.) the reason we put the "meta-" in front of the "service" is because
in the domain of plugins, just plain "services" are a businessland concern.
("metaservices", then, are services whose job it is to reflect and possibly
mutate the colleciton of services (among other facets)).

## in this application (er., library)

we are going to see how it feels to work with only conduits and metaservices.
working with the metaservice class will feel like working with a story.
