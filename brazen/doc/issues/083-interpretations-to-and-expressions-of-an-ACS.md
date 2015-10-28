# interpretations to and expressions of an ACS [#083]



## context & scope

here we specify how both [#089] "compound" and "terminal" components of
an ACS typically handle input & output from and to various "modalities."
to be cheeky, we refer to input as "interpretation" and output as
"expression".




## "modalities"..

..is our catch-all term that refers broadly to "substrate" and
"encoding" when it comes to IO. for example, "JSON" is one modality.
there is a particular way that we "interpret from this modality, and a
particular way we "express to" it as well.




## what is a semi-formal definition for an ACS?

just so we agree on terms in this document,

  • here we conceive of an ACS as a directed graph, a tree,

      * with every child node having a name that is
        unique in the context of its parent

      * and that name (let's just say for now) is a name that
        isomorphs cleanly with the spec at [#013]:API.A,

      * ergo the root node has no name.

      * furthermore we'll conceive of the children of these
        nodes as being ordered.

      * nodes that have children have nothing but children, and nodes
        that have no children we've called a variety of things (e.g "field",
        "atom") but we'll call "leaf" for now.
_
