# autoloader implementation [#058]



## note :#note-1

it "feels" as though a file tree is really under custodianship of
two places: when we're trying to get at a file tree from the
coming from the perspective of a module, its file tree is memoized
inside of the module object itself. however in this case, before
the module (maybe class) is even created ("loaded"), we need to get
at its file tree first to see if there's a corefile to load
(otherwise we autovivify a module). these parallel trees ..

we need to peek at the file tree before its corresponding module/
class has been created ("loaded") to determine whether there is a
core file to load (otherwise we autovivify). see [#058] #note-1




## note :#note-2

when there is no eponymous file and there is no core file but there
*is* a directory-looking entry on the filesystem, AUTOVIVIFY using
OUR OWN NAMING CONVENTION ..




## note :#note-3

when it comes time to load the filesystem asset for a given const, we
have to answer this tree of questions:

  - is there a corresponding eponymous file?
  - is there a corresponding eponymous directory?
    - is there a corefile?

one approach would be to make possibly three successive roundtrips to
the filesystem to answer the three questions:

    ::File.exist? «the eponymous file path»
    ::File.directory? «the eponymous directory»
      ::File.exist? «the corefile»  # if the above is true

now, it is the case that we are optimizing to minimize trips to the
filesystem. an operation available to us that is not used above is
that of performing a directory listing.

if we follow the assumptions of #note-4, we can minimize trips to the
filesystem and still answer the above questions with an algorithm that
looks nothing like the above. rather than ask the filesystem questions
about individual files, we only ever make (and cache) directory listings.
in effect we end up with a cached tree reflecting the whole filesytem,
built one directory at a time only as needed.




## note :#note-5

because this is a const missing but there is already a value
associated with this (filesystem) entry group, this implies
neccessarily (we think) that a "wrong" const name scheme was
used either then or now. although we could be lenient and produce
the value anyway, it's better that we enforce a consistent scheme.
