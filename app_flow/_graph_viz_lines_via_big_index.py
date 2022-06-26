import re


def graph_viz_lines_via_big_index_(bi, listener):
    yield "digraph g {\n"
    assert bi.node_names_seen
    ch_indent = ''  # child indent. empty string for flush-left

    yield '/* Nodes */\n'
    for k in bi.node_names_seen.keys():
        for line in _lines_via_node(bi.nodes[k], ch_indent):
            yield line

    yield '/* Transitions */\n'
    for trans in bi.transitions:
        for line in _lines_via_transition(trans, ch_indent):
            yield line

    yield "}\n"


def _lines_via_transition(trans, indent):
    from_key, to_key = trans.initial_state, trans.result_state
    _assert_key(from_key)
    _assert_key(to_key)
    label = trans.transition_type
    assert '"' not in label
    yield f'{indent}{from_key}->{to_key}[label="{label}"]\n'


def _lines_via_node(node, indent):
    _assert_key(node.natural_key)
    yield f'{indent}{node.natural_key}[label="{node.natural_key}"]\n'


def _assert_key(key):
    assert re.match(r'^[a-zA-Z_]+$', key)

# #born
