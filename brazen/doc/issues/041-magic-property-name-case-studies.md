## magic formal property names :[#041]

(see also [#021] magic result shapes)

this kind of magic is certainly something that should at the highest
exist at the modality level, and generally be kept out of the model or
of [br]'s meta-API directly.


### :#the-first-case-study: CLI's stdin, stdout and stderr

in the following regards, the subject action was re-under-worked to be
the exemplary prototype of what we expect to become a widespread pattern
for the subject modality; and through this we hope to find a deeper
pattern still that we can work into The Common Modality.

at the business model level for the particular application, the subject
action is modeled as having among its formal arguments two called
`input_stream` and `output_stream`. when in the API modality, it is
convenient to conceptualize these alongside the other arguments:

   + the API action has a single point of entry: the call to the action

   + the receiver of the request can be stateless: the resources necessary
     to fulfill the action (and in this case effect the intended side-
     effects) are bundled alongside all other necessary arguments.

   + testing is simpler because we can provide for example a
     `::StringIO` object as the `output_stream` directly in the call to
     the action with no further special preparation necessary.

   + the same too for the input stream: whether for any given test the
     simplest substate is variously a string, an open filehandle or a
     mock of an interactive or non-interactive IO handle etc; this is up to
     the test to decide, and the API action is fully insulated from any
     of these concerns, needing no further intervention or special
     apriori test setup to acommodate shapes like these.

   + the above benefits of flexibility and ease-of-use for testing also
     apply when it comes to adapting the action for particular modalities.




now take the important case of adapting this action for the CLI
modality (that modality as always being the reductive case of a target
modality). we do *not* expose these particular formal properties directly
under to the generated action adapter (which forms the resultant UI) for
reasons that have a deeper lesson to teach, despite the fact that they
are characterics (albeit essential) of this particular modality:

  A) the "hop" from human to computer in this modality happens exclusively
     through the keyboard, and so the communication "substrate" (in this
     direction, and incidentally the other too) is always limited to text.

     when viewed through a wide enough lense strings have "unlimited"
     expressive power (for definitions of etc.). despite this, the front-
     user here is human so when we way "string" we mean "text that it is
     reasonable for a human to have to type". (but see #modality-idiom-A
     below.) this is all to say that at this hop we can't through our
     arguments pass "objects" or "resources" directly.

     (we discuss #what-we-mean-by-resources below.)

  B) in the subject modality these two particular formal properties
     have semantically equivalent counterparts that are so essential
     to the modality that they are "built in" as what amounts to
     univerally available resources accessible through global variables:
     stdin and stdout (and yeah stderr too but we'll discuss this
     #third-wheel below).


given A & B, in CLI it "doesn't make sense" to give these two subject
formal properties procedural exposure *to the human UI* for what is
hopefully now self-evident reasons, and perhaps others that are not:

the shell already has a powerful and elaborate set of facilities for
allowing the user to manipulate and arrange her program(s) with regards
to these resources: the human user of the shell can redirect the IO of
stdin, stdout and stderr to and from various other processes, writing
to and from files and contructing chains of quite some complexity.

this space of interaction mechanics lies squarely in front of our domain
of concern here, and so it can be effectively invisible to the application
itself. when adapting to this modality it would be problematic from every
pespective for us to do anything other than leverage these existing idioms
and interaction mechanics in toto, and we accomplish this by doing nothing
more than simply using these resources; rather than (on the one extreme)
not using them or (on the other) re-inventing any of them.

so what this all amounts to is that in our case study, `input_stream`
and `output_stream` are not granted procedural exposure to the human UI
for this reason: these properties that under The Common Modality
("back") are treated most optimally as "just any other property" both
cannot be and should not be treated as such in the target modality ("front").

these properties have characteristics that while from the perspective of
the front are so essential they get their own global variables; from
the perspective of the back this "specialness" is so arbitrary as to be
invisible.

so the onus then shifts to the target modality to implement this special
handling, which is exactly what we do here:




### :[#here.3]

on the back, change the defaults; which is a hack that accomplishes the
effect of always populating the argument box with these values of our
choosing.

on the front, eradicate the formal properties completely. we need not and
must not expose them as user-level properties there. this will settle
down somewhere near [subject document].




### :#what-we-mean-by-resources

without further justification here, we will postulate that "resource" is
an idiom that has value only in the context of the front modalities. for
now we want The Common Modality to be ignorant of this idiom.




### what about the :#thrid-wheel of stderr?

in practice historically this is a resource that we have relied upon
heavily, perhaps even more than stdout, and more than [Raymond] [1]
might like. when it comes to making [br]-powered applications, here is
where stderr fits in:

historically we like to use this "channel" for all kinds of non-payload
communication. any textual output that is not the main output your
program is expected to emit goes here. that means error messages and
informational (think: debugging) messages.

the event model that [br] effects was built specifically to accomodate
the general kind of arrangement that this specific componentiation is seen
as a manifestation of (whew).

(TODO: finish this thought)




### :#modality-idiom-A and further thoguhts

for now this is mostly a placeholder for the pattern in CLI where you
indicate a '-' for a path (input or ouput) to indicate (variously) that
stdin or stdout should be used in the place of a file by that name. this
arrangement is considered so idiomatic that we give it no further
treatment here (for now).

although we are sidestepping the above issue for now, it segways into
another one: the face that our subject action in the case study, the
fact that our action can accept a file path as input:

because for now and probably for always we want the individual actions
to be able to express special behavior for dealing with the ways that
the filesystem might be interacted with when resolving an "upstream", we
for now say that throwing filesystem paths over hops is a concern that
is outside of this scope.




## references

[1]: http://www.catb.org/esr/writings/taoup/
       "The Art of Unix Programming, Eric S. Raymond, Addison-Wesley, 2003"
