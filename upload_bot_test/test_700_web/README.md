# README about the "test 700 web" tree

## why "700"?

naming this node "700" is something of a convention. it accords with
a "regression-friendly" naming convention for toplevel test nodes that
we use elsewhere, where we progress from low-level to high-level:

  - 100's: private models
  - 200's: private magnetics
  - 300's: public models
  - 400's: public magnetics
  - 500's: API calls ("actions")
  - 600's: CLI
  - 700's: web

(actually this might be off-by-one around the 500's. we might have
one other thing before "API calls". but meh.)




## why JSON dumps here?

we don't love that there's versioned code we don't hand-edit around
here, alongside other code that we do. however, the design objective
of honoring "regression-friendly" ordering of our tests has outweighed
other aesthetic concerns.

this design consequence is only as certain as [#303] postman is.




## about the name of postman dumps

when we first versioned this one JSON dump we sort of arbitrarily named
it "whatever-and-ever.postman-collection.json". as it would turn out, we
accidentally came close to employing the exact convention postman itself
uses when exporting collections:

    «collection name».postman_collection.json

but note two things about this:

  - it uses an underscore (not dash) for that last part -
    "postman_collection" not "postman-collection".

  - (not shown) if you have spaces in the name of your collection,
    these spaces will end up in the filename here.

all of this is just little details of the way postman exports JSON dumps,
but it's relevant to us because we'd rather not fight against the small
decisions postman makes for tasks we're going to repeat a lot.

as such,

  - in our collections thing _from the postman GUI_, change the name of
    our collection to use dashes not spaces. actually, maybe we should
    use underscores not dashes, so that our exported filenames are self-
    consistent.

  - rename (as in move) the file to use the underscores form.

when we do this, we will save ourselves this one step everytime we export
the tests, of having to select the correct name.




## (document-meta)

  - #born.
