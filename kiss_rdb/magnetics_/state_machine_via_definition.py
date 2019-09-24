import re


def _items_via_parse_state_and_all_lines(ps, all_lines):
    """main parse loop.

    called "items" because it's up to the actions what shape of thing.
    """

    ok = True  # if no lines is not ok, that is for sm to effect, not us.

    for line in all_lines:
        ok, x = ps._receive_next_line(line)
        if not ok:
            break
        if x is not None:  # see #here1
            yield x

    if not ok:
        return

    ok, x = ps._receive_end_of_stream()

    if ok and x is not None:  # #here1
        yield x

    # :#here1: A) when x is None it's the action's way of saying "everything's
    # OK but nothing to yield." B) it's sad we can't DRY these two.


class _ParseState:

    def __init__(self, listener, actions_class, state_machine):

        # -- these before next
        self.listener = _build_enhanced_listener(listener, self)
        self._sm = state_machine
        self._state_via_state_name = self._sm._state_via_state_name  # opt meh
        # --

        # -- after above. A) validates existence. B) slight optimization
        o = actions_class(self)
        _dct = {k: getattr(o, k) for k in self._sm._distinct_transition_names}
        self.RECEIVE_ACTION_VIA_TRANSITION_NAME(_dct.__getitem__)
        # --

        self._be_in_state(self._sm.name_of_initial_state)

        self.current_matchdata = None
        self.lineno = 0
        self._did_reach_EOS = False

    def items_via_all_lines_(self, all_lines):  # main parse method
        return _items_via_parse_state_and_all_lines(self, all_lines)

    # == module-internal parsing API

    def _receive_next_line(self, line):  # a.k.a. "receive next token"
        self.lineno += 1
        self.line = line

        for trans in self.current_state.ATTACHED_TRANSITIONS:
            three = trans.MATCH(line)
            if three is not None:
                break

        if three is None:
            return self._when_transition_not_found()

        mixed, trans_name, any_dest_name = three

        # currently we don't want the actions to ever change state: that would
        # mean that in effect we are letting the injection change the grammar.
        # that's out of scope for what we want the injections to be able to do.
        # so change state eagerly now ..

        if any_dest_name is not None:
            self._be_in_state(any_dest_name)

        # woot call the *some* action

        return self._always_call_some_action(mixed, trans_name)

    def _receive_end_of_stream(self):
        self._did_reach_EOS = True
        o = self.current_state

        if not o.can_end:
            return self._when_transition_not_found()

        self._be_in_state(self._sm.name_of_goal_state)  # prob no reas but meh

        return self._always_call_some_action(
                mixed=None,  # there is never matchdata for end of stream
                trans_name=o.TRANSITION_NAME_FOR_END)

    def _always_call_some_action(self, mixed, trans_name):
        self.current_matchdata = mixed
        _action = self._action_via_transition_name(trans_name)
        two = _action()
        if two is None:
            # None has these semantics, for more elegant & future-proof actions
            return _nothing
        return two

    def _when_transition_not_found(self):
        _when_transition_not_found(self, self._sm)
        return _stop

    def RECEIVE_ACTION_VIA_TRANSITION_NAME(self, f):
        self._action_via_transition_name = f

    def be_in_state_(self, s):
        self._be_in_state(s)

    def _be_in_state(self, state_name):
        self.current_state = self._state_via_state_name[state_name]


def _build_enhanced_listener(listener, ps):
    def enhanced_listener(*a):

        # our listener peaks at every emission that comes through it, and
        # for those emissions that look a certain way, it adds to their
        # components more context about the parse state, like line number.

        if 'error' == a[0] and 'structure' == a[1] and 'input_error' == a[2]:  # noqa: E501
            def use_struct():
                dct = a[-1]()  # mutating this? yikes
                dct['did_reach_end_of_stream'] = ps._did_reach_EOS
                lineno = ps.lineno
                dct['lineno'] = lineno
                if lineno:
                    # (empty files stay on line number 0 and have no line)
                    dct['line'] = ps.line
                return dct
            listener(*a[0:-1], use_struct)
        else:
            listener(*a)
    return enhanced_listener


