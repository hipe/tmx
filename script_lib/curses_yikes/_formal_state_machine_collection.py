from collections import namedtuple as _nt


class Formal_FSA_Collection_:

    def __init__(self):
        assert not _mutex_for_singleton
        _mutex_for_singleton.append(None)

        self._module_cache_via_module_name = {}

    def WRAP_CLASS_REMARKABLY_HACKY_EXPERIMENT(self, klass, module):
        mc = self._cache_for_module_via_module(module)
        return mc.wrap_class_hackily(klass)

    def _cache_for_module_via_module(self, module):

        # It seems unlikely that participating class names will be repeated
        # across various modules that contain them so we could just munge
        # it maybe but ..

        mname = module.__name__
        dct = self._module_cache_via_module_name
        if (mc := dct.get(mname)) is None:
            dct[mname] = (mc := _CacheForModule(module))
        return mc


class _CacheForModule:

    def __init__(self, module):
        self._module = module
        self._CACHE = {}

    def wrap_class_hackily(self, klass):
        assert klass.is_interactable

        k = klass.__name__
        if (wc := self._CACHE.get(k)) is None:
            self._CACHE[k] = (wc := _wrapped_class_via(klass, self._module))

        return wc


def _wrapped_class_via(klass, module):
    fname = _expected_FFSA_function_name_via_abstract_area_function_name(klass.__name__)  # noqa: E501
    ffsa_func = getattr(module, fname)
    ffsa = _formal_state_machine_via_definition(ffsa_func())

    def use_klass(*abstract_area_args):
        aa = klass(*abstract_area_args)
        return _WrappedAbstractArea(ffsa, aa)

    return use_klass


def _delegate(orig_f):
    def use_f(selv):
        return getattr(selv._AA, attr)
    attr = orig_f.__name__
    return property(use_f)


class _WrappedAbstractArea:  # we don't love this but..

    def __init__(self, ffsa, aa):
        self._FFSA, self._AA = ffsa, aa

    def concretize_via_memo_and(self, *many, **kw):
        ca = self._AA.concretize_via_memo_and(*many, **kw)
        return self._add_state_machine(ca)

    def concretize_via_available_height_and_width(self, h, w, listener=None):
        ca = self._AA.concretize_via_available_height_and_width(h, w, listener)
        return self._add_state_machine(ca)

    def _add_state_machine(self, ca):
        state = self._FFSA.to_state_machine()
        ca.state = state  # #EXPERIMENTAL
        return ca

    def write_to_memo(self, memo):
        return self._AA.write_to_memo(memo)

    @_delegate
    def minimum_height_via_width(self):
        pass

    @_delegate
    def minimum_width(self):
        pass

    @_delegate
    def two_pass_run_behavior(self):
        pass

    @_delegate
    def can_fill_vertically(self):
        pass

    @_delegate
    def is_interactable(self):
        pass


class _StateMachine:

    def __init__(self, transitions, nodes):
        self._transitions, self._nodes = transitions, nodes

    def _init_state_machine(self):
        self._nodes['initial']  # validate the existence of the node
        self._state_name = 'initial'
        return self

    def MAKE_A_COPY(self):
        otr = self.__class__(self._transitions, self._nodes)
        otr._state_name = self._state_name
        return otr

    def move_to_state_via_transition_name(self, tn):
        trans = None
        for t in self._each_transition():
            if tn == t.condition_name:
                trans = t
                break

        if not trans:
            xx(f"whoopsie, can't trans from {self._state_name!r} OVER {tn!r}")

        self._accept_transition(trans)

    def move_to_state_via_state_name(self, nn):
        trans = None
        for t in self._each_transition():
            if nn == t.right_node_name:
                trans = t
                break

        if not trans:
            xx(f"whoopsie, can't trans from {self._state_name!r} to {nn!r}")

        self._accept_transition(trans)

    def _each_transition(self):
        node = self._nodes[self._state_name]
        transs = self._transitions
        for i in node.transitions_from_here:  # could have made it dict oh well
            yield transs[i]

    def _accept_transition(self, trans):
        afn = trans.action_function_name
        if afn:
            xx('literally the best thing')

        self._state_name = trans.right_node_name  # should be no need to valid

    @property
    def state_name(self):  # no NOT make this plain old writable
        return self._state_name


def _formal_state_machine_via_definition(defs):
    transitions = _transitions_via_definition(defs)
    return _formal_state_machine_via_transitions(tuple(transitions))


def _transitions_via_definition(defs):
    count = 0
    for tup in defs:
        yield _transition_via_tuple(count, tup)
        count += 1


def _formal_state_machine_via_transitions(transitions):

    def autovivify_node(name):
        if (node := nodes.get(name)) is None:
            nodes[name] = (node := _MutableNode(name))
        return node

    nodes = {}

    for t in transitions:
        i = t.transition_offset
        autovivify_node(t.left_node_name).transitions_from_here.append(i)
        autovivify_node(t.right_node_name).transitions_to_here.append(i)

    return _FormalStateMachine(transitions, nodes)


class _FormalStateMachine:
    def __init__(self, transitions, nodes):
        self._transitions = transitions
        self._nodes = nodes

    def to_state_machine(self):
        return _StateMachine(self._transitions, self._nodes)._init_state_machine()  # noqa: E501


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


def _expected_FFSA_function_name_via_abstract_area_function_name(fname):
    import re
    md = re.match(r'abstract_(.+)_via_.+\Z', fname)
    if not md:
        xx(f"whoopsie: {fname!r}")
    component_name, = md.groups()
    return '_'.join((component_name, 'state_machine'))


# Just for sanity for now, assert there's only one ever in the whole runtime.
# Doing it this way is bad because we're suppposed to unit test the class
_mutex_for_singleton = []


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
