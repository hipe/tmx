# the API narrative :[#006]

## action loader stubs :[#026]

this again.

in a short- (and hopefully fast-) running process like the typical CLI
invocation (or even a "raw" invocation by a test), without the subject
enhancement, for the API to process the request of the front- (or
human- ) client, it must load every action of every model (and allocate
memory for each of their every properties etc) on every request.

this both effects responsivenes and introducess unnecessary load
dependencies; and does so proportionally worse at scale.

with this, the model makes it look like it has loaded its actions
already by placing these lighter weight "stubs" in their place. the first
time `.new` is called on one of these stubs, the file is loaded.

the costs of using this is:

  1) many assumptions are made about the metadata of your action..

  2) weird issues can crop us if loading doesn't trigger when you
     expect that it should have


this enhancement is in a memoizing proc so that we don't load brazen
right away at the top of the application (again to avoid load-
dependencies).

things like this exist in [tm] and probably elsewhere. we aren't event
considering trying to unify this pattern yet because of how chunky it is
(ok we are *considering* it but that's all).

in the future we may try to simplify this to leverage peeking at the
FS instead of needing to construct the stubs "manually".




--------------

(EDIT: all of the below is made historical by the advent of [br])
(and should probably be merged into [br] for some of its ideas)

at the time of this writing the API "client" is conceived of as a
would-be long-running (daemon-like) process that would possibly serve
serveral clients in tandem.

its two main functions are 1) in a config stack it may serve as the
lowest frame, that is the last-line-of-defense defaults for business
constants or configuration values. (EDIT: it is no longer recommended
that any business defaults be kept in any top-level node within the
application. such concerns belong at the model level at the highest.)

2) it provides the "models" shell, which in turn provides shells with
which the clients may produce silos, silo controllers, collection
controllers, entity controllers, etc.

externally there is both the 'API' module and a class 'Client' within
that module. internally they are the same class for one reason of
convenience but this is subject to change.


the primacy of the API client is evinced by the arguments to its
constructor: it is built only with a reference to the toplevel business
application module and nothing else (no references to system resources
like stdout, no configuration files etc).




## :#note-25

keep the new name function from infecting upwards passed this point



keeping for #posterity, primordial boxxy:

    path.reduce(self.class) { |m, s| m.const_get(constantize(s)) }.new(self)
