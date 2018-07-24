"""
ABOUT THIS FILE:
we developed the parsing of queries for tags before we developed the parsing
of "tag subtrees" (not yet defined) from strings. (this was because queries
are more complicated than tag subtrees, and so we wanted to frontload this
harder parsing work so that we would fail fast if our parsing approach is bad.)

there's two distinct steps in a query's lifecycle: parsing it then executing
it. we are timelining our development in a query-feature-centric way so that
we parse query features and also test their execution typically in the same
commits (feature by feature).

this presents a catch-22: we need a tag model to be present in order to test
query execution; but we can't parse tag subtrees from strings until we have
the parsing of the queries done (by our own design). fortunately we
shouldn't be parsing for tag subtrees for this purpose anyway..

:[#707.D]
"""


def tag_subtree_via_tags(tags):
    """ :[#707.B]: is that for now we don't want a dedicated tag subtree class.

    we will use plain tuples of tags for now but: one possible reason to
    complexify this is so that the "subtree" maintains an internal index
    (dictionary) of the tags it has by tag stem. but meh for now.
    """
    return tuple(tags)  # accord to [#707.B]: use tuples here for now


def deep_tag_via_sanitized_pieces(pcs):
    last = len(pcs) - 1

    def f(cursor):
        if cursor == last:
            return _TailTag(pcs[cursor])
        else:
            return _DeepTag(pcs[cursor], f(cursor + 1))
    return f(0)


def tag_via_sanitized_tag_stem(sanitized_tag_stem):
    return _SimpleTag(sanitized_tag_stem)


class _DeepTag:

    def __init__(self, sanitized_tag_stem, child):
        self.tag_stem = sanitized_tag_stem
        self.child = child

    is_deep = True


class _TailTag:

    def __init__(self, sanitized_tag_stem):
        self.tag_stem = sanitized_tag_stem

    is_deep = False


class _SimpleTag:

    def __init__(self, sanitized_tag_stem):
        self.tag_stem = sanitized_tag_stem

    is_deep = False

# #born.
