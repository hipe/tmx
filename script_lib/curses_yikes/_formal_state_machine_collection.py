from collections import namedtuple as _nt


# {ffsa|FFSA} = formal finite state automaton (as opposed to the instance)


def build_formal_FSA_via_definition_function_(
        house_module_string, defnf, **kw):
    ffname = defnf.__name__
    ffsa_key = house_module_string, ffname
    return _build_FFSA(ffsa_key, defnf(), **kw)


class _StateMachine:

    def __init__(self, ffsa):
        self.FFSA = ffsa

    def _init_state_machine(self):
        self._nodes['initial']  # validate the existence of the node
        self._state_name = 'initial'
        return self

    def MAKE_A_COPY(self):
        otr = self.__class__(self.FFSA)
        otr._state_name = self._state_name
        return otr

    def move_to_state_via_transition_name(self, tn):
        trans = self.transition_via_transition_name(tn)
        if not trans:
            xx(f"whoopsie, can't trans from {self._state_name!r} OVER {tn!r}")
        self.accept_transition(trans)

    def state_name_via_transition_name(self, tn):
        return self.transition_via_transition_name(tn).right_node_name

    def transition_via_transition_name(self, tn):
        return self._first_trans(lambda t: tn == t.condition_name)

    def _first_trans(self, condition):
        for t in self._each_transition():
            if condition(t):
                return t

    def _each_transition(self):
        node = self._nodes[self._state_name]
        transs = self._transitions
        for i in node.transitions_from_here:  # could have made it dict oh well
            yield transs[i]

    def accept_transition(self, trans):
        self._state_name = trans.right_node_name  # should be no need to valid

    @property
    def state_name(self):  # no NOT make this plain old writable
        return self._state_name

    @property
    def _nodes(self):
        return self.FFSA.nodes

    @property
    def _transitions(self):
        return self.FFSA.transitions


def _holy_smokes_merge_FFSAs(one, two):
    """
    aw snap here we go again with yet another syncing algorithm:
    - Preserve the original order of the left graph, in terms of how its
      transitions were ordered in the definition with respect to each other
    - The right graph can add new states and it can add new transitions that
      point to existing states (i.e. LHS or RHS) but it cannot..:
    - The right graph cannot rewrite an existing transition on an existing
      state at all (like it cannot change what state the "RHS" points to, it
      cannot add an action (FOR NOW), it cannot even be completely identical.
      It simply can't model an existing transition name on the existing state)
    - For those transitions that the right graph adds to existing nodes,
      each such transition MUST indicate its insertion point along in the
      transitions of the left state with the fancy DSL
    - Multiple new transitions that share an insertion point will end up
      adjacent to each other in definition order
    - New states (and so new transitions) are simply added to the result
      graph in their definition order AFTER all the existing states have
      been traversed and processed as above
    """

    pool, deferred = _build_merge_plan(one, two)

    transitions = _transitions_via_merge_plan(pool, deferred, one, two)
    transitions = tuple(transitions)  # NECESSARY

    one_key, two_key = one.FFSA_key, two.FFSA_key
    rang = range(0, max(len(one_key), len(two_key)))
    merged_key = tuple('+'.join((one_key[i], two_key[i])) for i in rang)

    return _formal_state_machine_via_transitions(transitions, merged_key)


def _transitions_via_merge_plan(pool, deferred, one, two):

    one_transitions = one.transitions
    one_num_transitions = len(one_transitions)
    two_transitions = two.transitions

    # What is the offset of the first transition before which you insert?
    some = len(pool)
    if some:
        these_keys = list(pool.keys())
        count = these_keys[0]
    else:
        count = one_num_transitions

    # The original transitions before the first insert stay exactly the same
    for i in range(0, count):
        yield one_transitions[i]

    # Is the greatest existing transition offset imaginary because #here1?
    if some and these_keys[-1] == len(one_transitions):
        insert_these_right_before_deferred = pool.pop(these_keys.pop())
    else:
        insert_these_right_before_deferred = ()

    # Now melt down the the zero or more "rows" of our "insertion table"
    # while we traverse the rest of the existing transitions

    def new_T(t):
        new_T.output_offset += 1
        return t._replace(transition_offset=new_T.output_offset)
    new_T.output_offset = count - 1

    for i in range(count, one_num_transitions):

        # Are there any new transitions to output before this one?
        arr = pool.pop(i, None)
        if arr is not None:
            for two_offset in arr:
                yield new_T(two_transitions[two_offset])

        # Output the existing transition
        yield new_T(one_transitions[i])

    # The special case of new transitions that are to be inserted "before"
    # the imaginary endcap transition at the very end of existing transitions
    for i in insert_these_right_before_deferred:
        yield new_T(two_transitions[i])

    assert not pool

    # Deferred transitions (ones that introduce whole new states)
    for t in deferred:
        yield new_T(t)


