def _parse(all_lines, parse_actionser, sm, listener):

    ps = _ParseState(listener)
    ps._be_in_state('start', sm)
    actions = _normal_actions_via(ps, parse_actionser, sm)

    def execute():
        ok = True  # if no lines, whine using state machine, not by us
        for line in all_lines:
            ps._receive_line(line)
            ok, x = receive_next_token(line)
            if not ok:
                break  # NOTE be sure all break coincides with a not OK
            if x is not None:  # see #here1
                yield x
        if not ok:
            return
        ok, x = receive_end_of_stream()
        if ok:
            if x is not None:  # see #here1
                yield x

    # :#here1: A) it's sad that we can't DRY this. B) when x is None it is the
    # callback's way of saying "everything's OK but i have nothign to yield"

    def receive_end_of_stream():
        ps._receive_end_of_stream()
        o = ps.state_body
        if o.can_match_end_of_stream:
            return call_any_action(o.transition_for_end_of_stream)
        else:
            return when_transition_not_found()

    def receive_next_token(line):
        ok = False
        for trans in ps.state_body.available_transitions_for_during_stream:
            ok = trans.matcher(line)
            if ok:
                break
        if not ok:
            return when_transition_not_found()

        two = call_any_action(trans)

        trans_to = trans.transition_to
        if two[0] and trans_to is not None and trans_to != ps.state_name:
            ps._be_in_state(trans_to, sm)

        return two

    def call_any_action(trans):
        call = trans.call
        if call is None:
            return _nothing
        else:
            return actions[call]()

    def when_transition_not_found():
        _when_transition_not_found(ps, sm)
        return _stop

    return execute()


def _normal_actions_via(ps, parse_actionser, sm):
    # so you don't have to call getattr as often
    actions = {}
    f = parse_actionser(ps)
    for name in sm.callback_names:
        actions[name] = f(name)
    return actions


class _ParseState:

    def __init__(self, listener):

        def enhanced_listener(*a):

            # our listener peaks at every emission that comes through it, and
            # for those emissions that look a certain way, it adds to their
            # components more context about the parse state, like line number.

            if 'error' == a[0] and 'structure' == a[1] and 'input_error' == a[2]:  # noqa: E501
                def use_struct():
                    dct = a[-1]()  # mutating this? yikes
                    dct['did_reach_end_of_stream'] = self._did_reach_EOS
                    lineno = self.lineno
                    dct['lineno'] = lineno
                    if lineno:
                        # (empty files stay on line number 0 and have no line)
                        dct['line'] = self.line
                    return dct
                listener(*a[0:-1], use_struct)
            else:
                listener(*a)
        self.listener = enhanced_listener

        self._has_line_callback = False
        self._did_reach_EOS = False
        self.lineno = 0

    def replace_line_handler(self, f):
        None if self._has_line_callback else None
        f0 = self._on_line
        self._on_line = f
        return f0

    def on_line_do_this(self, f):
        sanity() if self._has_line_callback else None
        self._has_line_callback = True
        self._on_line = f

    def _receive_line(self, line):
        self.lineno += 1
        self.line = line
        if self._has_line_callback:
            self._on_line()

    def _be_in_state(self, state_name, sm):
        self.state_body = sm.state_bodies[state_name]
        self.state_name = state_name

    def _receive_end_of_stream(self):
        self._did_reach_EOS = True


class StateMachine:

    def __init__(self, define_state_transitions=None):

        if define_state_transitions is None:  # for __init_duplicate
            return

        def peek_transition(f, **kwargs):
            trans = _Transition(f, **kwargs)
            call = trans.call
            if call is not None:
                calls[call] = True
            return trans

        calls = {}
        _dct = define_state_transitions(peek_transition)
        self.callback_names = tuple(calls.keys())
        self.__receive_these(**_dct)

    def __receive_these(
            self,
            transitions_via_state_name,
            ):

        self.state_bodies = {k: _StateBody(v) for (k, v) in transitions_via_state_name.items()}  # noqa: E501

    def modified(self, modify_states):
        dct = {k: v for (k, v) in self.state_bodies.items()}
        for state_name, f in modify_states:
            dct[state_name] = f(dct[state_name])

        otr = self.__class__()
        otr.__init_duplicate(self.callback_names, dct)  # ..
        return otr

    def __init_duplicate(self, tup, dct):
        self.callback_names = tup
        self.state_bodies = dct

    def parse(self, all_lines, parse_actionser, listener):
        return _parse(all_lines, parse_actionser, self, listener)


class _StateBody:

    def __init__(self, transitions):
        """super hacky - the way a transition signifies that it can match
        on the end of the input stream is currently by having `None` as the
        matcher function..

        internally we need to give this kind of transiton special handling.
        externally it is definitionally different than the others because
        it cannot be defined with a matcher function (which takes a line).
        """

        last_transition = transitions[-1]

        if last_transition.matcher is None:
            use_transes = tuple(transitions[0:-1])
            has = True
            self.transition_for_end_of_stream = last_transition
        else:
            use_transes = transitions
            has = False

        self.available_transitions_for_during_stream = use_transes
        self.can_match_end_of_stream = has

    def modified(self, append_transitions):
        sanity() if self.can_match_end_of_stream else None
        _ = (*self.available_transitions_for_during_stream,
             *append_transitions)
        return self.__class__(_)


class _Transition:

    def __init__(self, matcher, call=None, transition_to=None):
        self.matcher = matcher
        self.call = call
        self.transition_to = transition_to


# -- expression (EN)

def _when_transition_not_found(ps, sm):

    def struct():

        # (this is ugly here but so far not needed elsewhere)
        o = ps.state_body
        use_transes = o.available_transitions_for_during_stream
        if o.can_match_end_of_stream:
            use_transes = (*use_transes, o.transition_for_end_of_stream)

        s_a = tuple(trans.matcher.noun_phrase for trans in use_transes)

        return {
                'expecting_any_of': s_a,
                # do not add 'position' as an element at all -
                # we don't know here whether or not we even have a line (token)
                }

    ps.listener('error', 'structure', 'input_error', struct)


def oxford_or_USE_ME(these):  # #todo this became a coverage island at commit
    length = len(these)
    if 0 == length:
        return 'nothing'
    elif 1 == length:
        return these[0]
    else:
        *head, penult, ult = these
        tail = f'{penult} or {ult}'
        if len(head):
            return ', '.join((*head, tail))
        else:
            return tail


def sanity():
    raise Exception('sanity')


_not_ok = False
_stop = (_not_ok, None)
_ok = True
_nothing = (_ok, None)

# #history-A.1: introduced experimental dup-and-mutate behavior
# #born.
