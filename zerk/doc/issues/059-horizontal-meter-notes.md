# horizontal meter  :[#059]

## negative minimum :[#here.1]

in its first few years, the horizontal meter only ever visualized
non-negative numbers. the closely related "max-share meter", in
its sense, assumed that numbers always represented a count of
countable items or some quantity, like the pages of a book or
ounces on a scale. it conceived of every "item" in this count
to be as significant as any other.

the minimum number of the collection was never taken into
account, so for example a data collection of the numbers
{ 41, 44, 43 } across ten "pixels" would yield meters that
probably all looked the same and all looked "full".

if you wanted to "zoom in" such that only the range (min
to max) was visualized, you could do it yourself by sending
{ 0, 3, 2 } (each number minus the minimum number), and telling
it to use a denominator of 3 (the max minus the min). but out
of the box the subject has no sense for "zooming", because it
doesn't really have a sense of scale - it's not annotating the
visualization with number markers; it's only producing a matrix
of blocky pixels.

enter negative numbers: imagine we are plotting temperatures
in degrees. this is what we use the `negative_minimum` for.

the "negative minimum" should be the value of your lowest number
in the collection. if you add your "denominator" to this value,
you should probably reach your highest value in the collection.

so if you're plotting { -20, 5, 10 }, your negative minimum
should be -20 and your denominator should be 30. a visualization
for these numbers would then be the same as a counterpart
visualization of the numbers { 0, 25, 30 } (which is each of
the numbers "shifted" up by 20).

it's an imperfect solution but (EDIT)
