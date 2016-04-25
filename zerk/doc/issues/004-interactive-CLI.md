# interactive-CLI

## intro

interactive CLI was originally the only sort of interface that [ze] was
designed to support. the other two "bundled modalities" evolved out of it,
and now the three bundles modalities are counterparts to each other.

interactive CLI started as its own thing and then was overhauled and
rewritten from the ground up to be a layer on top of [ac]. it stands as
a good complement to [ac] because it is an interface for tree-like
structures.

the interactive CLI that this node offers is generally referred to as "iCLI".




## name conventions (for development)

at writing this iCLI node is largely "self-contained": that is, it
doesn't have a very large external API - the user simply "applies" this
library (with what little external API it *does* have) to an existing ACS
tree, and if all goes well (and the tree follows the right conventions), we
generate an interactive CLI client for that tree.

recall from [#bs-028] that we see every method as having a name that is
either "public API", "library-scope", or "file-private". because the
iCLI has a public API that is so thin as to be almost non-existent, most of
the methods in its codebase fall into the latter two categories of scope.

if we were to follow the referenced convention to a tee, the visual
effect of this would be that most method names here woudl *end* in
underscores and almost no method names here would have `normal_names`.

because we see this as an underutilization of the most readable of the
method name patterns, we have re-arranged the conventions locally:


  • `normal_name` - "library scope" (that which under [#bs-028] we would
                    use a `name_like_this_` or similar). (any public API
                    method names will use this same pattern, but should
                    be annotated with a comment.)

  • `name_like_this_` - probably to comport with a name that's in [ze]
                        *but not* in iCLI (probably for the ivocation
                        sub-lib).

  • `name_like_this__` - perhaps to emphasize that it is only called 1x
                         and *in* iCLI.

  • `_name_like_this` `__or_this` `___or_this` are as [#bs-028].
_
