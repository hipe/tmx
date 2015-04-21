# towards tessellating phrasal boundaries :[#005]

## foreward

(the very first rough sketch of this content in writing comes from the
commit message at "12.D", or the seventh commit before the commit that
created this document.)




## synopsis

at the moment of this writing we have demonstrated to ourselves that what
we are calling "tesselating phrasal boundaries" seems to be a thing and
seems to be useful to us. our objective now is to find a more general
solution for this mechanic; one that can work "automatically" for new
phrases requiring at most that the grammars be (..er..) tagged with
points at which this tesselation may occur. again at the time of this
writing, we are not close to finding such a solution (however we are
confident one exists). findind such a solution is the ultimate objective
of this document.



## introduction

consider the utterance:

    "things that are marked with '#foobric' or '#doobric'"

speakers of the platform language will interpret (consciously or not)
that the above can be expanded to express **the same thing** as:


    things that are marked with '#foobric' or

    things that are marked with '#doobric'


i.e the latter example is a longer way of saying the former. in fact, we
may call the former [#it-031] "optimally concise" because by our rules
this is the densest we can get this expression to go without losing
information (i.e becoming ambiguous or otherwise uninterpretable).

(yes, in the platform natural langauge we could go further and do things
like omit the "that are"; we could even say

    "'#foobric' or '#doobric' things"

losslessly; but in the introduction to [#029] we stipulate the rubric of
"no synonyms", that is, that the surface idioms we chose to express our
business domain is arbitrary and effectievely unimportant to use here;
rather that what is important is that we chose only one idiom so that we
can for now focus on the subject algorithm.)




## a spectrum

there are other sub-optimally-verbose-but-still-correct expansions we
may make on the subject example. we will try to include all of them that
sound "acceptably natural" to us. note the varying degrees of
awkward-ness that they exhibit in how they sound, a metric that is
perhaps subjective:



    things that are marked with '#foobric' or

           that are marked with '#doobric'


then:


    things that are marked with '#foobric' or

                are marked with '#doobric'


then:

    things that are marked with '#foobric' or

                    marked with '#doobric'


finally:


    things that are marked with '#foobric' or

                           with '#doobric'


if we take these four examples along with the two that preceded them
(and introduced the topic); we find that we can produce "natural enough"
sounding expansions or contractions of **the same information** with as
many variations as there are "breakable boundaries" plus one in the
"phrase template". here are the "breakable boundaries" in the "phrase
template":



    things that are marked with '#xx'
           ^   ^   ^      ^    ^

there are five breakable boundaries in the "phrase template", so there
are six possible contractions/expansions that we may make to express the
underlying boolean tree.




## stop the insanity

note we cannot chop words off from the middle:

     things that are marked with '#foobric' or
    !things that                 '#doobric


and note we certainly can't chop words off from the end, because we
would loose our "most important part" (however that is determined):

     things that are marked with '#foobric' or
    !things that are marked with




## the other direction:


consider:


    drinking or smoking will kill me



then at the most expanded extreme:


    drinking will kill me or
     smoking will kill me



and in between:

    drinking will or
     smoking will kill me



also (super awkward, probably even unacceptiby unnatural):

    drinking will kill or
     smoking will kill me



but not:

    drinking will kill me or
   !smoking



there is a visually mechanical dynamic at work here, something that the
graph-theory behind something like "graph-viz" could hypothetically
perhaps help optimize: note that in this series of examples, when we
contract the longest form down to the optimally concise form, we "chop away"
from the first (not second) phrase fragment; unlike in the previous series
of examples where we chopped away at the second (not first).


consider the "joints" (dots) below:

    rest-of-sentence • thing-A
                                => rest-of-sentence • ( thing-A thing-B )
    rest-of-sentence • thing-B

contrast:

    thing-A • rest-of-sentence
                                => ( thing-A thing-B ) • rest-of-sentence
    thing-B • rest-of-sentence



the above concisions can be made because what is expressed by the "joint"
still holds true after the concision. but because of the arbitrary
breakdown of the sentence in the platform language, whether the "joint"
is at the "front" or "back" of the "varying slot" determines whether we
chop of parts of the front or back (respectively) of the subsequent
phrase when "concising".




## an in-fix example:

the "joints" rubric above applies to more "varying slots" than just
those at the head or tail of the phrase template. consider:

    we fight at the bar
                         => we fight and dance at the bar
    we dance at the bar

the general form here is one where the "varying slot" is in the middle:

    head • thing-A • tail
                           => head • ( thing-A thing-B ) • tail
    head • thing-B • tail

the "joint rule" still holds: what is expressed by the joints is still
true after the concision, so it may be made -- it is "more concise".


however:

    we danced in rome
                       => ! we danced and sang in rome and paris
    we sang in paris


although the above aggregation may happen in the platfrom natural
language, we are not interested in it because it produces an expression
that is ambiguous (wherease the source expressions are not). the
"concision" loses information, so it is not "more concise":

a generalization of what happened is:

    subj-A • verb-A • adv-A
                             => ! subj-A • ( verb-A verb-B ) • ( adv-A adv-B )
    subj-A • verb-B • adv-B

the concision is problematic because it violates the "joint rule": the
above joints imply information that is not in the source structure;
namey, "verb-A adv-B" and "verb-B adv-A".


HOWEVER:

    we danced in rome
                       => we danced in rome and sang in paris
    we sang in paris

(interesting side note: the produced form has the same number of words
as the sum of words in source expressions; yet it "feels" more concise,
perhaps because it has less redundancy; or is more "packaged".)


    subj-A • verb-A • adv-A
                         => subj-A • ( ( verb-A • adv-A ) ( verb-B • adv-B ) )
    subj-A • verb-B • adv-B

this is getting hard to visualize without drawing the whole trees, but
the point is that the joints in the result structure are still correct
and unambiguous, hence this is a concision we can make.



## but the point of all this is

that at the "breakable boundaries" of the phrase template is where we
may insert an 'and' or an 'or' to construct boolean trees.

to be clear, not all "spaces" are "breakable boundaries":

    if you quickly finish your sandwich and
    if you quickly finish your pickle

                                    (.. we can make it in time for the movie)

    if you quickly finish your sandwich and
       you quickly finish your pickle

    if you quickly finish your sandwich and
           quickly finish your pickle

    if you quickly finish your sandwich and
                 ! finish your pickle

    if you quickly finish your sanwich and
                          your pickel

    if you quickly finish your sanwich and
                               pickel


although the six variants above all exhibit varying degrees of
awkwardness, we find only one to be problematic.

    conj-if subj adv verb pronoun noun
           ^    ^   !    ^       ^


for some interesting reason we have yet to posit a guess over, the
"joint" between the adverb and verb is so unbreakable that we may not
"tessallate" into that spot. so there are 4 "breakable joints" so
there are 5 accceptible expansion-contractions.



## one more interesting facet

re-read all of the above and consider where we may naturally place a
'not' word with respect to the "breakable boundaries". the allowable
placement of "not" will depend on the particular phrase template, and
has to do with the grammar rules of this negation operator:


        things that are marked with '#foobric' and
    not things that are marked with '#doobric'

        things that are marked with '#foobric' and
         ! not that are marked with '#doobric'

        things that are marked with '#foobric' and
              ! not are marked with '#doobric'

        things that are marked with '#foobric' and
                    not marked with '#doobric'

        things that are marked with '#foobric' and
                           not with '#doobric'

        things that are marked with '#foobric' and
                                not '#doobric'

of the "breakable joints" here, some "sound better" than others:
(EDIT: the partiular parts of speech below are dummy placeholders)

        plural-noun spec verb prefect-verb conj noun
                   !    !    ^            ^    ^

this approach may or may not be improved by allowing for "weighted"
breakability scores; but at present as we re-read the examples we keep
changing what we think their relative scores should be with respect to
each other. (nonethess we may start referring to "joint breakability"
instead of "breakable joints".)
