# the CLI action top narrative :[#039]

## :#storypoint-5 introduction

welcome to the CLI action. it's dangerous to go alone. take this.

this is the "narrative" for the (locally) top node (module) stated in the
title, which holds assorted smaller and lightweight concerns for a CLI action.
it may be the case that one child node of ours in particular has a far greater
role to play in the behavior of the typical CLI action instance than we do,
but at this level, how are we to know?

this one node (specifically the i.m node) represents the biggest loss we
had in the great :#fire, whose gory detail you can read all about in
in a long anecdote in [#084] the expression agents doc if you really want to.

because we had once embarked on an abitious rewrite there and then lost
everything, we re-approach this same same task today with some exasperation,
but at the same time we meet the challenge with the enthusiam of knowing
that whatever we rebuild will be cleaner and stronger and clearer than what
was lost.



## :#storypoint-7 (these constants)

the use of variants of these constants thoughout the CLI node exemplifies
nicely the use of our [#050] name conventions: because it ends in an 'X' it
signifies that the "caller" does not know anything about the shape of these
values and must use them accordingly. you will see variants of these constants
appear variously with zero, one or two trailing underscores and these each
have [#100] precise meanings.

they exist as "public" constants here because while [#126] we do not have a
central, shared general CLI node by design, we think it is ok to share these
constants throughout our sibling nodes; and that is happening here and not
elsewhere because in practice almost all our sibling nodes will exist with
the topic node having been loaded already.



## :#storypoint-10

### reasons for the ugly constant name

(this below calculus applies equally well to multiple constant names under
the topic node. the name you are reading about may be different than the name
you are "at" but the calculus still holds.)

a lot of developers might take issue with a module named 'IMs' and/or a
file named "ims.rb", and they would be justified in their scrutiny. but in
fact given our name conventions we have exactly no other choice. our [#079]
naming conventions are now so tight (and valuable in their precision) that
names like these actually chose themselves without us needing to spend much
thought:

• the module itself is not an part of our public API (that is, it must not
  be included directly), so to give it a full name 'InstanceMethods' would
  not only be misleading, it would be incorrect.

• our normal tactic in such a situation is to give a const name one or two
  trailing underscores as appropriate per our [#079] name conventions for
  constants. however, this too would be incorrect, because this module
  is private to the library but not within it. (that is, it is part of our
  :#private-API). in fact it must be public (not just protected) within the
  library because of the way it is structured and who needs access to this
  node. hence a const name with trailing underscores would also be incorrect.

the only choice we are left with is to give the module an intentionally terse
name as described in [#119] its essay that describes the rationale behind
this. a name like 'IMs' is supposed to look weird and supposeed to be a red
flag that what you are seeing is not part of a public API. there is simply no
other way to name the node given its designed scopes of visibility. and so too
to accord with autoloading there is no other way to name the file other than
"ims.rb" (we actually patched the autoloader so the filename wouldn't isomorph
to "i-ms.rb"!)



## :#storypoint-15 (method)

this method is part of the #option-parsing-facility of headless CLI.

this method is a DSL-ish that just accrues o.p definition blocks for you.
turning them into an o.p is your responsiblity. use them e.g in your
'build_option_parser' method.

the "#state-profile" of this "#field" includes "#semantic-booleansim":

we employ :#field to refer generally to something resembling a getter (e.g an
`attr_reader`) usually with a corresponding setter (e.g an `attr_writer`, but
usually not that form in particular); but the name is meant to emphasize
that a variety of visibility, access mechanisms and validation might be
at play between you and the field. also, to say #field hopefully means there
is some kind of reflection somewhere.

a :#state-profile of a #field describes classes of well-formed states the
field value may assume through its lifecycle.

:#semantic-booleanism is a kind of #state-profile (or formally part of
one) whereby the particular true-ish-ness vs. false-ish-ness of the field's
value is an immediate indication of whether that field should be considerred
as *semantically* "absent", "not set", "empty", "unspecified", and so on.

such a field profile is useful for at least two reasons: one, its easier to
implement on the module-methods DSL side of things for reasons, and two, it's
more readable and concise in "controller"-like logic where we actually use
the field's value.

this has particular signficance for strings and arrays: (in fact those are
the only shapes that perhaps counter-literal interpretations of this
property):

• a string field that exhibits #semantic-booleanism will typically never be
  the empty string. if you have such a field and it is the empty string, its
  emptiness will not be checked for and it will be included in rendering as
  if it were any other string (often not what we want).

• an array field that exhibits #semantic-booleanism MUST never be the empty
  array no matter what! if an array of length zero is a valid value-state for
  your field to have, then it does not exhibit this property, period. we have
  to agree on this point because it has a huge impact on how we write the
  logic for such fields, and failure to follow our own rules can lead to
  everything breaking horribly.

• this characteristic could be applied equally well to fields that yield
  business objects or arbitrary other classes of value.



## :#storypoint-16 (pattern)

you will notice in this module methods moudule (sic) that it opens with
a triptych: three methods that each define themselves, then declare themselves
as private, then define an attr reader with name inflected to look
lower-level. yes this is indeed a pattern: :#DSL-methods are typically private
methods intended to be called by a class defining itself. all of the API-
public methods in this node will necessarily be DSL methods (pursuant to the
name and purpose of this module), hence they will all typicall be private
methods. each of these methods records the data of the class definining
itself, and then makes that data available for reading with simple public
reader methods.



## :#storypoint-20 (method)

this method is part of the #argument-syntax-facility of headless CLI.

this method is for custom syntax rendering of custom hacky syntaxes that
you may hand-implement.

this method is for hacky custom syntaxes that you want to document.
its #field's #state-profile exhibits #semantic-booleanism.



## :#storypoint-25 the desc facility

this method is part of the #desc-facility of headless CLI, which is tracked
generally and universe-wide with :[#033], such that we can one day unify the
diaspora of implementations. as the name would suggest but perhaps not
clearly, this facility is concerned with storing and rendering description
text for actions.

this method is a DSL-ish writer. its corresponding #field has a state file
that exhibits #semantic-booleanism

more description occurs at #storypoint-#todo, in the corresponding i.m section.



:#storypoint-30 :#the-default-action-methhod

your default action is simply an instance method your action defiines that
ltself results in the name of another method to be used as the default action
method. (we may call this a :#task-method to differentiate it when you have
have one action class with multiple ..well.. task methods.)

this in turn is the method name to be used as a task method if for e.g the
queue is empty after parsing any opts, and the engine needs to decide what
method to use to process the request.

this task method will in turn be used possibly to parse argv args with, and
then this method will be called with any valid-arity-having argv.

a common default name for this assumed elsewhere is `process`, however it is
the opinion of the present author that it is an #anti-feature for the library
to assume your default task method has any pre-ordained name.

it makes the code more readable to use a name that describes the business
function of this task. for example, use a name that is expressive (in one or
two words) about what your particular action actually does, or its default
"behavior payload" (its primary reason for existing), even its (shudder)
value proposition!

so anyway, this DSL writer can be used to indicate that.
