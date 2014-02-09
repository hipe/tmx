# the API parameters narrative :[#014]

this whole node is for an #experiment with the automatic creation of a
set of meta-fields that can be recognized by the entity library. tag
your fields with these metafields and we can try to make magic happen
for you. but note it is only the beginning. within e.g a given action
class you can create arbitrary new meta-fields to describe your fields
with, and use them however you want in that action.



## :#the-unpack-params-method

`unpack_params` (what it was formerly is described in [#012]) result
is a tuple (fixed length array) of the same number as the number of
your arguments. each value of the tuple will be a hash whose each key
and value correspond to one of the bound parameters. which pair goes in
which hash is determined as follows: each of your arguments is resolved
into a function. the function will be run against each of the parameters
in order (of the functions). any first such call whose result is true-
ish, the search is short-circuited. whatever position the function
had in your provided order of functions, the resulting key-value pair
will be inserted into the hash of the corresponding position in the
result tuple WHEW! the number of result pairs is guaranteed to be less
that or equal to the number of bound parameters: it is possible that
bound parameters fail all of the functions, in which case they are not
reflected in the result. above we said `resolved into a function` - if
you pass a ::Symbol, it will send that symbol using :[] to each field,
the true-ish-ness of that result determines whether it is a match. if
you pass `true`, the true function will be used (matches everything),
which is useful only at the end as a catch-all base case.
#todo wtf test-case documentation hello
