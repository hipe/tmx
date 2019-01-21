def items_via_toml_path(toml_path):

    raise Exception('integrate me with below (easy)')  # #todo


def _coarse_items_via_all_lines(all_lines, listener):

    state_name = 'start'
    allowed_state_transitions = _state_transitions[state_name]
    lineno = 0

    for line in all_lines:
        lineno += 1
        did_find = False
        for transition_tuple in allowed_state_transitions:
            _yes = transition_tuple[0](line)
            if _yes:
                did_find = True
                break

        if not did_find:
            _when_transition_not_found(lineno, line, state_name, listener)
            state_name = 'end'
            break

        action_name = transition_tuple[1]
        next_state_name = transition_tuple[2]

        if action_name is not None:
            cover_me()

        if next_state_name != state_name:
            allowed_state_transitions = _state_transitions[next_state_name]
            state_name = next_state_name

    if state_name != 'end':
        # (reminder: we set the state to "end" in some error states above!)
        _when_did_not_reach_end(lineno, state_name, listener)


def _when_transition_not_found(lineno, line, curr_state_name, listener):

    def msg():
        f = _nonterminal_symbol_noun_phrase_via_matcher_function.__getitem__
        _ = _state_transitions[curr_state_name]
        _ = tuple(f(tup[0]) for tup in _)
        _head = f'expecting {_oxford_or(_)}'
        return _contextualize_error_message(_head, lineno, line)

    listener('error', 'expression', 'input_error', msg)


def _when_did_not_reach_end(lineno, current_state_name, listener):

    if 'start' == current_state_name:
        if 0 == lineno:
            def msg():
                yield 'no lines in input'
        else:
            def msg():
                yield 'file has no sections (so no entities)'
    else:
        cover_me()

        def msg():
            yield f'at end of input, was in "{current_state_name}" state.'

    listener('error', 'expression', 'input_error', msg)


def _contextualize_error_message(head, lineno, line):

    _line = f'{head} at line {lineno}: {repr(line)}'
    return (_line,)


# (below is derived directly from the [#863] state transition graph)

# tests (actually very local)

def blank(line):
    return '\n' == line


def comment(line):
    return '#' == line[0]  # per #todo


def section(line):
    return '[' == line[0]  # per #todo


def key_value(line):
    cover_me()


def end_of_input(line):
    cover_me()
    return line is None


_nonterminal_symbol_noun_phrase_via_matcher_function = {  # ick/meh
        blank: 'blank line',
        comment: 'comment line',
        section: 'section line',
        key_value: 'key-value line',
        end_of_input: 'end of input',
        }


def _the_worst(func):
    if blank == func:
        return


_state_transitions = {
        'start': (
            (blank, None, 'start'),
            (comment, None, 'start'),
            (section, 'xx', 'inside entity'),
            ),
        'inside entity': (
            (key_value, 'xx', 'yy'),
            (blank, None, 'xx'),
            (comment, None, 'xx'),
            (end_of_input, 'xx', 'yy'),
            ),
        'done': (
            )
        }

# --


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
