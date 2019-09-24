---
title: "functional pipelines"
date: "2018-09-02T19:10:48-04:00"
---
# functional pipelines

this is scratching a surface. this article is stub. i can help expand it.

  - currently "functional pipeline" can refer to the broad idea which begins
    to get introduced semi-formally at document birth (months after project
    birth); but it can also refer to several specific ideas that can be at
    odds with each other; the subject of the next two bullets.

  - NOTE :[#463.B] refers to the pipeline workflow we use at document birth,
    which is what is depicted in our sibling digraph document.

  - in contrast, we will use :[#463.C] to be a hazy placeholder for this
    future vaporware idea of configurable, functional pipelines.

  - often the distinction isn't important except for complicated
    synchronizations; but since there is nonetheless potential for ambiguity,
    we must always distinguish which we mean when we use this node tag.

  - we are familiar with the idea of [#457.A] JSON being the lingua franca.

  - we can extend this idea further when we are syncing. the schema of the
    near collection sort of serves as a lingua franca of its own for the
    various far collections (producers, actually) that want to feed into it.

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




## <a name=D></a> case study: how "deny list" came about

this tricky pipeline came about as a balance of several requirements:

  - the consumer needs its producer to have yes the custom field (that
    combines our two idealized "raw" fields of label and url)

  - the consumer needs to have a custom key that comes from a function that
    takes as argument random access to any (so all) raw fields.

  - as always the consumer can't have "strange" fields

  - at #history-A.1 we no longer want any markdown coming out from the
    "raw" producer scripts directly.

so:
  - the below "map" (far custom mapper) adds the custom field
    (but does not, like we do in other places, remove fields)

  - "inspect" gets to "see" everything that will have ever existed

  - the new "deny list" strips out a known set of fields so the consumer
    won't complain.

(comme ça:)

    .                                                      (start)
                                                              V
                +--------+                            +------------+
    (done) key, | widget | <--(deny list)             | url, label |
                +--------+         ^                  +------------+
                                   |                        |
                               (inspect)                  (map)
                                   |                        V
                +--------------------+              +--------------------+
           key, | widget, url, label |<-- (keyer) <-| widget, url, label |
                +--------------------+              +--------------------+


ideally, with [#463.C] custom functional pipelines, we could accomplish
the above with a series of maps only; with no need for special implementation
of a deny list.




## (document-meta)

  - #history-A.1
  - #abstracted
