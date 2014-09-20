# the datastore actor narrative :[#028]


## :[#037]

as it stands now when an entity is unmarshalled from a datastore it is
done so by first converting the data into an iambic list and then
processing the list into a new entity via an entity edit "session".

part of the reasoning behind this is so that we grease the game gears
that we use when editing new entities that come from the interface,
especially as it pertains to normalizaiton for internal representation.

this means that validation errors may occur for whatever reason (e.g a
version mismatch between what is stored and the class that is
unmarshalling, or any number of other reasons).

we used to call the main `else_p` edge case handler in such cases. now
we simply result in the entity, necessitating that the caller check for
validity and act appropriately.
