# the "reduce forms" algorithm (:#miranda-july)

any given form is a match for the argument constituency IFF for
every category-exponent pair in the constituency:

  • if the corresponding pair in the form has a true-ish
    (i.e "set") exponent value, that exponent value is the
    same exponent as the value in the pair.

that's it. if the corresponding exponent value for that form is
"not set" for a given pair in the argument criteria, the form
(at this pass) gets to pass as if it had a matching value for
that category.

no greater weight (or "score") can be given to forms that
"match more things" than others; the form either matches the
criteria or it doesn't.

### case in point

the "she, he or it" test (in the pronoun spec) demonstrates this
empirically:

  • the phrase starts with having a number exponent of "singular"

  • we modify the noun phrase to be "third person subjective"

  • the target output is "he, she or it".

the "she" and "he" form are specific to the subjective case (with
"her" and "him" being the objective counterparts there). "it", on
the other hand, functions for both the subjective and objective roles.

although against this criteria the "she" and "he" "match more things"
than than the "it" form, it is incorrect to eliminate the "it" form
from the set of matching results. or as miranda july puts it,
"no one belongs here more than you".

if we look at the "lexicon" data for the "pronoun" lexical category,
the described algorithm is made more intuitive if you imagine an entry
existing for every possible combination being stated explicitly
where we have instead left grammatical categories blank, for any
given surface form that has a blank entry:

in the "table", the "they" form does not specify a gender. as such
it can be used when the gender is explicitly 'feminine', 'masculine'
or 'neuter'. so you can imagine the entry that is there as "shorthand"
for these three "entries" it implies.

this is of course combinatorial: the widely applicable "you" surface
form, if we multiple out its permutations (two cases times
three genders times two numbers) can be used for a whopping 12
"roles" (if four is indeed the limit to the number of grammatical
categories that are important for pronouns, which it will or won't
prove to be based on how our "lexical category" constituency plays
out..):

    tmx permute generate --case subj -c obj --gen fem -gmasc -gneut \
      --number sing -nplur

    subj fem sing, obj fem sing, subj masc sing, obj masc sing
    subj neut sing, obj neut sing, subj fem plur, obj fem plur,
    subj masc plur, obj masc plur, subj neut plur, obj neut plur

this is why we don't like the term "role" here - it diminishes
the "relational database lookup" quality that is most concisely
represented by the data as it is as opposed to the theoretical
expansions of it we are describing here.

also, note that for those surface forms that do and don't variously
"care about" particular grammatical cateogires, we could group such
surface forms by "those that have the same set of grammatical
categories they care about":

  (care about four categories): "she", "he", "him", "her"
  (cares about nothing but person): "you"
  (cares about all but case): "it"
  (care about all but gender): "us", "them", "me", "we", "they", "I"

but this is not yet made interesting by doing so.
_
