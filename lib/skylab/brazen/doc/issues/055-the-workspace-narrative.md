# the workspace narrative :[#055]


## introduction

what we now call a "workspace" was once conceptualized in [tm] as a
"config stack". for now our rendition of it amounts to an abstraction
around a config file, but it decidedly stands for less than this.

currently it provides facilities for finding the config file given a
relative pathname and starting path and a maximum number of dirs to
search upwards.

we will again scale it out one day to work like [tm] used to, with
abstracting the access of property values via a variety of means, e.g
perhaps multiple cascading config file locations and/or the environment,
or perhaps strange new config modalities like sessions in datastorses etc.

the workspace silo is a "reusable silo": it works here for this
application but we want to exhibit the same behavior elsewhere for
others, in a manner that is both unobtrustive yet
extensible/customizable.




## :#note-120

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

keep this in mind below as we handle names variously with global or local
semantics.

in the resolutions of the below we never disriminate between having not
had a name in the target box and having had a falseish value already -
either way the value is [over]written when we have a (trueish) value to
[over]write it with.

note that depending on the caller the target box may be the same object
as the argument box of the action. such cases may lead to extraneous
reads, but will not lead to extraneous writes; given our hand-written
defaulting logic.

  • `config_filename` - action or delegate or class
  • `max_num_dirs`    - action or delegate or hard-coded default of 1
  • `path`            - action (as `workspace_path`) or delegate
