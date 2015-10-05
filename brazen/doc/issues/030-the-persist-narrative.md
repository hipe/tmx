# the persist narrative :[#030]

## persisting one entity

"create" is a [#ba-041] "universal abstract operation". the fact that
we chose the word "persist" and not "create" says that this must mean
something different (at least somewhat) from plain old [#030] create.

when persisting an entity to a collection we must distinguish between
whether we're adding a new entity or notifying the collection about a
change to an existing entity. even the simple [#ca-061] box uses this
distinction. in fact, we will go ahead and use its two verbs: "add" &
"replace".

despite this important dichotomy, it is useful to be able to refer to
to either or both of these operations with the more general "persist"
label, as long as we remember what this term represents: it stands as
a placeholder so that we may make the distinction further on down the
pipeline.


    persist_entity [ <x>, [..] ] <entity> & <on event selectively>


in breaking tradition with the stricter UAO's that take only required
parameters we stipulate that the implementing method *may* accept any
number of additional parameters (required, optional or globbed as may
be desiged) so that both imlementation-specific collection identifiers
and "adverbs" may be passed, that may be necessary to effect behavior
beyond the information containted in the entity.

failures must issue a potential event into the [#069] selective event
listener and result in the result of the callback.

successs must result in trueish and should result in true. whether or
not to emit events on success is a design choice (but Eric S. Raymond
would probably recommend [#sl-145] not to).




## the full stack (at this moment)

because a "persist" typically requires more datapoints than the other
UAO's (stream, delete), it can be a challenge to design interfaces of
the participating methods that take enough arguments to implement the
desired behavior while still feeling flexible enough that they do not
seem locked-in to the framework.

[br] goes thru an intentionally tall stack of public API method calls
to implement this operation allowing every participtaing component to
implement the particular method call however it will, perhaps even by
broadening the signature of the method.

as a guide to this end (and at risk of writing brittle documentation),
here is that stack (first relevant call at top):


    <action> `produce_result`

    <action> `via_edited_entity_produce_result`

    <entity> `persist_via_action` <action>, & <common>

    <entity collection> `persist_entity` <bx>, <entity>, & <common>

      # (the particular collection component usually does a lot of work)

    <entity> `intrinsic_persist_before_persist_in_collection` <bx>, & <common>

      # (and the particular collection usually finishes the operation)



the set of all concerned players in the above consists of the action,
the entity, the collection, and the argument box. we made efforts to
keep the design of these methods as minimal as reasonable, such that
they receive as little datapoints as necessary to effect the desired
behavior for "most" use cases; however the particular user application's
particular model silo may certainly need to override one or more of
the above, perhaps even changing signature (but do note that the boxes
above are typically mutable and so can be uses as an ad-hoc dictionary).

so the above may be used as a guide when determining exactly where in
the pipeline is the right place to override these methods when it it is
necessary.




## musings on the word choice

"write" sounds too much like writing a file to a filesystem. "save"
sounds too much like we are using a PC in the 1980's. "store" is OK but
again it hits close to "storage and retrieval" which is a paradigm we
overlap with but do not quite fit cleanly into.

if we were really cool we would not have to call "persist" at all: the
object graph could just write itself entirely "at the end" (of some
kind). but we are not here to write the next killer ORM (for now).
