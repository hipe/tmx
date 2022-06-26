import re


def graph_viz_lines_via_big_index_(bi, listener, app_label=None):
    yield "digraph g {\n"
    assert bi.node_names_seen
    ch_indent = ''  # child indent. empty string for flush-left

    if app_label:
        label = _escape_attr(app_label)
        yield f'label="\\n{label}"\n'

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
    label = _escape_attr(_label_via_natural_key(trans.transition_type))
    yield f'{indent}{from_key}->{to_key}[label="{label}"]\n'


def _lines_via_node(node, indent):
    _assert_key(node.natural_key)
    label = _escape_attr(_label_via_natural_key(node.natural_key))
    yield f'{indent}{node.natural_key}[label="{label}"]\n'


def _escape_attr(s):
    assert '"' not in s  # ..
    return s


def _label_via_natural_key(nk):
    return nk.replace('_', ' ')


def _assert_key(key):
    assert re.match(r'^[a-zA-Z_]+$', key)

# #born
