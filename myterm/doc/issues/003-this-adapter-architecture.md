this adapter architecture :[#003]

  • for the sake of this discussion, let's say that an expression of
    an adapter's usefulness is in the syntax it adds to the client:
    through this added syntax we may prepare and execute the unique
    operations that constitute the "value proposition" of that
    particular adapter.

  • the core "application" has no useful operations of its own, except
    those that list adapters and set the active adapter.

  • the way an adapter is selected is through what we'll call an
    "adapter change expression" in the argument stream.

  • the selected adapter (if any) can effect how each token on the
    argument stream is interpreted.

  • the coinciding change in syntax that accompanies a change in
    adapter must take effect immediately after the "adapter change
    expression" has been parsed.

i.e how the argument stream is parsed can change *mid-parse*.

the readers expressed by the below methods are memoized in a [#ac-022]
"reader writer", which was conceived to serve this problem. we can
assume this structure holds for at least the lifetime of the
"stack frame" of the [#ze-012] parsing implementation, i.e long enough.

since we change how the argument stream is parsed *mid-parse*,
we have to check what mode we're in at each token. (note this
clunkiness is only in effect while this root node serves as the top
of the frame, i.e typically not very long.)

if we hold an adapter, it can intercept expressions that would
otherwise match in our frame. if an adapter defines an association
and also expresses that the association is unavailble (at the moment),
it is still the adapter that has processed this expression. it is
*not* the case that the expression "falls through" to us in these
cases.

(yes an adapter could hypothetically change the syntax to lock out
further changes to what adapter is selected, but because there is
no as-yet forseen use-case to use multiple adapters in one invocation,
we see this as purely an imagined problem.)
_
