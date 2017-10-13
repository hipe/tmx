# the shell and kernel metaphor :[#078]

(#open [#047]: this feels "gone" (as a convention) but what has replaced it?)

# history and context

we used to say "conduit" and "flusher" instead of "shell" and "kernel",
but once the latter terms occurred to us, our decision to replace all
occurrences of the former with them was immediate because of how ready-made
the kernel/shell metaphor already is, and how aptly it characterizes the
meaning we are after (although we will miss "conduit" because of how cool it
sounds).

confusingly before we made the change we were already mentioning "kernel" in
this document because of the limited if not widespread use it had seen as a
term contemporary with "flusher" (the term it has now has replaced). so it may
seem weird or redundant in places.

additionally, at one point we said "most of this has been superceded by
bundles, but it's still interesting, if you're me". now this is a #todo:
in light of this reconception we need to make bundles fit into this document
eventually.



# shells, kernes, their collaborators, and their downstream by-products :[#078]

the goal of this node is to present the folowing terms, and relate them to
each other: `shell`, `kernel`, `story`, `kernel`, `metaservices`.

in several places in the skylab universe we make use of `shells`
`kernels` and `stories`, so they bear some explanation. the remaining terms
are emergent for the current project, but my bear-out broader application.



## `shells` (formerly "conduit", née "joystick")

the "shell" construct is a popular choice for implementing the kind of DSL
where all of the declaration happens inside of an `enhance` block. we
typically create one such shell class for each such DSL. to "read the
values in" that are in such an enhance block, we create one such shell
object and `instance_exec` the block on it. in this way the expressions
available in the DSL exactly correspond to the public instance methods
of the shell class.

the shell has a narrowly defined scope of responsibility and is very short-
lived: it is only used for implementing the surface shape of the DSL, and not
for storing its passed values or doing anything with them.

we hence used to call it a "conduit" because its only purpose is to be a
conduit of information from the (developer) client to the underlying library;
but now call it "shell" because we want to piggyback on the shell/kernel
duality that is already a strong concept from the domain of operating systems.

you can think of the shell as the method signature to a function call.
(Shell's earliest recognizable ancestor was called "Joystick".)

although the shell classes themselves are API-private (being after all an
implementation detail), their public method interfaces constitute *the*
public API at the outermost level of the libraries that use them.



## the `story`, in constrast to `shell`

the Story, then, is the model of the information gathered during that DSL
block from the shell. The story object is the internal datastructure that
keeps track of whatever client-specific customizations happened during the
DSL block. (we have also called this 'Metadata' elsewhere. you can safely
substitute this term anywhere you see "Story" if you prefer it.)

unlike the Shell, the Story is not (or should not) be thought of as mutable
hence it does not need to concern itself with maintaining an interface for
being edited (* at least not as far as you know).

conversely, Shell's only job is to be written to, so it need not concern
itself about maintaining any private methods or complex internal state that
must be encapsulated.

the separation between Story and Shell is important - it gives us a
separation of concerns, and a layer of insulation.

the separation between Story and the client (user developer) classes is also
important - it externalizes our storage of data so we don't crowd the ivar
namespace; as well it also externalizes any support method needed for (ideally
read-only) methods (e.g reflection methods), which in a plugin architecture,
are just about the most important thing! ^_^



## a `kernel`? (formerly "flusher")

sometimes we may use what we call a "kernel" whose only job is to apply the
information gathered after having run the block in thru the the shell. a kernel
may be used in lieu of a story (in cases where we don't need to keep the
metadata for long) or in conjunction with it (in cases where there is some
amount of non-trivial logic necessary in order to enhance the given module,
logic that is outside of the scope of responsibility of both the shell and
the story.



## `kernel`? `metaservices`? (this "kernel" is the earliest one)

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

we are going to see how it feels to work with only shells and metaservices.
working with the metaservice class will feel like working with a story.
