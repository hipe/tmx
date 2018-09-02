# functional pipelines

this is scratching a surface. this article is stub. i can help expand it.

  - we are familiar with the idea of [#417.A] JSON being the lingua franca.

  - we can extend this idea further when we are syncing. the schema of the
    near collection sort of serves as a lingua franca of its own for the
    various far collections (producers, actualy) that want to feed into it.

  - when in a sync we target a "markdown table" format (which, at writing
    we always do); we usually (always?) do a thing where we combine something
    like a "url" field and something like a "label" or "name" field to make
    what's in effect an aggregate field in the form of a markdown link.

  - in the old days we accomplished syncing through a smelly combination of
    the producer script "knowing" "deeply" that it was targeting a MD table;
    and in some cases it providing a "keyerer" to fuzzify the matching (etc)

  - now, in the new days, the smell isn't completely erased because the
    producer scripts still have MD table awareness; but things are more
    abstracted:
      - keyer takes as an argument the whole dictionary, not just the
        original key

      - now there can also be a mapper so that the producer script doesn't
        have to be written with a "deep", structural concern for the  ..




## dream not yet realized

currently:
    +--------------------+              +--------------------------+
    | near collection    |              | far collection           |
    | (a markdown table) |     <---     | (w/ special funcs for MD)|
    +--------------------+              +--------------------------+


ideally:

    +-------------+      +-----------+
    | near coll 1 | <--- | map for 1 | <-+
    +-------------+      +-----------+    \__+-------------------------+
                                           __| far collection ("pure") |
    +-------------+      +-----------+    /  +-------------------------+
    | near coll 2 | <--- | map for 2 | <-+
    +-------------+      +-----------+




## (document-meta)

  - #abstracted
