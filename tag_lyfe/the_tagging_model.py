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


"""
the document object model for all strings as it pertains to taggings:

    [ document_pair [ document_pair [..]]] end_piece

    document_pair = separator_string tagging

this "structure grammar" is intended to work for all strings.
"""


class DocumentPair:

    def __init__(self, sep_s, tagging):
            self.separator_string = sep_s
            self.tagging = tagging

    is_end_piece = False


class EndPiece:

    def __init__(self, sep_s):
            self.separator_string = sep_s

    is_end_piece = True


def tag_subtree_via_tags(tags):
    """ :[#707.B]: is that for now we don't want a dedicated tag subtree class.

    we will use plain tuples of tags for now but: one possible reason to
    complexify this is so that the "subtree" maintains an internal index
    (dictionary) of the tags it has by tag stem. but meh for now.
    """
    return tuple(tags)  # accord to [#707.B]: use tuples here for now


"""
BEGIN: new in this edition: consult [#705] the tagging model (digraph)
"""


def tagging_via_sanitized_tag_stem(stem):
    _name_component = BareNameComponent(stem)
    return deep_tagging_via_name_components((_name_component,))


def tagging_via_sanitized_pieces(pcs):
    """NOTE - this will go away #open [#707.I] after we unify the grammars
    this is here for conveninece as a legacy way to build the thing
    """

    _ = [BareNameComponent(s) for s in pcs]
    return deep_tagging_via_name_components(_)


def deep_tagging_via_name_components(ncs):
    """ new in this edition: consult [#705] the tagging model (digraph)"""

    itr = iter(reversed(ncs))
    curr = _TailNode(next(itr))
    for name_component in itr:
        curr = _BranchNode(curr, name_component)
    return _Tagging(curr)


class _Tagging:

    def __init__(self, node):
        self.root_node = node

    def to_string(self):
        itr = self.root_node._each_name_component()
        pieces = ['#', next(itr)._surface_string()]
        for nc in itr:
            pieces.append(':')
            pieces.append(nc._surface_string())
        return ''.join(pieces)


class _Node:

    def __init__(self, name_component):
        self._name_component = name_component

    @property
    def tag_stem(self):
        return self._name_component._deep_string()


class _BranchNode(_Node):

    def __init__(self, child, name_component):
        super().__init__(name_component)
        self.child = child

    def _each_name_component(self):
        yield self._name_component
        for nc in self.child._each_name_component():
            yield nc

    is_deep = True


class _TailNode(_Node):

    def _each_name_component(self):
        yield self._name_component

    is_deep = False


class DoubleQuotedStringNameComponent:

    def __init__(self, sexps):

        def surface_string_initially():
            s = build_surface_string()
            self._surface_string = lambda: s
            return self._surface_string()

        def build_surface_string():
            pieces = ['"']
            for typ, s in sexps:
                if 'raw_string' == typ:
                    pieces.append(s)
                else:
                    assert('escaped_character' == typ)
                    pieces.append('\\')  # #(Case1040) 1/2
                    pieces.append(s)
            pieces.append('"')
            return ''.join(pieces)

        def deep_string_ininitially():
            s = build_deep_string()
            self._deep_string = lambda: s
            return self._deep_string()

        def build_deep_string():
            pieces = []
            for typ, s in sexps:
                if 'raw_string' == typ:
                    pieces.append(s)
                else:
                    assert('escaped_character' == typ)
                    pieces.append(s)  # (Case1040) 2/2

            return ''.join(pieces)

        self._surface_string = surface_string_initially
        self._deep_string = deep_string_ininitially


class BareNameComponent:

    def __init__(self, s):
        def same():
            return s
        self._surface_string = same
        self._deep_string = same


# END


# #history-A.2: yet another new and improved model to accomodate quotes
# #history-A.1: begin actually using this to build native structures from AST's
# #born.
