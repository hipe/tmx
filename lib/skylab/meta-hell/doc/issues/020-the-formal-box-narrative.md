# the formal box narrative :[#020]

## obviation path

## this node is redundant with [#cb-061] which came after it and was
rewritten for reasons. the below is a feature comparison table with a
focus on those features of original box that new box doesn't yet have.

                feature name | orig | new
                      length | same | length
                       count | same
                   get_names | same | same
                        has? | same | has_name
                         if? | same | [algorithms]
                        each | same | each_pair
                   each_pair | same |
                      detect |
                    defectch |
                      filter |
                         map |
                      reduce |
                      select |
                       which |
                          at |
                at_with_name |
                to_pair_scan | same | to_pair_stream
            get_value_stream |
                       fetch |
           fetch_at_position |
                       first |
                 fuzzy_fetch |
                      invert |
                     to_hash |
                   to_struct |
                      accept |
                         add |
                      change | same | replace
               sort_name_by! |
                       clear |
                  partition! |
                      delete |
             delete_multiple |
     partition_where_name_in |
                        `[]` |
                        to_a |
                      values |
                 around_hash | hack


## :#storypoint-5 introduction

yo dog a formal box is like a hash (ordered) that you can customize the
strictness of and like other things too. by default none of its public members
mutate its composition.

Formal::Box sounds a lot like the "Associative container"
  from http://en.wikipedia.org/wiki/Container_(abstract_data_type)
