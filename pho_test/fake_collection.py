from contextlib import nullcontext as _nullcontext
from collections import namedtuple as _nt


def omg_fake_bcoll_via_lines(lines):

    from text_lib.magnetics.graph_via_ASCII_art import func
    graph = func(lines)

    bcoll = _omg_bcoll_via_ASCII_art_graph(graph)

    from pho import _Notecards as func  # imagine coll_via_bcoll
    return func(bcoll)


class _omg_bcoll_via_ASCII_art_graph:

    def __init__(self, graph):
        self._graph = graph
        self._graph_index = _index_the_graph(graph)
        self._cache = {}

    def retrieve_entity(self, eid, listener):
        return self._build_dereferencer(listener)(eid)

    def open_identifier_traversal(self, _):
        return _nullcontext(_Identifier(k) for k in self._graph.nodes.keys())

    def TO_EIDS_FOR_TEST(self):
        return self._graph.nodes.keys()

    def open_entities_via_EIDs(self, eids, listener):
        deref = self._build_dereferencer(listener)
        these = (deref(eid) for eid in eids)
        return _nullcontext(these())

    def _build_dereferencer(self, _listener):
        def dereference(eid):
            nc = self._cache.get(eid)
            if nc is None:
                nc = _fake_notecard(eid, self._graph_index)
                self._cache[eid] = nc
            return nc
        return dereference


def _fake_notecard(eid, gi):
    from pho.notecards_.notecard_via_definition import func
    core_attrs = {k: v for k, v in _do_fake_notecard(eid, gi)}
    return func(eid, core_attrs, None)


def _do_fake_notecard(eid, gi):
    use_prev = use_HCT = use_next = None

    if 'd' == eid[-1]:  # lol
        use_HCT = 'document'

    use_heading = r"Hello I am the heading for {eid!r}"

    use_body = f"Hello i am the body for {eid!r} KISS For now"
    # (no newline at end of line so it looks like the accidentally bad way)

    use_parent = gi.parent_of.get(eid)
    use_children = gi.children_of.get(eid)

    yield 'parent', use_parent
    yield 'previous', use_prev
    yield 'natural_key', None
    yield 'hierarchical_container_type', use_HCT
    yield 'heading', use_heading
    yield 'document_datetime', None
    yield 'body', use_body
    yield 'children', use_children
    yield 'next', use_next
    yield 'annotated_entity_revisions', None


def _index_the_graph(graph):
    kw = {k: v for k, v in _do_index_the_graph(graph)}
    return _GraphIndex(**kw)


_GraphIndex = _nt('_GraphIndex', ('children_of', 'parent_of'))


def _do_index_the_graph(graph):

    children_of, parent_of = {}, {}

    def _add_parent_child(parent_EID, child_EID):
        if (arr := children_of.get(parent_EID)) is None:
            children_of[parent_EID] = (arr := [])
        assert child_EID not in arr
        arr.append(child_EID)

        assert child_EID not in parent_of
        parent_of[child_EID] = parent_EID

    def _see_sib(*_):
        xx('big fun')  # don't do the big trick here do it there

    these = {
        'add_parent_child_relationship': _add_parent_child,
        'see_sibling_relationship': _see_sib,
    }

    for k, *args in _do_do_index_the_graph(graph):
        these[k](*args)

    yield 'children_of', children_of
    yield 'parent_of', parent_of


def _do_do_index_the_graph(graph):
    for edge in graph.to_classified_edges():

        first = edge.first_node_label
        second = edge.second_node_label

        # Vertical edges can never have arrowheads
        if edge.is_verticalesque:
            assert not any((edge.points_to_first, edge.points_to_second))
            yield 'add_parent_child_relationship', first, second
            continue

        # Horizontal edges must always point to the right
        xx("haven't used horizontal arrows yet")
        assert not edge.points_to_first
        assert edge.points_to_second
        yield 'see_sibling_relationship', first, second


class _Identifier:
    def __init__(self, s):
        self._string = s

    def to_string(self):
        return self._string


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
