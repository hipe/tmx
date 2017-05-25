# the digraph session architecture :[#021]

## design objectives:

  - so that our design encourages (enforces even) us to be good
    citizens that release resources when we are done using them;

    also so that any current or future [possible] problems stemming
    from concurrent-access fail loudly instead of silently

    (when we want to allow concurrent reads, we can phase that in.);

    whenever a digraph corresponds to a file on the filesystem, all
    interactions with it (read-only and read-write alike) must now
    happen within an exclusive, locked-file session.

  - provision this same centralized point-of-access for all digraph
    "sessions", regardless of whether or not the filesystem is
    involved. realize file opening, file locking, and file closing
    as an implementation detail: all performers outside of the
    subject must be insulated from any knowledge of it to the
    furthest extent reasonable.

  - give the client some kind of straightforward confirmation of
    whether something failed, and whether the document was written
    as applicable.




## broad corollaries of our objectives:

  - we must know explicitly for all interactions whether the option
    may be needed of writing the graph (read-write) or whether this
    access is read-only. (we don't encounter write-only only because
    of how digraphs are always created (on the filesystem) in a
    dedicated invocation ("graph use") which is out of this scope;
    that is, the file (when applicable) will always have already
    existed when you get here.)



## considerations:

  - although emissions are emitted in an unsurprising way (for both
    successes and failures), it's awkward for a client to have to
    to intercept emissions to determine basic result status.

  - on one hand we want our result shape to be consistent whether
    or not we are in read-write mode; but on the other hand: when
    in read-only mode it "feels" more straightforward if our result
    is just the user result with no additional wrapping. we follow
    the latter currently. :#here1 (and extrapolated below)




