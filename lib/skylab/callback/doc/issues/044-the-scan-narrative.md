# the scan narrative :[#044]

## introduction

a "scan" is a [#049] "scn" with lots of methods added to it. whereas a
"scn" is intentionally minimal and only has one method officially, a
"scan" comes with a whole bunch of methods useful for mapping,
reducing, expanding, generating random access controllers, etc.

with a scan we can do interesting chaining:

    my_scan.reduce_by do |x|
      :some_condition == x.some_value
    end.map_by do |x|
      Some_Other_Class.new x
    end.immutable_with_random_access_keyed_to_method :some_method

so we take a potentially large set of results, reduce it down to a
smaller set, build some wrapper objects around it, and put them into a
dictionary-like random accessor. note that all of the insides of the
above blocks are evaluated lazily - none of it is executed until it is
necessary to do so.


### random-access notes


#### :#ra-105

the "value mapper" is an experimental hack that lets you map your items
thru and arbitrary proc before the result comes from `[]` and `fetch`.
it may be useful if you have a parse structure you are trying to make
act like a dictionary.

it is not for reduce operations. if you result in false-ish from your
mapper proc, behavior is undefined.

we must not store this result internally, because internally the topic
class may rely on the stored items responding to the key method, as
well..




#### :#ra-180

we are being requested a key we haven't already seen when we haven't
yet seen all the keys. use the existing scanner we are wrapped around
*from the current position it is in*, keep grabbing items off of it until
either we find the item being sought or we run out of items, all the while
storing each item and its key.