class StateMachine:  # #[#008.2] a state machine
    """DISCUSSION

    the state machine is an immutable.

    (if you're looking for the mutable thing, you probably want "parse state".)

    a state machine has many states and a state has many transitions and
    a (awkwardly) a single transition has *many* possible destination states
    (a weirdness to accomodate "dispatcher" "transitions". this thus makes
    our use of the term "transition" somewhat of an abuse in code, but we
    try not to let this abuse-of-terminology bleed into our schematics etc).

    :#here2"""

    def __init__(self, define_state_transitions):
        """DISCUSSION: very experimental interface:

        state machines are created with one defniition function
        that gets passed a collecton of functions..
        """

        # this is what the user gets passed to define their SM with

        class functions:  # #as-namespace
            transition_via_definition = _unattached_transition_via

        # pass it to the user

        _user_kwargs = define_state_transitions(functions)

        # now build self

        self.__init_self(**_user_kwargs)

    def __init_self(
            self,
            name_of_initial_state,
            transitions_via_state_name,
            name_of_goal_state,
            ):

        state_via_state_name = {}
        action_function_names = []

        for k, transes in transitions_via_state_name.items():
            state = _State(k, transes)
            for dtn in state.TO_STREAM_OF_DISTINCT_TRANSITION_NAMES():
                action_function_names.append(dtn)
            state_via_state_name[k] = state

        self._state_via_state_name = state_via_state_name

        self._distinct_transition_names = tuple(action_function_names)

        self.name_of_initial_state = name_of_initial_state
        self.name_of_goal_state = name_of_goal_state

    def parse(self, all_lines, actions_class, listener):
        _ps = self.build_parse_state(listener, actions_class)
        return _ps.items_via_all_lines_(all_lines)

    def build_parse_state(self, listener, actions_class):
        return _ParseState(listener, actions_class, self)


class _State:
    """DISCUSSION per #here2, the state has many transitions. in code,

    we distinguish between "attached" transitions and "unattached" transitions.

    the "unattached" transition holds matching mechanics and the name of a
    destination state; something that in practice we often want to re-use
    across several formal transitions.

    then the "attached" transition models the actual formal transition,
    including data derived from the association between the source state
    and the re-used component (more below).
    """

    def __init__(self, state_name, transitions):

        # --

        normal_head = _normalize(state_name)

        def name_for(normal_tail):
            return f'{ normal_head }__to__{ normal_tail }'

        attached_transes = []
        receive = attached_transes.append

        def attach(trans):
            if trans.TRANSITIONS_TO_SELF:
                _ = name_for(normal_head)  # foo__to__foo
                receive(_MonoAttached(_, trans))

            elif trans.HAS_MANY:
                _ = {k: name_for(_normalize(k)) for k in trans.THESE.keys()}
                receive(_PolyAttached(_, trans))
            else:
                _ = name_for(trans.DESTINATION_NORMAL_NAME)
                receive(_MonoAttached(_, trans))

        # --

        num = len(transitions)
        if num:

            last = num - 1

            # for ANY all but the any last, one
            for i in range(0, last):
                trans = transitions[i]
                assert(not trans.DOES_TEST_FOR_EOS)
                attach(trans)

            # for the last one
            trans = transitions[last]
            if trans.DOES_TEST_FOR_EOS:
                self.can_end = True
                self.TRANSITION_NAME_FOR_END = name_for(trans.DESTINATION_NORMAL_NAME)  # noqa: E501
            else:
                attach(trans)
                self.can_end = False
        else:
            self.can_end = False

        self.ATTACHED_TRANSITIONS = tuple(attached_transes)  # might be 0 len

    def TO_POSSIBLE_NOUN_PHRASE_STREAM(self):

        # (this is ugly here but so far not needed elsewhere)

        for at in self.ATTACHED_TRANSITIONS:
            yield at.UNATTACHED_TRANSITION.TO_NOUN_PHRASE()  # ..

        if self.can_end:
            yield 'end of input'

    def TO_STREAM_OF_DISTINCT_TRANSITION_NAMES(self):

        for at in self.ATTACHED_TRANSITIONS:
            for s in at.TO_STREAM_OF_DISTINCT_TRANSITION_NAMES_AS_AT():
                yield s

        if self.can_end:
            yield self.TRANSITION_NAME_FOR_END


class _PolyAttached:

    def __init__(self, dct, una):
        self.DICT = dct
        self.UNATTACHED_TRANSITION = una

    def MATCH(self, line):
        two = self.UNATTACHED_TRANSITION.MATCH_AS_TESTER(line)
        if two is None:
            return
        mixed, dest_name = two
        _trans_name = self.DICT[dest_name]
        return (mixed, _trans_name, dest_name)

    def TO_STREAM_OF_DISTINCT_TRANSITION_NAMES_AS_AT(self):
        return self.DICT.values()


