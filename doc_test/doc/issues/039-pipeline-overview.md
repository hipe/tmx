# overview of the pipeline

broadly,

  - from some sort of input source (imagine it's a participating asset
    document), we resolve a stream of [#025] "stem" components (somehow).
    (note that the "context" type of stem component is a branch node -
    it contains other stem components, nested arbitrarily deeply. at
    every level below the root level this is probably no longer streaming
    but rather a straightforward structure.)

  - each of those "stems" can become a [#026] "particular" component
    given the "choices" (namely what test suite solution we are targeting).
    if you like, this is a "map" on the previous stream.
    so in effect we have a stream of particular components.

  - an existing test document (let's just say we're talking only about
    fowards synchronization) is parsed into "document nodes", each of which
    *is* either a branch node or an item node, and each of which *might*
    have test-suite-particular meta-information embedded within it
    (for example if it represents a test case, the identifying string
    "bytes" of the test case).



    forwards synchronization overview

    given:

        +---------------+                    +------------+
        | participating |                    |  existing  |
        |   "asset"     |                    |    test    |
        |     file      |                    |    file    |
        +---------------+                    +------------+

        (or any line stream)                 (or any line stream)
                                             (a stub file as a default)

                 |                                  |
    we do:       |                                  |
                 V                                  V
        +-----------+    +------------+        +------------+
        |   stem    |    | particular |        |  existing  |
        | component | -> | component  |        |  document  |
        |  stream   |    |   stream   |        |    tree    |
        +-----------+    +------------+        +------------+
                                \                    /
                                 \                  /
                                  \                /
                                   V              V

                                  [  synchronization  ]
                                             \
                                              \
    and we get:                                V
                                            +------------+
                                            |  modified  |
                                            |    test    |
                                            |  document  |
                                            +------------+

                                        (really just a line stream)
