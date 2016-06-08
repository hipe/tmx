# the skylab "fields" sidesystem

## objective & scope

this sidesystem was formed under the mandate to unify universally all
significant efforts at libraries dealing with modeling
{ arguments | attributes | parameters | properties }, to an extent that
reduces duplication while still maintaining the sovereignty of
the nearby dedicated efforts that belong in their own libraries.

this, then, is what we hope is a semi-stable resting point for this
effort: a distillation of around *thirteen* (13) libraries that
spanned about 5 years of continuous work.

somewhere around 9 of these libraries have either been turned into feature
islands then sunsetted or assimilated. in the interest of presenting the
work as it stands now as a semi-coherent "canonical pantheon", a
tombstone at the end of this document is all that remains of a somewhat
extensive tabular survey of these previous works.



## each kind of formal attribute facility introduced.

### 1. simple "flat list"-based "attributes actor"

this is what you get when you pass the entrypoint proc of [#013] a glob
of symbols.

this formal attribute system merely associates symbol names with ivar
names in a direct way, while also maintaining knowledge of the order of
the formal symbols to support various means of invoking the actor.

we *think* that [co] "actor" (now [#016]) originated as a simplified take
on the complete [br] entity system; one that was intented to serve only
for the scope of "actors" as described in that document. (later, we
simplified this even further by breaking out the  "monadic" and "dyadic"
forms of these (now in [co]) for even *less* API than this.)

feature summary:
  • does *not* have dedicated class for formal attributes
  • does *not* have meta-attributes
  • (ergo) does *not* have meta-attributes DSL



### 2. "defined attributes"-based attributes [actor]

this most recent formal attribute system evolved as a semi-easy way to
facilitate actor-like backends for "operations" of [ac]. it provides a
concise way of indicating the same information from (1) but allowing the
ability to indicated "requiredness" too.

like everything does it evolved so assimilate other commmonly meta-
attributes (like `flag`, `description` and about 12 others..) and even a
meta-attribute API.

feature summary:
  • does have dedicated class for formal attributes
  • does have meta-attributes
  • does have meta-attributes DSL



### 3. the ACS

(see [#ac-001])




### 4. brazen entities / properties

"[br] entities" [#br-001] was the first such effort that was supposed to
be the last. distinct from its forebears was the (at the time) new
concept of "edit sessions" through which we would process "iambic" [#033]
streams of notation. this was a solution to the problem of
class-singleton-method-based DSL's that didn't faciliate a clean
distinction between "edit time" and "post edit time".

however these were the shortcomings that in part detracted us from [br]
and drew us to what we came up with near [ac]:

  • parsing iambic at file-load-time "feels" costly and doesn't regress
    well (when loading the file itself incurs wide dependencies), and
    workarounds to this feel cludgy

  • debugging long iambic streams can be difficult - when one term in
    the iambic fails, the stack trace does not lead you to the point in
    the iambic that fails.

  • there is a fair about of DSL and API that needs to be known to make
    even the simplest of entities / actions.

feature summary:

  • does have dedicated class for formal attributes
  • does have meta-attributes
  • does have meta-attributes DSL




# #tombstone: history & detail of ~ 13 attribute libraries (tabular) archived
