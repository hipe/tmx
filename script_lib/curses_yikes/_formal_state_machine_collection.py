from collections import namedtuple as _nt


def produce_formal_FSA_via_definition_function_NOT_USED_(
        house_module_string, defnf):

    return _cache.dereference(house_module_string, defnf)


# {ffsa|FFSA} = formal finite state automaton (as opposed to the instance)


def _build_cache():

    def dereference(house_module_string, defnf):
        fname = defnf.__name__
        ffsa_key = house_module_string, fname

        if (ffsa := cache.get(ffsa_key)) is None:
            ffsa = _build_FFSA(ffsa_key, defnf())
            cache[ffsa_key] = ffsa

        return ffsa

    kw = {k: v for k, v in locals().items()}
    cache = {}
    return _nt('_Cache', kw.keys())(**kw)


_cache = _build_cache()


def build_formal_FSA_via_definition_function_(house_module_string, defnf):
    ffname = defnf.__name__
    ffsa_key = house_module_string, ffname
    return _build_FFSA(ffsa_key, defnf())


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


def _build_FFSA(ffsa_key, defs):
    transitions = tuple(_transitions_via_definition(defs))
    return _formal_state_machine_via_transitions(transitions, ffsa_key)


def _transitions_via_definition(defs):
    count = 0
    for tup in defs:
        yield _transition_via_tuple(count, tup)
        count += 1


def _formal_state_machine_via_transitions(transitions, ffsa_key):

    def autovivify_node(name):
        if (node := nodes.get(name)) is None:
            nodes[name] = (node := _MutableNode(name))
        return node

    nodes = {}

    for t in transitions:
        i = t.transition_offset
        autovivify_node(t.left_node_name).transitions_from_here.append(i)
        autovivify_node(t.right_node_name).transitions_to_here.append(i)

    return _FormalStateMachine(transitions, nodes, ffsa_key)


class _FormalStateMachine:
    def __init__(self, transitions, nodes, ffsa_key):
        self.transitions = transitions
        self.nodes = nodes
        self.FFSA_key = ffsa_key

    def to_state_machine(self):
        return _StateMachine(self)._init_state_machine()


class _MutableNode:
    def __init__(self, name):
        self.node_name = name
        self.transitions_from_here = []
        self.transitions_to_here = []


def _transition_via_tuple(offset, tup):
    stack = list(reversed(tup))
    left, cond, right = stack.pop(), stack.pop(), stack.pop()
    kw = {'call': None}
    while len(stack):
        k = stack.pop()
        kw[k]  # validate name
        kw[k] = stack.pop()
    kw['action_function_name'] = kw.pop('call')  # meh
    kw['transition_offset'] = offset
    kw.update(left_node_name=left, condition_name=cond, right_node_name=right)
    return _Transition(**kw)


_Transition = _nt('_Transition', (
    'transition_offset',
    'left_node_name', 'condition_name', 'right_node_name',
    'action_function_name'))


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
