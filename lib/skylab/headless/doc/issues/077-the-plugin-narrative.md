# the plugin narrative :[#077]

## this document is about ..

.. the custom plugin library implemented as part of [gv]. it is not about the
particular plugins. any documentation available for these can be found by
looking for a doc node locator next to the particular class name of each
plugin in its code node.

there is [#hl-070] an overview of all plugin-like facilities in the skylab
universe, of which this is one of at least six.


## :#understanding-plugin-conduits

"couduit" is the working title of this essential two-way structure. the
conduit both models services that the plugin needs from the host, like a
stream to write info messages to, or perhaps the higher-level "info yielder".
beyond these basics, the host is invited to subclass and customize this conduit
class as necessary. (kick the class with the 'plugin_conduit_class' class
method on your host.)

experimentally and for now this same structure is used by the host as an
adapter handle, so that the host has a unified interface for the different
plugin instances of possibly arbitrary shape. (for these purposes it's just
a simple two element structure: it has an inflecting name object, and the
plugin itself, which is of mixed shape.)

there is a fair chance that these two concerns may split into two classes.


## :#storypoint-50

the below cluster of methods corresponds to a subset of [#033] the different
kinds of callback tree patterns. see #the-different-callback-patterns-in-brief
there.


## :#storypoint-60

this method will yield the symbolic name of every plugin that listens to the
channel (first argument), or if no block is given it will call the appropriate
callback method for that channel along with any (non-block) args that were
passed to this selfsame method call.

in contrast to #storypoint-70, if while iterating over the listening plugins
and yielding each one, if any such response to the yield is a true-ish value,
this value will be interpreted as being an error code and the iteration will
be stopped at that point and that error code will be the result of this call.

i.e this method allows any plugin to short-circuit the host out of dispatching
the event to the other plugins, and so should be used when the host wants to
allow any plugin to trigger a failure of system startup, for example.


## :#storypoint-70

this method is exactly like #storypoint-60 but semantically different: rather
than a world of error codes, in this world "true"-ish means "succeeded" and
"falseish" means "did not succeed." the plugins are conceived of as
"shorters" that one-by-one will attempt something, and the first one to
succeed short-circuits the rest of the attempts. the result will be any
first true-ish value that any plugin resulted in.

note that although these are logically the same, we keep the names different
because they are semantically opposite and we want the client code to reflect
the semantic expectations the client is placing on the agent callbacks.


## :#storypoint-75

this method will iterate over every plugin that listens to the channel
indicated by the first arg and call the corresponding callback method of
that channel with the remaining (non-block) args passed in this selfsame
call to this method.

this contrasts #storypoint-60 in two ways: a) there is no block form, so
this method does not allow you to for example customize what args you pass
to each plugin per plugin. b) regardless of what the result value is from the
call to the plugin's callback, this iteration will continue, which is to say
this method does not allow the plugin to short-circuit its operation.

any true-ish result from the call to the plugin will be accumulated into an
array of tuples, each tuple consisting of first the conduit to the plugin and
second the value that the plugin resulted in.

if all plugins resulted in false-ish, the result will be nil; but if any
plugin resulted in true-ish the result will be the array described above.
