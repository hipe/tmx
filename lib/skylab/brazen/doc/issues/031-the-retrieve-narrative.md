# the retrieve narrative :[#031]


## retrieving one entity

### imagine silos representing themselves to one another

consider that each model class is pictured to live at the top of a vertical
"silo" of the tiers described in [#025]. now imagine that one silo exists to
model an entire datastore (which is fine). (some prefer "adapter".)

now imagine that some other silo exists to model some particular
business entity, and it decides to store itself in the datastore represented
by the first silo.

it order for the second to get back data from the first it will have to
identify itself in terms of its model. when this is necessary, for now
we accomplish this by passing the model class itself *or* using an
"identifer" object that in some way identifies the model as well as the
identity of this entity.


### what's in a name?

we hope to use natural keys and we hope that those fields are always named
'name'. we hope never to support compound keys.

for now we will assume natural keys, and hope that an entity can
represent itself unambiguous,nly with the combinaton of its name and its
model class (with emphasis on "for now").


### receiving events

for now it is not practical to assume that the collection controller
exists only to serve the interests of the caller: although it may be
"wired" (that it, it may have an event recevier inside of it), we will
not assume it is wired for us; because to do so would limit us in at
least two ways:

1) if the collection controller is already wired with an event receiver
internally, we have no control of who the receiver is or what the event
model is, or what the handlers do in the case of the various events that
may occur.

2) in a long-running process with perhaps multiple silos querying the
same datastore, it may be impractical (or just too much code bloat) to
model this as having one collection controller per query.

(were there ever to come a time that we did indeed want a collection
controller with an event receiver of our chosing, this would be
trivial to implement but note it would mean an interface change from
what we are describing here.)

as such, we instead opt to pass a single event handler proc (optionally)
with each call to our method, implemented as a block.

we will say that never should there be a good reason to make a loud
failure from such a query, so in the event that there is no event
handler block passed and something terrible happens, we will just
quietly result in nil or false (whichever we feel like).

the possible events we expect to emit from such a query are things like
"not found" and "multiple found".


### the signatures

and so, given all of the above, we have:


    entity_via_identifier <identifier>, <event receiver>


`identifier` is a interface that is currently evolving, but will
probably be something like a symbol name of the model class and a string
name for the entity's (natural key) `name` field value.

not all collection-like silos are multi-model. a collection may be designed
(or produced) to hold only one kind of entity, in which case the identifier
will only be used for its pertitnent part.




### thoughts on the use of the verb "produce"

(EDIT: before we even commited the document we changed the name to
[nothing]).

you might be wondering why we don't call the thing "retrieve". but first:

we don't use "get" for reasons that will one day be [#hl-095] explained.

"fetch" is ok, but the semantics of this family of method names are almost
exclusively that this takes exactly one key-like argument. so it's close
but not quite the right fit.

"lookup" is a lower-level term that we often use internally.

for a long time we favored the "retrieve" verb in this family of method
names because it evoked "storage and retrieval" which is usually what a
collection is a façade for. however we eventually came to appreciate that
a collection controller is a more abstract façade than even that:

consider the old "data-mapper" ORM that was once offered up as an
alternative to active record. one particular innovation it proffered
was the isomorphism between database "entites" and the runtime's
objectspace (that is, memory): entities that came up from the datastore
would exist one-to-one with objects in the runtime's memory. if you got
back the same result entity in two different queries, it could give you
a reference to *the same* object, which, depending on what you are doing,
could be useful.

the "collection controller" façade exists as a simple, solid wall with
very few holes of very particular shapes, behind which similiar kinds
of innovations could be developed: maybe you are querying a relational
database, maybe you are querying a key-value datastore, maybe you are
even querying an in-memory database like memcached or even some crazy
future combination, or things we haven't even thought of yet.

the point is, to say "retrieve" implies that you are putting work into
going out and getting the thing and bringing it "back". in fact we may
not have had to travel very far to get the thing. to say "produce" and
not "retrieve" is a reminder that we don't know how we are getting the
thing, only that we have a common interface for how it is to be gotten

we say "via" and not "by" in order to adhere stronly to our own
conventions, but we will likely change our minds on this point.
