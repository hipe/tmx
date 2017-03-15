# the datamodel by way of an introduction

## prerequisite

see [#007] README for development.




## overview

    +--------+      +---------------+
    | survey | ---- | entity stream |
    +--------+      +---------------+
         |
         o - we may one day introduce multiple reports for one survey
         |
     [ report ? ]
         |
         o
    +----------+
    | criteria |
    +----------+


`cull` is a tool to aid the human in making decisions. one way of
looking at it is as a specialized spreadsheet front-loaded with idioms
and logic to the end of making table-ish reports.

another way of thinking of it is as a recommender system, albeit one
not quite as heavy-duty as what that term usually evokes.

the reports that [cu] produces can be any permutation of quantitative and
qualitative. specifically, they can be one, the other or both.

to jump ahead a bit, by this
very definition we are now positing here, the machine does not know what
the criteria are for a report that is qualitative. as such the machine's
only function in this case is to present the data to the human's eyes,
given perhaps some parameters defining fields of focus for the report.
but keep reading for thoughts on the utility of this.

currently our only [#bs-040] "output modality" is intrinsically *linear*
and *static*; however we should consider both of these classifications
as temporary: for those (internally) "function chains" that are
qualitative in nature, the particular order in which entites are
presented must be interpreted by the human as meaningless.

perhaps a report that is qualitative can be used by the human to build a
criteria for a report that is quantitative. ideally these reports would
be interactive, allowing the human to order the entites and express her
own "fields of focus", or perhaps the machine would try to infer the
criteria from the ordering itself, but that is certainly beyond the
scope of the moment.

all of this both sets the stage for what we are about to describe and is
getting ahead of ourselves.




## alternate introduction for functionalists

`cull` is a tool to aid the human in making decisions. one way of
looking at it is as a glorified map-reduce function. the input this
function takes is a stream of "entites". each such entity will be
"scored" by a "criteria". the output of all this is N number (perhaps 1,
perhaps the input quantity) of entities, presented (typically) in
descending order by score (with details of how the score was produced
perhaps being presented as well).




## the datamodel

a "survey" is a component whose role is largely to provide
encapsulation: it couples *one* "entity stream" with one "criteria" to
produce one "report". currently we are conceptualizing a "report" as an
effemeral thing; i.e one that does not have direct representation as an
"entity" (in the [br] sense) in our datamodel.

so the survey "has" *one* "entity stream". the entity stream produces a
series of zero or more entities. at the hands of the survey, the resultant
entities of this stream are memoized as needed given the "criteria".

by its human language dictionary definition, a "criteria" is simply a
set of "criterion"*s*. if you know any Greek, the former statement is a
tautology (because the one is just the plural form of the other). despite
this (or perhaps because of it (see "sapir-whorf")), we exploit these
two terms by modeling them variously as different structures in our
implementation.

to step away from the holodeck and get back to the deck, a "criteria"
against an "entity" produces a "score", which (simply) is a *real* number
representing that particular entity's (again) "score" against this
criteria.

this is largely where `cull`'s scope of responsibility both begins and
ends: to figure out (given a criteria) what the score is for a particular
entity (and perhaps present it (perhaps given a stream of entities)).

([#001] for more on the entity datamodel.)




### the criteria in more detail

a "criteria" is expressed by the human in terms that the machine will
hold (ultimately) as a *set* of *`criteria`*'s. for now, each
"criteria" *is* a function that takes a single entity as its input and
give a single real number as its output. (you need not hold "function"
as a concept that embodies anything more than "a thing that via
arguments produces output".)

strictly speaking, to say that the "criteria" is a *set* of "criterions"
is both relevant and false: a "set" has constituents; this much is
relevant to us. also, a set's constituents are unordered; this much as
well is relevant to us. but the fact that a set's constituents (by the
definition of "set") must be unique with respect to each other is not
technically part of our mission statement:

in theory by our definition of "criteria" (as we present it in this
selfsame sentence), every "criteria" contains multiple (zero or more)
"criterions" (insomuch as they are functions) that are themselves
perhaps the same as each other (using the sense of "identity" for a
"function" as expressed by the platform). so to be clear, when we say
"set" here; what we actually mean is "bag" (as the wikipedia expression).

in other words: a "criteria" might have multiple "criterion" that are
the same as each other. if at this point this doesn't make sense to you
then it probably has no utility in doing so (again) at this point.




### scoring

scoring, then, is (for now) simple arithmetic: with each entity from
the "entity stream" we pass that entity to each "criterion" in the
"criteria". each criterion results in a real number (perhaps negative).
the score for each entity is simply the sum of these numbers.




## qualitative case study: a feature set comparison

let's say the only thing you care about comparing among your entities is
their respective sets of features (and no, we haven't defined "feature" yet.)

it may be the case that these features themselves are discrete binary
properties: either the thing "has" or "does not have" the feature, in a
direct way. ([#hu-003.032] for wayyy to much explanation on this sort of thing.)

at this moment the topic commit is towards an exploration around this case
study.

...
