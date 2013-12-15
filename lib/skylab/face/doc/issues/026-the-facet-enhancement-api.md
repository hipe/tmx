# the facet's `enhance` API :[#026]

each facet, in order to ehance the API Action class, will be sent a message
to enhance the particular API Action class via its `[]` method.

this is a consistent, common interace that each facet will follow, that
takes the form - `Action::Foo[ action [..] ]`

this must be assumed to be non-re-affirmable unless otherwise stated. (that
is, the default is to assume that sending `[]` more than once with the
same module as an argument has undefined behavior.
