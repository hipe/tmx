# making some sense of the architecture :[#059]

(EDIT: below the dashed line is unintegrated old content, *all* of which
is no longer releveant, but is left intact for historic interest)


--------

this application has gone through at least three almost ground-up rewrites,
yet it is still almost untenably confusing to understand without some
narrative, verbal/visual introduction (even for the author).

## treemap's history and secret mission statement

aside from the supposed core business focus of the app which is to generate
treemaps, "treemap" the project ever since its inception has been all about
exploring plugin architecture: treemaps can be generated in a variety of
ways utilizing a variety of third-party tools. we wanted to see to what
extend we could make an omni-utility that holds all these tools under on
roof, hopefully with a semi-unified UI and a semi-unified API to wire the
particular adapters to the application's "kernel" and "shell" as it were.

## the two fundamental axes of the universe

as is wont during developent, we are developing ad-hoc structures and
inventing terms for them along the way. but despite our efforts, these names
are rarely self-documenting to a degree sufficient to get a working
understanding of them at first glance. this, then, is our goal here:

there are two primary axes along which we divide this universe: one is that
of "adapters", and two is that of "actions". the application has many
adapters and each adapter has many actions:

  +-----+    +---------+    +--------+
  | app |---o| adapter |---o| action |
  +-----+    +---------+    +--------+

one fun part is this: of the actions, there is the idea of an action being
"native", that is, it has some kind of built-in presence within the
application, outside of any adapter. an action that is not native is called
"strange" - that is, any adapter can add any action it wants to the
application and the application need not have apriori knowledge of it.

## actions and the adpaters that touch them

another facet of any action is the number of adapters that touch it:
an action that is native and has no coalescence with any adapters will have
one set of behaviors, whereas a strange action that is "from" only one
participating adapter will have another, whereas yet another set of behaviors
will occur with the action that has multiple adapters, and may be variously
native or strange.

specifically this manifests in request processing and help screens: the
question becomes "which adapter(s) should be reflected in the processing
of this request?" whether it be for a help screen or a plain old payload
request. fortunately these decisions usually make themselves in intuitive,
straightforward ways (the principle of least surprise), but the surprising
part is: this intuitive-ness is unfortunately not always born out in the
implementation.

## on to the architecture: things and their names

in the spirit of zero-configuration we use the filesystem wherever possible
as the lingua-franca substrate through which we create and detect both
actions (native and strange) and adapters.

the topmost (rootmost) node is the

  +-------------+
  | adapter box |
  +-------------+

. true to its name, it is is an ordered key-value collection ("associative
container") [#cb-061]. its purpose is to represent the available/loaded
adapters in some way, and allow them to be retrieved for doing further
stuff. as for its implementation, it *simply* glues together some other
awesomeness from elsewhere and so it itself is quite tiny.

formally the adapter box has many

  +-------------+    +---------+
  | adapter box |---o| adapter |
  +-------------+    +---------+

. the adapter object is the primary means through which we interact with any
adapter.its main reason for existing is to reflect on the composition of the
actions and load (or "catalyze") them when desired.

amusing history anecdote: the "adapter" class was first known as a "mote"
and then a "metadata" before being christened as the "catalyzer". we finally
renamed it to what it is (the thing it represents - the adapter) when we
realized that we were over-worrying about creating god-objects; but with all
this said: the primary inspiration for writing this whole document was to
explain what the "catalyzer" was for (because we could never remember), and
when we got halfway done with this document we thought of this better name for
it, thereby vitiating the value of this document somewhat.

## that's all for now

we will come back and "Finish" this document once we have compelete test
coverage and we knock-out un-used vestigial classes and code.
