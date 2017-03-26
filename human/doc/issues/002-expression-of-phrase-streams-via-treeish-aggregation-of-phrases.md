# expression of phrases via treeish aggregation of phrases :[#002]

## foreward

(there is a sister algorithm at [#055]. we don't know which one is
"better" off hand.)




## :"how we tiebreak"

### how we arrive at a tiebreak

any time we are comparing two expressions for aggregation, we start
by going along every "formal component" for the "outside" expression.

for each formal component there will be the any known value for the
"inside" and "outside" expressions variously.

we will refer to as a "column" the grouping of this *formal* component
and the any known *actual* value from the inside and the outside
expressions, variously.

each of these formal components is either "defined" or not "defined".
(this is determined by whether it had the `component` meta-flag in
its `COMPONENTS` structure. we should change this name.) what we do
logically with those columns with non-defined formals is the subject
of a comment inline.

if this list is *more than one* columns long, we have to
"tiebreak". (this is a simplification of what we used to do which
involved detecting contiguous spans..)




## when we arrive at a tiebreak, how we tiebreak

for each of these "columns", determine if the inside and outside
actual components are semantically equal (by whatever measure we
use). you will end up with N yes/no answers for the N (more than
one) columns. we can always place this list of answers into one
of the following non-overlapping categories:

  • 0 of the N component pairs are semantically equivalent
  • a number not listed here of component pairs are equivalent
  • N-1 of the N compoment pairs are equivalent
  • N of the N component pairs are equivalent

here is what do to for each of these categories:

  • when it is "N-1" we are happy - this is a clean aggreation:

        we   ate   some   soup
        you  ate   some   soup

       (diff same  same   same)

        "we and you ate some soup"


    N is 4 (four columns). 3 are semantically equivalent and 1
    is different. this fits into the "N-1" category above.
    another example in the same categeory:


        i    love  this   project
        i    hate  this   project

       (same diff  same   same)

    "i love and hate this project"



  • when 0 are the same, there is no aggregation that can be
    made.

        i    ate    no    soup
        you  drank  some  kombucha

       (diff diff   diff  diff)

        (can't aggregate at all)


  • when all N are the same, the two expressions are themselves
    semantically equivalent. what we should do in this case is
    undefined for now..

        we   had  lunch
        we   had  lunch

       (same same same)

       (wat do?)


  • when it is "a number not listed here", under this
    simplified algorithm we just give up at this point.

        we   ate   some   soup
        you  ate   some   poop

       (diff same  same   diff)

    !"we and you ate some soup and poop"  (this is lossy)

    the remainder of this section will list some examples that we do NOT
    produce under this current algorithm, but that we would perhaps
    produce under the old algorithm that detected contiguity. (we have
    simplified this away).

    note that the productions are grammatical and unambiguous but to
    varying degrees perhaps sound amusingly awkward and unnatural.

        we   drank  some    soup
        we   drank  lots of ale
       (same  same  diff    diff)
       "we drank some soup and lots of ale"

        we   ate    some   soup
        you  drank  some   soup
       (diff diff   same   same)
       "we ate and you drank some soup"




## :"note about aggregating word-lists"

word-lists are usually used for modifier phrases that don't (in English)
inflect (like a simple adjective modifying a noun). because it's not a
feature we ever yet wanted "in the wild", we don't care about aggregation
for these. but if we wanted it we could try to turn this on.

    i    have a    red  fish
    i    have a    blue fish

   (same same same diff same)

   !"i have a red & blue fish"  # this does not logically follow from the above



this example demonstrates that to use the subject algorithm here again
an expression like this would produce "incorrect" productions. there is
apriori knowledge required to determine if an aggregation is
appropriate, because:

   my    bedroom is   in   a    sad   state
   my    bedroom is   in   a    sorry state
   (same same    same same same diff  same)

  "my bedroom is in a sad, sorry state"  # OK


all this said, we don't want this situation to "break" possible
aggreations that can be made otherwise, so we go ahead and make
word-lists play along ..
_
