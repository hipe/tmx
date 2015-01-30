# the stream narrative :[#044]

## quick historical preface on a name change.

what we used to call "scans" in this universe are in a much more popular
universe called "streams". more precisely, our "scans" sounded like they
resembled their "streams" closely enough that not to rename our node would
probably only cause confusion, both for visitors from that universe and
inhabitants of this one. so we renamed our "scan" to "stream".

(also, we concede that "stream" is a better name: "scan" invokes
something that can perhaps peek and perhaps jump ahead given some
pattern (like a string scanner); by design we don't provide any such
complexities out of the box.)

one day it will be very interesting to see all the ways that the outside
("more popular") form differs from ours; but for now we remain
blissfully ignorant.

also we think it's telling that this facility emerged to prominence both
in our ecosystem and theirs at around the same time; but "independently".
because of our isolation we know that there was no direct
"cross-contamination":

on our little island, we discovered a penchant for these structures because
years ago we liked the simplicity of scanning lines from a file and thought
it would be useful to apply this pattern more broadly to other interactive
modalities like it.

little did we know that "streamifying" everything would become an
obsession that would consume us, but that's perhaps more of a personal
problem.




### on the visibility of the node (extreme detail)

the reason we rename this to be a private node (`[cb]::Stream__` not
`[cb]::Stream`) is for implementation hiding: the thing we do with
sub-classing Proc is (although “elegant”) perhaps kinda weird and not very
future-proofy.

but wait, that’s not why. the reason is that when we build streams
themselves it is either functionally or through using one of the macros
(a "macro" begin a method like `build_a_stream_from_a_nonsparse_array` or
`build_a_stream_with_this_one_trueish_item_as_its_only_item (names are
made up but equivalent methods exist)).

for the latter (building via macros), we should be using a “library shell”
anyway (an object whose only job is to have methods that correspond to
public singleton methods of that node (i.e its “library methods”)).

for the former (building a stream functionally) since the argument here to
build such a thing is only proc, the current favored way to do that is by
using a block, and we like `[cb].stream do ..` better than
`[cb]::Stream.new do ..` probably just because its shorter.




## introduction

a "stream" is a [#049] "scn" with lots of methods added to it. whereas a
"scn" is intentionally minimal and only has one method officially, a
"stream" comes with a whole bunch of methods useful for mapping,
reducing, expanding, generating random access controllers, etc.

with a stream we can do interesting chaining:

    my_stream.reduce_by do |x|
      :some_condition == x.some_value
    end.map_by do |x|
      Some_Other_Class.new x
    end.flush_to_immutable_with_random_access_keyed_to_method :some_method

so we take a potentially large set of results, reduce it down to a
smaller set, build some wrapper objects around it, and put them into a
dictionary-like random accessor. note that all of the insides of the
above blocks are evaluated lazily - none of it is executed until it is
necessary to do so.


## random-access notes

(these notes are stowaways here, piggybacking-in from the "random
access" child node. they are not part of the stream narrative proper.)


### :#ra-105

the "value mapper" is an experimental hack that lets you map your items
thru and arbitrary proc before the result comes from `[]` and `fetch`.
it may be useful if you have a parse structure you are trying to make
act like a dictionary.

it is not for reduce operations. if you result in false-ish from your
mapper proc, behavior is undefined.

we must not store this result internally, because internally the topic
class may rely on the stored items responding to the key method, as
well..




### :#ra-180

we are being requested a key we haven't already seen when we haven't
yet seen all the keys. use the existing scanner we are wrapped around
*from the current position it is in*, keep grabbing items off of it until
either we find the item being sought or we run out of items, all the while
storing each item and its key.




## signal processing scans :[#059]

this is a bit of a hack to allow us to perform what amounts to calling
an arbitrary proc in order to for example release the resources that are
behind a stream before we have reached the end of the stream.

apologies to real life signal-processing. this is a goofball experiment:
we want to associate with our glorified proc a dictionary of callbacks.
in order for the topic proc to go thru its many transformations (maps,
reduces etc) all the while carrying with it these same callbak procs, we
deem it easiest to make (what is effectively) a singleton class for each
such topic proc. this way during transformations it does the right thing
automatically, because each object that spawns off of this one has the
same class with the same dictionary (struct) inside of it.

this is #open because the way we accomplish this although "simple" in
terms of how easy it was to implement is ugly because it creates a new
class for each such instance and gives that class a procedurally
generated name achieved by incrementing an integer. this would be awful
if this were in a long running process and should be corrected somehow.

(perhaps even using singleton classes (if possible) would be acceptible)
