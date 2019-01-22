from kiss_rdb.magnetics_ import (
        string_scanner_via_definition as scn_lib,
        state_machine_via_definition as sm_lib,
        )


def items_via_toml_path(toml_path):

    raise Exception('integrate me with below (easy)')  # #todo


def _coarse_items_via_all_lines(all_lines, listener):  # #testpoint

    def actionser(ps):  # might push this in to lib
        def f(name):
            return getattr(pa, name)
        pa = _MyParseActions(ps)
        return f

    return sm_lib.parse(all_lines, actionser, _state_machine, listener)


class _MyParseActions:

    def __init__(self, parse_state):
        self._ps = parse_state

    def on_section_start(self):
        o = self._ps
        tup = _strict_hacky_section_line_via_line(o.line, o.listener)
        if tup is None:
            return _stop
        else:
            cover_me()

    def at_end_of_input(self):
        cover_me()


def _strict_hacky_section_line_via_line(line, listener):

    nc = _name_components_via_line(line, listener)
    if nc is None:
        return

    if 'item' != nc[0]:
        return _input_error(listener, expecting='keyword "item"', position=1)

    length = len(nc)
    if 1 == length:
        _ = 1 + len(nc[0])  # eew
        return _input_error(listener, expecting='dot', position=_)

    identifier = nc[1]
    if 2 == length:
        _ = 1 + len(nc[0]) + 1 + len(identifier)  # the worst
        return _input_error(listener, expecting='dot', position=_)

    keyword = nc[2]
    if 'attributes' == keyword:
        which = 'attributes'
    elif 'meta' == keyword:
        which = 'meta'
    else:
        _ = 1 + len(nc[0]) + 1 + len(identifier) + 1  # SO BAD
        __ = 'keyword "attributes" or "meta"'
        return _input_error(listener, expecting=__, position=_)

    if 3 < length:
        _ = 1 + len(nc[0]) + 1 + len(identifier) + 1 + len(which)  # NOOOOOO
        return _input_error(listener, expecting="']'", position=_)

    return (identifier, which)


def _name_components_via_line(line, listener):
    """
    parses toml "section" lines crudely.

    given a line like this:
        "[foo.bar.baz123]\n"
    result in an array like this:
        ["foo", "bar", "baz123"]
    """

    scn = scn_lib.Scanner(line, listener)

    if not scn.skip_required(_open_brace):
        return

    name_components = []  # necessarily separated by dots. no fancy whitespace

    keep_parsing = True
    while keep_parsing:
        s = scn.scan_required(_loosey_goosey_identifier)
        if s is None:
            return
        name_components.append(s)

        # whether or not there's a dot determines if we stay in the loop

        keep_parsing = scn.skip(_dot)
        pass  # hello.

    if not scn.skip_required(_close_brace_and_end_of_line):
        return

    return name_components


o = scn_lib.pattern_via_description_and_regex_string
_open_brace = o('open brace ("[")', r'\[')
_loosey_goosey_identifier = o('identifier ([a-zA-Z0-9]+)', r'[a-zA-Z0-9]+')
_dot = o('dot (".")', r'\.')
_close_brace_and_end_of_line = o('close brace and end of line', r'\]\n$')
del(o)


def _input_error(listener, **kwargs):
    listener('error', 'structure', 'input_error', lambda: kwargs)


# -- below is derived directly from the [#863] state transition graph

def _define_state_machine(o):  # interface here is VERY experimental!

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

    _noun_phrase_via_matcher_function = {  # ick/meh
        blank: 'blank line',
        comment: 'comment line',
        section: 'section line',
        key_value: 'key-value line',
        end_of_input: 'end of input',
        }

    _transitions_via_state_name = {
        'start': (
            o(blank),
            o(comment),
            o(section, call='on_section_start', transition_to='inside entity'),
            ),
        'inside entity': (
            o(key_value),  # ..
            o(blank),
            o(comment),
            o(end_of_input, call='at_end_of_input')
            ),
        'done': (),
        }

    _ = _noun_phrase_via_matcher_function.__getitem__
    return {
            'transitions_via_state_name': _transitions_via_state_name,
            'nonterminal_symbol_noun_phrase_via_matcher_function': _,
            }


_state_machine = sm_lib.StateMachine(_define_state_machine)


def cover_me():  # #todo
    raise(Exception('cover me'))


_not_ok = False
_stop = (_not_ok, None)

# #born.