class _MonoAttached:

    def __init__(self, trans_name, una):
        self.DISTINCT_TRANSITION_NAME = trans_name
        self.UNATTACHED_TRANSITION = una

    def MATCH(self, line):
        two = self.UNATTACHED_TRANSITION.MATCH_AS_TESTER(line)
        if two is None:
            return
        mixed, any_dest_name = two
        return (mixed, self.DISTINCT_TRANSITION_NAME, any_dest_name)

    def TO_STREAM_OF_DISTINCT_TRANSITION_NAMES_AS_AT(self):
        yield self.DISTINCT_TRANSITION_NAME


def _unattached_transition_via(
        tester=None,
        transition_to=None,
        transition_tos=None,
        dispatcher=None,
        tests_for_EOS=False,
        noun_phrase=None,
        ):

    signature = (
            tester is not None,
            dispatcher is not None,
            tests_for_EOS,
            )

    # if tester
    if (True, False, False) == signature:
        assert(not transition_tos)
        return _TesterUnattachedTransition(transition_to, tester)

    # if dispatcher
    if (False, True, False) == signature:
        assert(noun_phrase)
        return _DispatcherUnattachedTransition(
                transition_tos, dispatcher, noun_phrase)

    # if EOS
    elif (False, False, True) == signature:  # EOS
        assert(not transition_tos)
        return _EnderUnattachedTransition(transition_to)

    _ = ('yes' if yes else 'no' for yes in signature)
    _ = ', '.join(_)
    _ = (
        f'(tester, dipatcher, tests_for_EOS) are mutually exclusive. '
        f'had ({_}).')
    raise ValueError(_)


class _DispatcherUnattachedTransition:

    def __init__(self, transition_tos, dispatcher, noun_phrase):
        self.THESE = {k: None for k in transition_tos}
        self.DISPATCHER = dispatcher
        self._noun_phrase = noun_phrase

    def MATCH_AS_TESTER(self, line):
        two = self.DISPATCHER(line)
        if two is None:
            return
        state_name, mixed = two
        self.THESE[state_name]  # validate existence
        return mixed, state_name

    def TO_NOUN_PHRASE(self):
        return self._noun_phrase

    HAS_MANY = True
    TRANSITIONS_TO_SELF = False
    DOES_TEST_FOR_EOS = False


class _TesterUnattachedTransition:

    def __init__(self, transition_to, tester):

        if transition_to is None:
            self.TRANSITIONS_TO_SELF = True
        else:
            self.DESTINATION_NORMAL_NAME = _normalize(transition_to)
            self.DESTINATION_NAME = transition_to
            self.HAS_MANY = False
            self.TRANSITIONS_TO_SELF = False

        self.TESTER = tester

    def MATCH_AS_TESTER(self, line):

        mixed = self.TESTER(line)
        if mixed is None or mixed is False:  # hypothetically 0 could be true
            return

        if self.TRANSITIONS_TO_SELF:
            use = None
        else:
            use = self.DESTINATION_NAME

        return (mixed, use)

    def TO_NOUN_PHRASE(self):  # BIG HACK
        _function_name = self.TESTER.__name__
        _base = _un_normalize(_function_name)
        return f'{_base} line'  # so crazy

    DOES_TEST_FOR_EOS = False


class _EnderUnattachedTransition:

    def __init__(self, transition_to):
        self.DESTINATION_NORMAL_NAME = _normalize(transition_to)

    TRANSITIONS_TO_SELF = False  # ..
    DOES_TEST_FOR_EOS = True


# -- expression (EN)

def _when_transition_not_found(ps, sm):

    def struct():

        s_a = tuple(ps.current_state.TO_POSSIBLE_NOUN_PHRASE_STREAM())

        return {
                'expecting_any_of': s_a,
                # do not add 'position' as an element at all -
                # we don't know here whether or not we even have a line (token)
                }

    ps.listener('error', 'structure', 'input_error', struct)


_dash_or_space = re.compile('[- ]')  # intentionally not robust for now


def _un_normalize(func_name):  # BIG HACK
    return func_name.replace('_', ' ')


def _normalize(name):
    return _dash_or_space.sub('_', name)


_not_ok = False
_stop = (_not_ok, None)
_ok = True
_nothing = (_ok, None)

# #history-A.3: massive overhaul: inject actions class (for mutli-line)
# #tombstone-A.2: archive ability to mutate state machines (no longer needed)
# #history-A.1: introduced experimental dup-and-mutate behavior
# #born.
