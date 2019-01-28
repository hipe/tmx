from kiss_rdb.magnetics_ import (
        string_scanner_via_definition as scn_lib,
        state_machine_via_definition as sm_lib,
        )


def items_via_toml_path(toml_path):
    raise Exception('integrate me with below (easy)')  # #todo


def _traverse_IDs_without_validating(all_lines, listener):  # #testpoint, #todo
    _actionser = _actionser_via_class(_Actions_for_ID_Traversal_Non_Validating)
    return parse_(all_lines, _actionser, listener)


def parse_(all_lines, actionser, listener):
    return state_machine_.parse(all_lines, actionser, listener)


def _actionser_via_class(cls):
    def actionser(ps):
        def f(name):
            return getattr(pa, name)
        pa = cls(ps)
        return f
    return actionser


class _Actions_for_ID_Traversal_Non_Validating:
    """the imagined, intended purpose of this is for traversing every ID

    (for example for something like generating an index, we'll see..)

    for now we exercise many of the kinds of things that supposedly make
    kiss-rdb great by fast-parsing the big files and only parsing out the
    part we care about (the section lines).

    FOR NOW no validation. like:
      - it does NOT check that any `meta` sect comes before any `attributes'
        section for any same entity (identifier).

      - it does NOT validate anything about the identifier. (upstream it is
        implicitly validated as being `[a-zA-Z0-9]+` maybe.)

      - e.g it does NOT validate that identifiers are in some valid range
        or are in ascending order. (probably this will be forthcoming, and
        somehow abstracted out of this so it is somehow a layer or something)

    BUT as an exercise, for now we're structuring this in logically the same
    way we want to for when we will vendor-parse an entity: you can't emit
    the entity until you've found its last line and you don't know you've
    reached its last line until either you hit the next line of the next
    section OR the end of the file.
    """

    def __init__(self, parse_state):
        self._on_section_start = self._on_section_start_at_beginning
        self._ps = parse_state

    def on_section_start(self):
        o = self._ps
        tup = item_section_line_via_line_(o.line, o.listener)
        if tup is None:
            return stop
        return self._on_section_start(tup)

    def _on_section_start_at_beginning(self, tup):
        self._cover_me_semaphore = True
        self._previous_section = tup
        self._on_section_start = self._on_section_start_subsequently
        return nothing

    def _on_section_start_subsequently(self, tup):
        previous_section = self._previous_section
        self._previous_section = tup
        return (okay, previous_section)

    def at_end_of_input(self):
        del self._cover_me_semaphore
        return (okay, self._previous_section)


def item_section_line_via_line_(line, listener):

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

    import re

    def blank(line):
        return '\n' == line
    blank.noun_phrase = 'blank line'

    def comment(line):
        return '#' == line[0]  # assume [#864.provision-2.1] - first character
    comment.noun_phrase = 'comment line'

    def section(line):
        return '[' == line[0]  # assume [#864.provision-2.1] - first character
    section.noun_phrase = 'section line'

    def key_value(line):
        return bare_key_rx.match(line)
    key_value.noun_phrase = 'key-value line'
    bare_key_rx = re.compile(r'^[A-Za-z0-9_-]+ = ')

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
            o(section, call='on_section_start'),
            o(None, call='at_end_of_input')  # this must be the last rule
            ),
        }

    return {
            'transitions_via_state_name': _transitions_via_state_name,
            }


state_machine_ = sm_lib.StateMachine(_define_state_machine)


not_ok = False
stop = (not_ok, None)
okay = True
nothing = (okay, None)

# #born.