but is sort of "stable" in the sense used in List_of_data_structures, except
that its order is mutable :[#020].



## #storypoint-40

the "optimization" you are thinking of is probably a bad idea.

    h.each( & box.method( :add ) )  # strange - `each` wouldn't work



## :#storypoint-75

these reader methods are presented in categories and the categories are
ordered by vaguely how `heavy` their gestalt result is, ascending.

there are 2 methods here that do actually mutate the receiver, but they are
private. can you find them?



## :#storypoint-115

if an entry exists with `name` (if `has?` `name`), call `found` with the
value. Otherwise call `not_found`, which will be passed zero one or two args
consisting of [box [`name`]] based on its arity.



## :#storypoint-130

`each` - if block given, yield each name-value pair (or just value per block
arity) (and result will likely be nil/undefined.). otherwise, if no block
given, result is the enumerator. this serves as a downstream implementation
for lots of other readers so be very careful if you attempt to rewrite it in
your box subclass, e.g - your version should internally use a formal box
enumerator-like, one that has a normalized (2-arg) consumer and is capable of
producing filtered offspring, whatever i mean by that.

avoid overhead of processor, memory, cognition and avoid ugly tall stack
frames; for this 95% case. #todo benchmark looping alternatives :[#051]:
length is determined at beginning of traversal, not during.



## :#storypoint-155

exactly `::Hash#values_at` but the name doesn't collide with `Struct#values_at`
which weirdly only works with ints. also uses hash "risc" b.c ..



## #storypoint-165

this method is probably aliased to '[]' in the box class.



## :#storypoint-200

this is a higher-level, porcelain-y convenience method, written as an
#experimental attempt to corral repetitive code like this into one place (was
near [#ba-003]). to use it your box subclass must implement `fuzzy_reduce`
(usually in about one line) (see). Internally, `fuzzy_fetch` produces a subset
box of the items that match the _string_ per your fuzzy_reduce method
(actually in theory some of this could be applied towards arbitrary search
criteria but for now it is geared towards user-entered strings..)

if none was matched in the search, `when_zero` is called with no arguments.
if one, `when_one` is called with **the matching `Formal::Box::Matchdata`
object (see)**, which has the matched item in it with other metadata (some
algos like to know what search string was used, or which of several searched-
against strings was matched).

if more than one item was matched, `when_many` is called with the whole box of
matchdatas.

result is the result of the particular callback (of the three) that was
called. exactly one will be called, because the three callbacks cover in a
non-overlapping way the set of non-negative integers, to put too fine a point
on it.



## :#storypoint-205

this is typically used as a backend for the method at #storypoint-200.

in your box subclass, implement a method called `fuzzy_reduce` and for its
body you will typically call `_fuzzy_reduce`, passing it a string as a search
query and a proc that takes three arguments. the proc will be called once for
each item in your box, and will be passed the item's name, value, and a
yielder. pass into the yielder whatever string(s) you want to represent the
item by in this search:

    def fuzzy_reduce ref                              # `slug` is e.g
      _fuzzy_reduce ref, -> _k, v, y { y << v.slug }  # something your items
    end                                               # respond to, stringy


internally e.g _fuzzy_reduce will use a regex created from the search ref and
match it against each string you yield, stopping at the first match per item
(but still the broader search continues over each item). the result is a new
box whose names correspond to the matching subset of names in your box, and
whose values will be one matchdata per item (see).

if your items have multiple aliases or keywords to be searched against (i.e.
not just one "name" string), just loop over them and yield each one to the
yielder, which is what it's there for.

the reason you have to implement a `fuzzy_reduce` yourself is because it would
be a bit of a smell for this library to assume how to induce one or more
strings for your items.



## :#storypoint-225

this is one of the algorithms in the :+[#049] fuzzy matching family.

the reference argument will be turned into a regex with the usual simple
algorithm. your tuple is called with (k, x, y) once for each item in the
box argument, where `k` is each key and `x` is each corresponding value.
in your tuple, yield to `y` with `<<` each string name from `x` (or even `k`)
(#todo:during-merge: change the order of the args for y to go first.)
against which you want to attempt a match with the reference argument.

the result is a new box with zero or more matchdata items.

*NOTE* this implementation is ignorant of the idea of an exact match, so for
a ref of "fo" against ["fo", "foo"], result is 2 matches. this is now
considered a bug.

#todo - investiage a possible bug where the input token is longer than the
surface name but still matches



## :#storypoint-245

if your subclass very carefully overrides (and calls up to!) the 2 below
methods correctly, you could have relatively painless duping The duplicate is
supposed to 1) a new box object of same class as receiver with 2) (for the
non-constituent ivars like @enumerator_class) ivars that refer to the same
objects as the first and 3) constituent elements that are in the same order
as the receiver, and whose each value is a dupe of the original for some
definition of dupe (which is determined by `dupe_constituent_value` which you
may very well want to rewrite in your box subclass).

(then we wrote [#021].)



## :#storypoint-270

dupe an arbitrary constituent value for use in duping. we hate this, it is
tracked by [#014]. this is a design issue that should be resolved per box.



## :#storypoint-275

like `dupe` but don't bring over any of the constituent elements. used all
over the place for methods that result in a new box.



## :#storypoint-280

these are all the nerks that add, change, and remove the box members that make
up its constituency. they a) all all private by default but can be opened up
as necessary and b) are here because we might want to make some strictly read-
only box-likes.



## :#storypoint-290

note there is not even a private version of `store` ([]=) because it is
contrary to Box's desire to be explicit about things. the equivalent of
`store` for a box requires you to state whether you are adding new or
replacing existing.



## :#storypoint-320

TL;DR: for all the members that match `func`, take them out of this box and put
them in a new box. In more detail: it's like an ::Enumerable#partition but one
result instead of two, and it mutates the receiver.

it's like ::Hash#delete_if whose result is effectively the deleted virtual
hash.

result is a new box that is spawned from this box (so, same class and same
"non-constituent" ivars, initted with somethin near [#021]) whose constituency
is the set of zero or more name-value pairs that resulted in true-ish when
passed to `func` (which must take 2 args). Each matched name-value pair is
removed from the reciever. No matter what you end up with two boxes where once
there was one and still the same total number of members.



## :#storypoint-340

batch-delete, bork on key not found.




## :#storypoint-370


this method `[]` does not behave as it does with hash: it is strict.
it is more similar to the same method of ::Struct. use `fetch` with a block
if you need hash-like softness.

the reason this method is not defined in the instance methods module is
so that we can avoid overwriting ::Struct's native implementation, so that
this plays nice with the 'struct-as-box' facility.



## :#storypoint-405

this exists a) because it makes sense to use enumerator for enumerating
and b) to wrap up all the crazines we do with hash-like iteration



## :#storypoint-410

result is a new Box that will have the same keys in the same order as the
virtual box represented by this enumerator at the time of this call, but whose
each value will be the result of passing the value of *this* virtual box to
the proc.

result is not of the same box class as the one that created this enumerator,
just a generic formal box (because presumably the constituent elements of the
result box are not necessarily of the same "type" as the box you called this
on).

this was designed to be easily re-written if you want to specify the
box class that is used.

we can't imagine a circumstance where you would not pass a block, but we
have covered this case to act like Enumerable.



## :#storypoint-480

`defectch` - fetch-like detect
similar to fetch but rather than using a key to retrieve the item,
use a function (like ordinary `detect`) and retrieve the first matching
item. Ordinary `fetch` allows you to pass a block to be invoked in case
an item with such a key is not found. This is like that but it is a
second function, not a block that you pass (this one accepts no block..).
Like ordinary `fetch`, if no `else` function is provided an error is
raised when the item is not found. Furthermore, the shape of the result
you get is contingent on the the arity of your first function oh lawd.
Whether or not using this constitues a smell is left to the discretion
of the user.



## :#storypoint-515

Array#select result is array, Hash is hash..



## :#storypoint-525

these are the normalizers we use to yield either one or two values out per
element as appropriate

these are the permissable arities your block (to whatever) can have and then
the corresponding normalizer we use to yeild each name-value pair out



## :#storypoint-530

# if you want to collapse back down to a box
# after a chain of e.g. filters or whatever
