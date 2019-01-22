def parse(all_lines, parse_actionser, sm, listener):

    ps = _ParseState(listener)
    actions = _normal_actions_via(ps, parse_actionser, sm)

    # --

    available_transitions = sm.transitions_via_state_name(ps.state_name)

    for line in all_lines:

        ps._receive_line(line)
        did_match = False
        for trans in available_transitions:
            did_match = trans.matcher(line)
            if did_match:
                break

        if not did_match:
            _when_transition_not_found(ps, sm)
            ps._be_in_state('end')
            break

        call = trans.call
        trans_to = trans.transition_to

        if call is not None:
            ok, x = actions[call]()
            if ok:
                cover_me()
            else:
                ps._be_in_state('end')
                break

        if trans_to is not None and trans_to != ps.state_name:
            available_transitions = sm.transitions_via_state_name(trans_to)
            ps._be_in_state(trans_to)

    if 'end' != ps.state_name:
        # (reminder: we set the state to "end" in some error states above!)
        _when_did_not_reach_end(ps)


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
            if 'error' == a[0] and 'structure' == a[1] and 'input_error' == a[2]:  # noqa: E501
                def use_struct():
                    dct = a[-1]()  # mutating this? yikes
                    dct['lineno'] = self.lineno
                    dct['line'] = self.line
                    return dct
                listener(*a[0:-1], use_struct)
            else:
                listener(*a)
        self.listener = enhanced_listener

        self._on_line = None
        self.lineno = 0
        self.state_name = 'start'

    def _receive_line(self, line):
        self.lineno += 1
        self.line = line
        if self._on_line is not None:
            self._on_line()

    def _be_in_state(self, state_name):
        self.state_name = state_name


class StateMachine:

    def __init__(self, define_state_transitions):

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
            nonterminal_symbol_noun_phrase_via_matcher_function,
            ):
        self._transitions_via_state_name = transitions_via_state_name
        self.nonterminal_symbol_noun_phrase_via_matcher_function = nonterminal_symbol_noun_phrase_via_matcher_function  # noqa: E501

    def transitions_via_state_name(self, state_name):
        return self._transitions_via_state_name[state_name]


class _Transition:

    def __init__(self, matcher, call=None, transition_to=None):
        self.matcher = matcher
        self.call = call
        self.transition_to = transition_to


# -- expression (EN)

def _when_transition_not_found(ps, sm):

    s_via_f = sm.nonterminal_symbol_noun_phrase_via_matcher_function
    transes = sm.transitions_via_state_name(ps.state_name)

    def msg():
        _ = tuple(s_via_f(trans.matcher) for trans in transes)
        _ = f'expecting {_oxford_or(_)}'
        return _contextualize_error_message(_, ps)

    ps.listener('error', 'expression', 'input_error', msg)


def _when_did_not_reach_end(ps):

    if 'start' == ps.state_name:
        if 0 == ps.lineno:
            def msg():
                yield 'no lines in input'
        else:
            def msg():
                yield 'file has no sections (so no entities)'
    else:
        cover_me()

        def msg():
            yield f'at end of input, was in "{ps.state_name}" state.'

    ps.listener('error', 'expression', 'input_error', msg)


def _contextualize_error_message(head, ps):

    _line = f'{head} at line {ps.lineno}: {repr(ps.line)}'
    return (_line,)


def _oxford_or(these):
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


def cover_me():
    raise(Exception('cover me'))

# #born.
