def app_design_via_recfile(main_recfile, listener):

    from kiss_rdb.storage_adapters.rec import collections_via_main_recfile as func
    colz = func(main_recfile, 'PageNode', _build_datamodel_bridge)

    def export(func):
        exports.append(func)

    exports = []

    @export
    def to_graph_viz_lines_(listener):
        return _to_graph_viz_lines(colz, listener, ad.app_label)

    @export
    def check_app_design(listener):
        return _check_app_design(colz, listener)

    class AppDesign:
        pass

    ad = AppDesign()
    for func in exports:
        setattr(ad, func.__name__, func)

    ad.app_label = _hackishly_derive_app_label(main_recfile)

    return ad


# == Internal Decorators

def something_or_stop(func):
    def use_func(*a, **kw):
        something = func(*a, **kw)
        if something is None:
            raise _Stop()
        return something
    return use_func


# ==

def _to_graph_viz_lines(colz, listener, app_label=None):
    from app_flow._graph_viz_lines_via_big_index \
            import graph_viz_lines_via_big_index_ as func
    try:
        bi = _build_big_index(colz, listener)
        return func(bi, listener, app_label=app_label)
    except _Stop:
        return ()


def _check_app_design(colz, listener):
    try:
        bi = _build_big_index(colz, listener)
    except _Stop:
        return
    assert bi
    def lines():
        yield "Transitions between UI Nodes ok."
    listener('info', 'expression', 'ok', lines)


def _build_big_index(colz, listener):
    node_itr, first_node, trans_itr, first_trans = _these_four(colz, listener)
    nodes = {k: v for k, v in _build_node_dict(first_node, node_itr, listener)}
    attrs = _build_trans_SOMETHING(first_trans, trans_itr, nodes, listener)
    attrs = {k: v for k, v in attrs}
    return _BigIndex(nodes=nodes, **attrs)


class _BigIndex:
    def __init__(self, from_here, to_here, node_names_seen, transitions, nodes):
        self.from_here, self.to_here = from_here, to_here
        self.node_names_seen = node_names_seen
        self.transitions, self.nodes = transitions, nodes


def _build_trans_SOMETHING(trans, trans_itr, nodes, listener):

    from_here = {}
    to_here = {}
    transitions = []
    node_names_seen = {}

    def assert_key(nat_key):
        if nat_key in nodes:
            node_names_seen[nat_key] = None
            return
        _when_strange_transition_boundary(listener, nat_key)
        raise _Stop()

    def touch_list(dct, k):
        if k not in dct:
            dct[k] = []
        return dct[k]

    while True:
        # First, make sure the nodes it references exist
        from_key = trans.initial_state
        to_key = trans.result_state
        assert_key(from_key)
        assert_key(to_key)

        # Then, update three indexes
        new_offset = len(transitions)
        touch_list(from_here, from_key).append(new_offset)
        touch_list(to_here, to_key).append(new_offset)
        transitions.append(trans)

        trans = next(trans_itr, None)
        if trans is None:
            break

    yield 'from_here', from_here
    yield 'to_here', to_here
    yield 'node_names_seen', node_names_seen
    yield 'transitions', tuple(transitions)


def _build_node_dict(node, node_itr, listener):
    seen = {}
    while True:
        k = node.natural_key
        if k in seen:
            _when_node_not_unique(listener, node)
            raise _Stop()
        seen[k] = None
        yield k, node
        node = next(node_itr, None)
        if node is None:
            return

@something_or_stop
def _these_four(colz, listener):

    # Resolve an iterator for all nodes. Make sure there is at least one.
    coll = colz['PageNode']
    node_itr = coll.where(listener=listener)
    first_node = next(node_itr, None)
    if first_node is None:
        if listener.did_error_:
            return
        return _when_none(listener, coll)

    # Resolve an iterator for all transitions. Make sure there is at least one.
    coll = colz['UI_Transition']
    trans_itr = coll.where(listener=listener)
    first_trans = next(trans_itr, None)
    if first_trans is None:
        if listener.did_error_:
            return
        return _when_none(listener, coll)

    return node_itr, first_node, trans_itr, first_trans


def _hackishly_derive_app_label(main_recfile):
    if not isinstance(main_recfile, str):
        return
    from os.path import basename, splitext
    bn = basename(main_recfile)
    stem, ext = splitext(bn)
    return stem  # whatever


def _when_strange_transition_boundary(listener, nat_key):
    def lines():
        yield f"No such UI node: {nat_key!r}"
    listener('error', 'expression', 'not_found', lines)


def _when_node_not_unique(listener, node):
    def lines():
        yield f"Multiple UI nodes with same natural key: {node.natural_key!r}"
    listener('error', 'expression', 'not_unique', lines)


def _when_none(listener, coll):
    def lines():
        yield f"No {coll.fent_name} in {coll.recfile}."
        yield f"(Need at least one.)"
    listener('error', 'expression', 'empty_collection', lines)


def _build_datamodel_bridge(colz):
    from dataclasses import dataclass
    from enum import Enum, unique as unique_enum

    @dataclass
    class PageNode:
        natural_key: str

    @dataclass
    class UI_Transition:
        initial_state: 'PageNode'
        result_state: 'PageNode'
        transition_type: 'UI_Transition_Type'

        IS_IN_MAIN_RECFILE = True

    @unique_enum
    class UI_Transition_Type(Enum):
        tt_one = 'tt_one'
        tt_two = 'tt_two'

    return {'PageNode':PageNode, 'UI_Transition':UI_Transition,
            'UI_Transition_Type':UI_Transition_Type}


class _Stop(RuntimeError):
    pass

# #born
