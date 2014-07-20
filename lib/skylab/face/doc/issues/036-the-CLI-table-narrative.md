# the CLI table narrative :[#036]

## :#storypoint-5

this is one of several CLI table implementations. one day we will designate
one of the narratives as the home to sort these out.



## :#storypoint-80

keep in mind what is happening here - *every* time you call the curried
executable, it makes a deep copy of the whole field box. it feels like we
should optimize this but it depends on the usage whether this is helpful: we
don't expect our usage patterns to justify such an optimization at this point



## understanding multi-pass table rendering

text-based table-rendering is not fun or interesting unless we do
"dynamic column alignment". to do this necessitates that we hold the entire
table (in some form) in memory as we determine the statistics for each column,
so that we can know how much whitespace to pad each cel of each column with.

algorithmically, alternatives probably exist to acheive a simliar end but they
are beyond the scope of this project.



## :#the-data-pass

in the data pass we flush every row of data from the producer, and along
the way we gather statistical data about each field from its each cel.

once we get to the end of the rows of data from the producer we can
know statistical metrics about the field, like what is the widest width
of all of its cels in terms of characters when stringified, or what is
the minimum and maximum values for the field when numeric.

we want to store the values of each cel in memory rather than iterate multiple
times over the same producer (if it were even possible) because the producer
might for e.g be a randomized functional tree in which case iterating over
it multiple times would probably yield different results which may obviate
attempts at building statistical data.

random gotcha: some custom enums want to short circuit the entire rendering of
the table rather than render anything.


## :#storypoint-280

when this form is called the instance is acting as a curried executable - the
arguments do not mutate this instance.
