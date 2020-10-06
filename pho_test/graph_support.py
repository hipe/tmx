def build_custom_index(lines):
    # The point is, let tests assert against content without needing to worry
    # about order. also centralize any other accomodation for formatting
    # choices we make to here

    nodes, assocs_via_node_key, subgraphs = {}, {}, {}
    import re

    node_id = 'n([0-9]+)(?:_([a-zA-Z0-9]+))?'

    inside = r"\[(.+)\]"

    # Ignore These At The Beginning

    these = []
    these.append(('open digraph', re.compile(r'^digraph g \{')))
    these.append(('this thing', re.compile(r'^[ ]+rankdir=')))

    # Subgraph Matcher And Action (custom action)

    subgraph_rx = re.compile(f'^[ ]*subgraph[ ]cluster_{node_id}[ ]\\{{$')
    label_rx = re.compile('^[ ]+label="(?P<escaped>.+)"$')

    def handle_subgraph_match(nmaj, nmin, stack):
        line = stack[-1]
        if (md := label_rx.match(line)) is None:
            raise _ParseError(f"expecting label - {line!r}")
        stack.pop()
        sg = _Subgraph(_key(nmaj, nmin), md['escaped'])
        assert sg.key not in subgraphs
        subgraphs[sg.key] = sg

    # Association Matcher and Action

    assoc_rx = re.compile(f'^[ ]*{node_id}->{node_id}(?:{inside})?;$')

    def handle_assoc_match(n1maj, n1min, n2maj, n2min, inside):
        n1key = _key(n1maj, n1min)
        n2key = _key(n2maj, n2min)
        assoc = _Association(n1key, n2key, inside)
        if assoc.key not in assocs_via_node_key:
            assocs_via_node_key[assoc.key] = []
        assocs_via_node_key[assoc.key].append(assoc)

    # Node Matcher and Action

    node_rx = re.compile(f'^[ ]*{node_id}{inside};$')

    def handle_node_match(n1maj, n1min, inside):
        nkey = _key(n1maj, n1min)
        node = _Node(nkey, inside)
        assert node.key not in nodes
        nodes[node.key] = node

    # Matching closing curlies has a little magic

    closing_curly_rx = re.compile('^(?P<margin>[ ]*)\\}$')

    # Parsing Grammar That Reorders Itself In Real Time, Just As An Exercise

    def reorder(i):
        assert 0 < i
        new_order_offsets = (i, *range(0, i), *range(i+1, leng))
        assert leng == len(new_order_offsets)
        return tuple(order[i] for i in new_order_offsets)

    order = (
        (assoc_rx, handle_assoc_match),
        (node_rx, handle_node_match),
        )

    leng = len(order)
    rang = range(0, leng)

    stack = list(reversed(lines))
    exp_stack = list(reversed(these))

    # Assert hard-coded head expectations
    while True:
        act = stack[-1]
        exp_desc, exp_rx = exp_stack[-1]
        if exp_rx.match(act):
            exp_stack.pop()
            stack.pop()
            if len(exp_stack):
                continue
            break
        raise _ParseError(f"expecting {exp_desc} had: {act!r}")

    while True:
        line = stack.pop()

        # First we attempt to match the most common two things, node lines
        # and assoc lines. And we do the clever self-optimizing (lol) thing

        continue2 = False
        for i in rang:
            rx, then = order[i]
            if (md := rx.match(line)):
                then(*md.groups())
                if i:
                    order = reorder(i)
                continue2 = True
                break
        if continue2:
            continue

        # Then, we hand write a check for this more complicated parser, which
        # we could expand into a thing if we wanted to torture ourselves

        if (md := subgraph_rx.match(line)):
            handle_subgraph_match(* md.groups(), stack)
            continue

        if (md := closing_curly_rx.match(line)):
            if len(md['margin']):
                continue
            break

        raise _ParseError(f"didn't recognize this line: {line!r}")
    assert not stack
    return _CustomIndex(subgraphs, nodes, assocs_via_node_key)


class _CustomIndex:
    def __init__(self, subgraphs, nodes, assocs_via_node_key):
        self.subgraphs = subgraphs
        self.nodes, self.assocs_via_node_key = nodes, assocs_via_node_key


class _Subgraph:
    def __init__(self, key, escaped):
        self.escaped = escaped
        self.key = key


class _Association:
    def __init__(self, left, right, inside):
        self.key = left
        self.rigth_key = right
        self.inside = inside


class _Node:
    def __init__(self, key, inside):
        self.key = key
        self.inside = inside


def _key(nmaj, nmin):
    return (int(nmaj), int(nmin))  # ..


class _ParseError(RuntimeError):
    pass

# #born
