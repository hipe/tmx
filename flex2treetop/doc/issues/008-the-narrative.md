# the flex2treetop narrative :[#008]


## foreward

to have any hope of understanding what is going on here, it is strongly
recommended that you at least read until section [#.A] below.




## the main premise

in flexfiles there are definitions and there are rules. these
correspond to two of the three sections of a flex specification file.
(we don't care about the first section here, for reasons alluded to in
the next documentation section.)

whereas a flexfile has definitions and rules, in treetop we have only
rules. (we will differentiate explicitly between treetop rules and flex
rules.)

the brazen theory this utility puts to the test is this: to what extent
can we construct an isomorphicism between treetop rules and (variously)
the definitions and rules of flex? the extent to which we can do this is
the extent to which we can translate a flex specification into a treetop
specification.




## more about flex :[#.A]

it *seems* that the "definitions" of flex translate smoothly to rules of
a treetop grammar: they each use grammatical game mechanics that have
analogues with one another (things like character classes, alternations,
sequences, repetition ranges).

the more challenging part comes with translating flex's "rules". a flex
rule is a bit more like a function than a purely grammatical
component: it typically has a head and a body; and while it appears that
the head is a purely grammatical structure, it seems that the body may
consist of arbitrary C code.

(in our grammar grammar, we call the parts "pattern" and "action"
instead of "head" and "body", respectively.)

now this is a problem for us: we decidedly do *not* want to concern
ourselves with translating these actions because for whatever reason,
life is easier when we deal purely in structure and not in logic for
this effort.

furthermore, it is arguably a smell to combine the concerns of action
with the concerns of defining a grammar.

fortunately, with the flex grammars we are typically interested in
attempting to translate, it seems their designers seem to agree with us:
the flex grammars we are interested in tend to follow a pretty strict
pattern with regards to actions. the one flexfile we are looking at in
particular has actions that each fall into one of two categories: they
either return a constant, or do nothing..




## what to do with the "ignore" type of flex rules?




## what to do with the "return a constant" type of flex rules?

in an ideally simple world a lexer delivers a stream of tokens and
nothing else. our treetop parsers deliver a structure that is based on
the structure of the grammar and nothing else. so our twisted hack is this:

if a flexfile's ideal rule consists of a *head* that is nothing more
than a grammatical structure and a *body* that is nothing more than a
constant; and a tretop rule consists of a *head* that is a rule name and
a *body* that is a grammatical structure; we use the flex rule *body*
for the treetop rule *head* and the flex rule *head* for the treetop
*body*.

because that's the most confusing sentence I have ever written, here's
an example:

    "<!--"    {return CDO;}

the above is a snippet of a flex rule. we can basically flip the two to
get our treetop rule:

    rule CDO
      "<!--"
    end

a more complicated snippet: the flex:

    {num}{E}{M}    {return EMS;}

and the treetop:

    rule EMS
      num E M
    end

(not pictured are definitions of those three depended-upon rules, in both
sides).

this "game mechanic" is a nifty possiblity, but there is one issue: in
the flex world we have the constant namespace (e.g "CDO" is a constant),
and we have (separately) a definition namespace. in treetop, however,
there is only the rule namespace. the way we get around this is kind of
nasty: ... (EDIT)




## why deferred actors? [#.B]

this class-as-function facade does two things: one, it acts as it sounds, it
lets us interface with our #tributary-agent classes as if they were procs -
it dumbs down the interface for the caller.

two, it allow us to lazy-load the node, which in turn accomplishes two
things: one, things regress more nicely when they break; nodes that fail to
load do not bring the whole system down until they are needed, which allows
us to pintpoint the cause of the problem in our tests faster.

two, if any of the metaprogramming is a heavy lift, it too is executed only
when needed.

this achieves the same effect as balkanizing this file into many smaller
files, which we are avoiding for some reason.





