# the function narrative :[#006]

## about the "unmarshal" performer :[#here.A]

(EDIT: "magnetic" would probably apply nowadays.)

this "unmarshal" device was originally categorized as a model because
(by design) it does not follow the simple single-entry model of actor:
because it is convenient for implemention, we use this same class to
implement two different functions (that correspond to its two public
instance methods).

we almost created a new category for this sort of thing called
"performer" and then "device" - we wanted something distinct from
"actor" because this violates that categorization in that to use this
node, apriori knowledge of its interface required of it (something we
like to avoid generally).

"model" is not a good fit either, perhaps because an "unmarshal" is not
long-running, or perhaps because it has no data of its own, but rather
is a means to the end of other data (which again touches on the invisible
definition of actor).

"ancillary" works. "effecter" is a fun neologism.





## the "final" narrative (towards #note-007)

the invisible fine print of [#004] the criteria model is that a report
is nothing more than a list of functions that take at one end an entity
stream and result in the other end at another entity stream.


    +---------------------+      +----------+    +---------+
    | input entity stream | ==>  | function | => | funtion |
    |   ( "upstream" )    |      |   one    |    |  two    |
    +---------------------+      +----------+    +---------+
                                                      ||
                                                      \/
          +---------------+      +----------+    +---------+
          | output entity | <==  | func N   | <= | funtion |
          |    stream     |      |  [etc ..]|    |  three  |
          +---------------+      +----------+    +---------+


a function can be a "map", a "mutator", or an "aggregator". the reason
we need these three categorizations is that the underlying mechanics
need to call these three sorts of functions differently based on these
categories.


                   +-----------------------------+
                   | function (perhaps imaginary |
                   |    abstract base class)     |
                   +-----------------------------+
                           ^      ^      ^
                          /       |       \  (is-a)
                         /        |        \
                 +---------+ +---------+ +------------+
                 |   map   | | mutator | | aggregator |
                 +---------+ +---------+ +------------+

### map

a map function takes in one entity and results in another entity. if the
map function results in false-ish this signals the end of the whole
stream so care must be taken for mappers that result in primitive
values (which, after all, are not entites so that brings you into an
area of your own experimentation).



### mutator

a mutator is sorta like a map function but instead of resulting in a new
entity, it mutates (if it wants to) the existing entity. the result of
function is never important; it is always ignored. functional
programming purists will prefer thinking in terms of `map` instead of
`mutate`, but hypothetically we can transform any mutate function into
map function by putting the the mutate function behind a correctly
implemented `dup` method for the entity so we aren't too hung up about
this yet.



### aggregator

(EDIT: this sounds like "reduce")

this last one is significantly more complex to implement than the other
two, but arguably more valuable as well. an aggregator can perform the
"reduce" of map-reduce. rather than taking as input an individual entity
like the other two do, an aggregator takes as input an entire stream.
still, though, its interface must be a pull-driven stream that results
in individual entities. hence to implement an aggregator typically
requires maintaining some sort of state.

if we were to make a "search" aggregator, when it receives a pull
request it would pull from the upstream until an entity (if any) matches
the query. each successive result that this aggregator produces is
another matching search result until the upstream (that is, search
space) is exhaused (or perhaps the downstream stops asking for results!)

the aggregator we are working on currenty is a summary aggregator: when
it first receives a pull request, it will pull **all** of the entites
from the upstream; that is it will keep pulling until the end of the
stream. once that point is reached (and hopefully it is); it will do
some sort of summary calculations. then it will deliver its results (in
some structure) as if it is an entity stream.




## discussion

when we first set out to implement [cu]  (an idea going back to about
1998), our tactical approach was simply to do whatever takes to implement
a narrowly-scoped, small-search-space, narrowly focused recommender
system / search "engine"-ish for tiny, but meta-data-rich datasets.
(really, just a fluffed up, specialized spreadsheet).

but as we set out (again) to implement it at this pass, we got obsessed
with the simplicity and versatility of this functional, stream-driven
approach.

it is our hope that by creating this toolset, we will be able to
consider solutions to problems in ways that are paradigmatically
different than we could have forseen when we set out to make this.




## this algorithm in particular :#note-007

so we have the list of functions that make up this report. this twisted
but precise algorithm is based off of two premi:

1) aggregators need something to aggregate
2) everything is pull-based


the normal algorithm is that we have one entity upstream (always as a given);
zero or more "map-ish" functions (that is, mappers or mutators); and zero or
one aggregator. we can run each result of the upstream through the zero
or more map-ish functions in a straightforward way. rather than having
the zero or one aggregator have to worry about this, we just feed it (if
any) an enity stream that wraps the above.

when there are no map-ishes, the aggregator gets the upstream "raw".
when there is no aggregator our result is the resultant stream of the
map-ishes. when there are neither map-ishes nor aggregator our result is
simply the upstream.

the fun really begins when you have N number of arbitrary functions
chained together. it might be `[ aggregator ] [ aggregator ]`
it might be nothing but map-ishes, you don't know.

since the "normal algorithm" described above is one we are comfortable
with, to implement the "N-number of arbitrary functions" algorthm, we
group this chain of functions into structures we call "jogs", each of
which is implemented with the normal algortihm. let's see how that goes..