## our responsibilities:

  - whether we are in read-write mode or read-only mode determines
    whether we will attempt to write the document. to state
    explicitly what may seem obvious, we never write to the document
    when in read-only mode.

  - if we ever do double-writing with a tmpfile, the subject node
    will be the sole agent (but not performer) of such work.
    (#wish [#007.D])

  - in all cases involving files (including non-exception errors),
    we must close the file (so the lock is released). (but note we
    abstain from writing to the file when we detect a user error.)

  - in cases where the document was written (filesystem or no),
    result is metadata about the write (e.g how many bytes) but also
    the result includes whatever the user resulted in; all in a
    struct. (see #here1)

  - in success cases where the document was not written, result
    is just user result. (justified at #here1)




## finally, a tiny gotcha:

  - to keep things simple but still adequately powerful, client
    MUST result in `nil` (not `false`) IFF something failed.
    `false` will always be interpreted as being a meaningful boolean.
    `nil` can never be used as a valid result from the client.
    its only possible interpretation is failure, and failure's
    only absolute expression is through a result of `nil`. (but all
    this applies only to clients of the subject.)




## supporting non-file BSR's (byte stream references):

(normally we avoid creating or using local acronyms, but [#ba-062.3]
byte stream references are so common here, we make an exception. see
manifesto.)

the subject was conceived of as a central, unified way to manage
file opening, file locking, file writing and file closing as it
pertains to digraphs. while this remains its central "mission", we
also want this to be the central means of accessing digraphs
generally, not just digraphs that live on the filesystem.

when the argument BSR is something "primitive" like a content string
or an array of lines; it is then passed as-is to the other performer.
BUT if it is a path or an IO (and we think that covers all the kinds
of BSR's we care about), then we lock it here and pass the BSR
wrapping the locked IO to the performer. (away this at #open [#098])

    - if content string, we do no locking, we do no closing
    - if array of lines, (same as above)
    - if open IO, we DO locking, we DO closing
    - if path, we open it, (then same as above)

the point is that for writing and reading alike, it is not the other
performer's responsibility to know about file modes and file locking;
it is ours and when locking applies it is also our responsibility to
release the lock by closing the file (or closing the file in any case
as appropriate).





# the document entity narrative :[#here.B]


## #args-partitioning

from a classified argument scanner put each relevant argument into
a bucket corresponding to its direction: input arguments in one
bucket, output arguments in another and so on *for the arbitrary
list of directions provided by the caller*, expressed as symbols.

this list of direction (symbol)s may be derived indirectly from
the list of formals, by reducing the formals to the set of all
unique directions that all formals classify under. (directions and
formals are many-to-many.)

• an actual will go into more than one bucket as appropriate IFF
  its formal is classified under more than one direction (e.g the
  workspace-identifying properties, because a workspace can express
  both an input and output identifier (the same graph path)).

• experimentally we use :+[#br-021] "name magic": if the property
  is not officially a "document property" but its name looks like
  it is, we represent it interally with an "impersonator" property.
  no, actualy, we don't. we have meta-properties so we should use
  them.




### introduction to declarative compound validation

we are familiar with an ordinary expression of "required-ness"
whereby we declare some particular formal properties as "required",
and for those formal properties that have no provided counterpart
in the actual properties, we short-circuit out of further processing
and emit a normalization-related event. this makes life much easier
further on down the pipeline, when we may procede with full knowledge
of all our known-knowns and known-unknowns.

formally we model "required-ness" as a function of "parameter arity":
a required property is one with a parameter arity whose floor is
one or greater. (here we may think of "arity" as simply a range.)

another conceptual component to our formal validation model is
"meta-properties". for the purposes of our discussion here the only
meta-properties we care about are "direction" and "shape", to be
discussed further below.

the primary value delivered this whole mechanism stems from this one
axiom: that across a given set of directions, the "arity" for each
such *direction* is either "zero-or-one" or "one". normalizing the input
arguments for a relevant action involves effecting these arities for
each such direction.

this is like the ordinary expression of "required-ness" expressed at the
intro, but rather than a *property* expressing the required-ness, it is
this (perhaps imaginary) *meta-property* that is the selector: we need
an actual argument whose formal property is not a particular property,
but rather is classified by this particular meta-property..




### understanding the axes of validation thru an example

imagine an action with the formal properties `input_string` and
`input_path`. these formal properties each have formal meta-
properties "direction" and "shape". for the first formal, the
actual meta-property for "direction" is "input", and that for
"shape" is "string" and so on.

as a side note, we could deduce the two actual values for these
two meta-properties for any given formal property name symbol
given for example an exhaustive list of shapes alone (or an
exhaustive list of directions alone) but we don't do this for reasons:

we added in this "magic" behavior experimentally at one point,
but then removed it, because as experience has suggested to us,
thinking of any such list as "exhaustive" is usually a whisper from
tomorrow's massive overhaul. it it better to leave the formal
property namespace wide open to business and use the meta-property
facility to this end.



### how arity of "not more than one" is effected

knowing only what we know so far, imagine now that actual properties
(the actual arguments) to the action are provided for both
`input_string` and `input_path`. given that both of the formals for
these actuals are classified under the direction of "input", that adds
up to two actuals that express input. but given our axiom above, the
count of actuals for a given direction cannot exceed one. hence, this
sort of input is classified as an unrecoverably ambiguity.

to put it more naturally, for this action we must resolve some form of
input, either by string or by path, but not both.

not all ambiguities are un-recoverable. ambiguity resolution will take
into accout the #trump'ing rules mentioned inline, whereby some arguments
trump others to resolve the ambiguity by rules whose input comes from the
formal property's meta-properties.

for example, workspace-related properties when treated variously as
input or output properties will get trumped by input- or output-
specific properties, because these latter are more specific, and
specificity is a (derived) meta-property that can resolve ambiguity.

this arity assertion of "not more than one for a given direction" again
stems from an axiom and so this normalization comes "for free" and is
ubiquitous (i.e not optional).




### how arity of "at least one" is effected

the phenomena that go into a normalization like this lie at the
underpinnings of what formal properties are necessary for.

we cannot know that we don't know something unless we already know
about it as a thing. we may then perhaps make a distiction between
"informed ignorance" and "true ignorance" ("i don't know Korean, but
I know that Korean is a language that I do not speak." vs. "asbestos
makes a good insulator. / let's paint the dials of this watch with
radioactive paint because it glows in the dark.").

(we can go further and say that it is ipso-facto impossible to be
self-aware of one's own "true ignorance" about any given topic,
because once he or she discovers the fact of ignorance, she then
achieves the state of "informed ignorance" on the topic. but that's
probably not relevant.)

so, to be able to say that we don't have something, we have to know
that that something is a thing. the way we do this here is through
a formal properties collection. note that thus far, we have
accomplished the normalized described by inspecting *paritcular*
qualified knownneses, that is, the tuple of 1) a formal property with 2) knowing
whether we know or don't know its actual value and 3) if 2 is true,
what that actual value is.

having simply a list of qualified knownnesss can accomplish the normalizations
described thus far, but depending on how the qualified knownness collection was built,
its underlying set of formal properties may not reflect the complete
set of formals for the particular (for e.g) action.

what we are leading up to is this: we determine the set of required
properties [somehow] by looking at the formals. the formals are not
necessary for performing all normalizations, but they are for this one.




#### how each particular bucket is sorted

if the normalization gets past the formulaic arity assertions above,
the resulting "buckets" (arrays) for each direction may still possibly
have many items. this happens when there are actual arguments whose
formal properties are classified with direction but are not direction-
specific and not "essential" (a specialized meta-property created for
this concern.)

this provision is made to allow for those input- or output-related
entities that are expressed through multiple properties, like
workspaces. in such cases (as well as any other), the bucket list is
sorted such that its "leader" argument is in front, and any ancilliary
arguments trail behind it.






### why meta-properties are necessary

it "almost" seems as if we could construct this whole mechanism
automatically outwards from a simple list of "shapes" - given
e.g [ "string", "path", "stream" ] we could do an absurd amount
of magic on the formal properies, actual arguments, whichever;
to apply the above logic without using explicitly declared meta-
properties (formals and values). the resons we do not this are
manifold:

1) these name patters are broad. to apply unilaterally this
treatement to all formal properties that end in `_path`, for
example, is impractically limiting.

2) we have "compound", "indirect" stream entities that we express,
namely, the workspace. the workspace can provide both an upstream
and a downstream identifer, yet (EDIT)





## document-meta:

  - #history-A.1: spike this with a splice of 100% as much (more) content,
    that came in from inline comments; while at the same time realizing
    that the existing content that was here was largey redundant with
    another document.
