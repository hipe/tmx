# the call_digraph_listeners spy narrative :[#022]


## :#storypoint-1 introduction

Set this up somehow as an interceptor for `call_digraph_listeners` and it will cache each such
emission that it gets into `emission_a`, presumably for subsequent test
assertion of it.

To keep life easy (for now) it assumes a payload datapoint of exactly 1 in
its `call_digraph_listeners` arity. To keep life simple (but not easy), it will not assume
anything about the shape of your one datapoint (although you wish it would
assume it is text.) (EDIT: no, you don't).

its `do_debug` state is derived from a function that you can set with `debug=`,
so that your debugging state does not have to be determined at the time that
you create this object and send it off somewhere, but rather can be linked e.g
to a different object's debugging state.

When debugging is on (when `do_debug` resolves to trueish), each call to `call_digraph_listeners`
will result in a `puts` to the `stdinfo` stream (stderr by default), with an
inspectified version of the emission.