def _build_merge_plan(one, two):  # (see caller)

    def will_insert_before(left_offset, right_offset):
        if (arr := insert_before.get(left_offset)) is None:
            insert_before[left_offset] = (arr := [])
        arr.append(right_offset)

    insert_before = {}
    one_nodes = one.nodes
    wti_via_key = two.where_to_insert  # (imagine `or _empty_dict`)

    # For each new transition, either process it now or process it later
    deferred = []
    for t in two.transitions:
        trans_k = t.left_node_name, t.condition_name
        wti = wti_via_key.get(trans_k)

        # If the LHS of this transition is a new state name, defer it
        existing_node = one_nodes.get(t.left_node_name)
        if existing_node is None:
            deferred.append(t)
            if wti:
                xx(f"shouldn't have a WTI for {trans_k!r} because is new node")
            assert not wti
            continue

        # The LHS of this transition exists already..
        trans_offset_via = one.THIS_ONE_INDEX_FOR(existing_node.node_name)
        transition_offset = trans_offset_via.get(t.condition_name)

        # Does this transition exist (by condition name) in the state already?
        if transition_offset is not None:
            xx(f"already exists, can't redefine: {trans_k!r}")

        # This transition is new to the state
        if not wti:
            xx(f"must have WTI because state exists: {trans_k!r}")

        stack = list(reversed(wti))
        typ = stack.pop()
        # :#here2:
        if 'insert_before' == typ:
            before_who, = stack
            before_offset = trans_offset_via[before_who]  # ..
        elif 'at_beginning' == typ:
            assert not stack
            before_offset = existing_node.transitions_from_here[0]
        else:
            assert 'at_end' == typ
            before_offset = existing_node.transitions_from_here[-1] + 1
            # (above offset might be imaginary. may be #not-covered) :#here1

        will_insert_before(before_offset, t.transition_offset)
    return insert_before, tuple(deferred)


def _build_FFSA(ffsa_key, defs, **kw):
    transitions = tuple(_transitions_via_definition(defs))
    return _formal_state_machine_via_transitions(transitions, ffsa_key, **kw)


def _transitions_via_definition(defs):
    count = 0
    for tup in defs:
        yield _transition_via_tuple(count, tup)
        count += 1


def _formal_state_machine_via_transitions(
        transitions, ffsa_key, where_to_insert=None):

    def autovivify_node(name):
        if (node := nodes.get(name)) is None:
            nodes[name] = (node := _MutableNode(name))
        return node

    nodes = {}

    for t in transitions:
        i = t.transition_offset
        autovivify_node(t.left_node_name).transitions_from_here.append(i)
        autovivify_node(t.right_node_name).transitions_to_here.append(i)

    wti = None
    if where_to_insert:
        wti = {k: v for k, v in _where_to_insert(where_to_insert)}

    return _FormalStateMachine(transitions, nodes, ffsa_key, wti)


def _where_to_insert(wti):  # just validates the syntax

    def which(stack):  # #here2
        typ = stack.pop()
        if typ in ('at_beginning', 'at_end'):
            assert not stack
            return (typ,)
        assert 'insert_before' == typ
        who, = stack
        return 'insert_before', who

    for (sn, tn, *rest) in wti:
        yield (sn, tn), which(list(reversed(rest)))


class _FormalStateMachine:

    def __init__(self, transitions, nodes, ffsa_key, wti):
        self.transitions = transitions
        self.nodes = nodes
        self.FFSA_key = ffsa_key
        self.where_to_insert = wti
        self._these_one_indexes = None

    def to_state_machine(self):
        return _StateMachine(self)._init_state_machine()

    def to_graph_viz_inner_lines_simplified(self):
        def gv_key_via_key(k):
            if not re.match(r'[a-z][_a-z0-9]+\Z', k):
                xx(f"oops: {k!r}")
            return k
        import re

        for t in self.transitions:
            s = t.condition_name
            if '"' in s:
                xx(f"have fun: {s!r}")
            label_rhs = ''.join(('"', s, '"'))
            lhs = gv_key_via_key(t.left_node_name)
            rhs = gv_key_via_key(t.right_node_name)
            yield ''.join((lhs, '->', rhs, '[label=', label_rhs, ']\n'))

    def THIS_ONE_INDEX_FOR(self, node_name):
        if (dct := self._these_one_indexes) is None:
            self._these_one_indexes = (dct := {})
        if (node_dct := dct.get(node_name)) is None:
            node_dct = {k: v for k, v in self._wahoo(node_name)}
            dct[node_name] = node_dct
        return node_dct

    def _wahoo(self, node_name):
        transes = self.transitions
        for i in self.nodes[node_name].transitions_from_here:
            yield transes[i].condition_name, i

    HOLY_SMOKES_MERGE_FFSAs = _holy_smokes_merge_FFSAs


class _MutableNode:
    def __init__(self, name):
        self.node_name = name
        self.transitions_from_here = []
        self.transitions_to_here = []


def _transition_via_tuple(offset, tup):
    stack = list(reversed(tup))
    left, cond, right = stack.pop(), stack.pop(), stack.pop()
    afn, afa = None, None
    if len(stack):
        k = stack.pop()
        if 'call' != k:  # (for now this is the only option supported)
            xx(f"unrecognized option for a transition: {k!r}")
        afn = stack.pop()
        afa = tuple(reversed(stack))
    kw = {}
    kw['action_function_name'] = afn
    kw['action_arguments'] = afa
    kw['transition_offset'] = offset
    kw.update(left_node_name=left, condition_name=cond, right_node_name=right)
    return _Transition(**kw)


_Transition = _nt('_Transition', (
    'transition_offset',
    'left_node_name', 'condition_name', 'right_node_name',
    'action_function_name', 'action_arguments'))


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #history-B.4: got rid of cache facilities in *this* module
# #born
