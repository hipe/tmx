# ragel notes

## freaky experiments in optimization :[#here.B]

the ruby-hosted implementation of ragel has you do it this way: either
volitionaly or not, you designate a single object that will serve as the
context (binding) within which all the parsing will happen for parsing one
particular input.

you call `%% write data` within the context of this object and in so doing
it becomes what we'll call the "holder" for all of the data that comprises
your grammar, which at writing is something like 14 (later "N") arrays of
lookup integers.

in the example that ships with ragel, this context is `Kernel` which is
sufficient for demonstration but is not appropriate for a project.

examples from the wild try to make this more idiomatic ruby by using
an arbitrary, dedicated object (of an arbitrary, plain old class) to be
the "holder" of this data.

this arrangement is adequate as a proof-of-concept that ragel can be
adapted to ruby, and as well it works in one-off scenarios where you are
only parsing one input string per grammar per runtime. however, at our
scale issues with this architecture are several:

  - like most grammars, ours is of course static: it doesn't change during
    the lifetime of our runtime. to allocate new memory each time a parse
    is invoked to hold the data that represents our grammar (N arrays) is
    bad style when not also a waste of resources.

  - in response to the above, if you were to somehow try to re-use this
    same "holder" of the grammar data across different parse ivocations,
    this would be awful because the ivar space of the instance is used for
    parse-specific concerns. (a safe variant of this would be to apply the
    "dup-and-mutate" prototype pattern, which we are considering but see
    the next point.)

  - in the generated parsing logic, this current hosting implementation
    makes a method call every single time every single one of these arrays
    is accessed. again this is wasted overhead, because A) as explained
    above, the grammar won't change during the lifetime of the parse so
    so it is not the case that other methods will need to access/mutate
    these data arrays and so B) accessing these data thru method calls
    is significantly slower than simply dereferencing local variables.

we have a workaround fix that addresses all three of these issues, but
it comes at a cost, which takes some explaining:

although we can assign to local variables programmatically through a ruby
`binding` (which is more than a little weird looking), we cannot
programmatically declare variables in a ruby scope (nor should we
want to).

so, for now we have to "hand write" the variable declaration statements
for the N arrays. this introduces a dependency because now our non-generated
(viz "hand-written") code needs to know the list of N variable names, and
if the ragel implementation changes (which it should be allowed to) our
grammar file could break. (although fixing it will be trivial.)

when we play with making our own ruby adaptation of ragel we will address
all of this.

but to conclude, our fix is to do the following:

  - the arrays that hold the grammar data are lazily memoized: though
    written in static (generated) code, these arrays are allocated lazily
    on first parse and then each subseqent parse will use these same data
    arrays.

  - the "parse context" (object) is of course dedicated to one parse.
    although we could try to replicate the arrangement of using method
    called (`attr_reader`-style) to access the arrays, we'd rather etc..
