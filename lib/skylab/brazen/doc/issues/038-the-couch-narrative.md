# the couch narrative :[#038]


## introduction

we are using couch to get our feet wet with talking to an external
API, and couch'd API is famously usable because it uses HTTP. that is
the only reason.




## #note-085

whether or not the call to the couch server succeeds we always want to
procede with the attempt at saving the collection as an entity (a
"record") in for e.g a config file.

if we don't do this, we get locked out from making the two ends match
up, in cases where they get out of sync:

let's say that you want to drop a database through the normal means of
using our interface. let's say that somehow your database exists, but
your config file got blown away. now, if you try to delete the databae
by name, it will look for it in the config file and not find it,
reporting the "unable" event.

so to correct this, let's say you go to add the database. if we followed
the convention, the subject codeponit would result in "unable" because
the database already exists, and then the caller would abort the whole
operation at that point, never reaching the part where we write to the
config file.

instead we may report success whether or not we succeeded in creating
the database so that the caller always procedes with adding the entity to
the config file.

an alternate way to accomplish the same thing is to build this logic
into the caller, which will have the advantage that the caller can
aggregated the boolean success values from these to operations into a
final success value.




## references

see natevw's [the three ways to remove a document](http://n.exts.ch/2012/11/baleting)
