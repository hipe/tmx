# the workspace narrative :[#055]


## introduction

the workspace silo is a "reusable silo": it works here for this
application but we want to exhibit the same behavior elsewhere for
others in a way that strikes a balance between being unobtrusive and
intuitive on the one end and customizable and extensible on the other.

what we now call a "workspace" was once conceptualized in [tm] as a
"config stack". for now our rendition of it amounts to an abstraction
around a config file, but it decidedly stands for less than this here:

it is up to the end client ([br] here, but others exist) whether its
workspace is persisted as just a config file or whether its persistence
is manifested as an entire directory with a) this config file nested N
levels deep within in and b) perhaps other assets persisted as files
within this directory as well.

also we have our sights set on making the particular persistence of the
config be modular: we don't take it for granted that we will always be
using the filesystem and/or one particular config file syntax.

currently the primary behavior this silo exposes relates to finding and
creating workspaces: it exposes the ability to find a config file given
a relative path (of one or more filename parts) and a starting path (and
optionally a maximum number of dirs to look in) from which to look
upwards for the config file.

also the silo exposes an "init" action which will create an empty-ish
workspace, and a "status" action that can reflect on the characteristics
of the workspace.

we may again scale this out one day to work like [tm] used to, with
abstracting the access of property values via a variety of means, e.g
perhaps multiple cascading config file locations and/or the environment,
or perhaps strange new config modalities like sessions in datastorses etc.




## :#note-040: why we do this here

the relevant formal property for the particular
upstream action will typically want to express either that this field
is fixed to some positive integer (like `1`) or that it is unbound (what
we typically use `-1` to signify). as well this typical formal property
will want to normalize an incoming value (if allowed) to be something
sensical, i.e a non-negative integer (notwithstanding `0` being a
guaranteed no-op.). given these two points, for the formal property
to express a default of "unbound", we want it to default it to `nil`
(which happens to be the same as not expressing a default); then we
do the above which has the desired outcome.




## (was #note-120)

a general property of property names is that they have semantics and
provide identity only within the context of the proprietor (entity or
action). multiple proprietors can use the same names as other
proprietors and they are not necessarily referring to the same thing:

for example, the name `path` for one formal argument for one action does
not necessarily hold the same kind of thing as a formal argument by the
same name of a different action.

(as an aside, note that because our structures and their containing
structures are generally hierarchical and at each step have some explicit
or inferrable name that is locally unique, universal identifiers can
generally be deduced from local ones as necessary.)

however, this dynamic is not intrinsic to the framework: it is a
question of implementation whether and to what degree this is dynamic is
observed. it is hypothetically possible to give universal (for some scope)
semanitics to a (local) property name (of variously an action or an entity):
it is only a matter of implementation.
