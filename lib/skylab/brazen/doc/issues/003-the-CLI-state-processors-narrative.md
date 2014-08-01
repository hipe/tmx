# the CLI state processors narrative :[#003]

## intro

in the code they all live under the node `When_`. at first they appear
to stick out like a sore thumb or perhaps seems as a smell. but on closer
inspection we come to understand exactly why the are as they are.



## what they are

they are something like methods that must be called in two separate
steps: one, you construct them with arguments. two you call 'execute' on
them. this is the familiar "agents" pattern that we see everywhere in
this universe.

but state processors add one important detail to the above: they must
result in an exitstatus.



## what they are not

they are not to be confused with entity events. entity events are a
convenient way to bundle up information and allow it to travel across
modalities. because state processors are only for within CLI, entity
events are not useful.



## why they were created

we wanted a modular, future-proofed way for logic to be accumulated in
one pass and then executed in another. we don't beforehand know if we
will be adding for example options to the option parser that will want
to trigger an early exit.

this pattern lets the client accumulate processers from a variety of
locations and only at a certain endpoint execute them all, perhaps
stopping with an early exit if any one processor results in an
exitstatus.

as a corollary benefit, we wanted a way to cut down on low-level
"busines logic" cluttering up the main client file; which is served
nicely by the compartmentalization we get from putting corners of logic
in their own dedicated classes.



## how they are used

typicially and now as a de-facto idiom, we wrap each *construction* (not
execution) of a state processor in a "when_foo_bar" for the state
processor "When_::Foo_Bar". this will allow child classes of the client
class to override this behavior easily with their own implementations.
_
