from kiss_rdb.magnetics_ import (
        string_scanner_via_definition as scn_lib,
        state_machine_via_definition as sm_lib,
        )


def block_stream_via_file_lines(file_lines, listener):
    _actionser = _actionser_via_class(_ActionsForCoarseParse)
    return parse_(file_lines, _actionser, listener)


def traverse_IDs_without_validating__(file_lines, listener):
    # #open [#867.E] #testpoint island
    _actionser = _actionser_via_class(Actions_for_ID_Traversal_Non_Validating_)
    return parse_(file_lines, _actionser, listener)


def parse_(file_lines, actionser, listener):
    return state_machine_.parse(file_lines, actionser, listener)


def _actionser_via_class(cls):
    def actionser(ps):
        def f(name):
            return getattr(pa, name)
        pa = cls(ps)
        return f
    return actionser


class _ActionsForCoarseParse:

    def __init__(self, parse_state):

        # cache every line (including head lines)

        def f():
            self._line_cache.append(parse_state.line)
        parse_state.on_line_do_this(f)
        self._line_cache = []

        # for now we realize this dependency late (when we are constructed)
        from .entity_via_open_table_line_and_body_lines import (
                mutable_document_entity_via_open_table_line_and_body_lines as _
                )
        self._entity_via = _

        # do something different between first table and the rest
        self._on_section_start = self._on_first_section_start
        self._at_end_of_input = self._at_end_of_input_in_empty_file

        self._listener = parse_state.listener

    def on_section_start(self):
        return self._on_section_start()

    def at_end_of_input(self):
        return self._at_end_of_input()

    def _on_first_section_start(self):
        # whether empty or not, we guarantee exactly one head block

        self._on_section_start = self._on_subsequent_section_start
        self._at_end_of_input = self._at_end_of_input_normally
        return (okay, _HeadBlock(tuple(self._turn_over_lines())))

    def _on_subsequent_section_start(self):
        _lines = self._turn_over_lines()
        return self._MDE_via(_lines)

    def _at_end_of_input_in_empty_file(self):

        lines = self._release_all_lines()
        if len(lines):
            return (okay, _HeadBlock(tuple(lines)))  # (Case171)
        else:
            return stop  # (Case186)

    def _at_end_of_input_normally(self):
        # this is different from the other place where we make an MDE in
        # that here we must *not* backtrack over the line cache by one line

        return self._MDE_via(self._release_all_lines())

    def _MDE_via(self, lines):
        open_table_line, *body_lines = lines
        otl = open_table_line_via_line_(open_table_line, self._listener)
        if otl is None:
            return stop  # (Case200)

        mde = self._entity_via(otl, body_lines, self._listener)
        if mde is None:
            cover_me()  # ..
            return stop

        return (okay, mde)

    # -- these two

    def _turn_over_lines(self):
        # assume this is happening at section start
        # backtrack over the line that ended up being an open table line
        lc = self._line_cache
        self._line_cache = [lc.pop()]
        return lc

    def _release_all_lines(self):
        lines = self._line_cache
        del(self._line_cache)
        return lines


class Actions_for_ID_Traversal_Non_Validating_:
    """the imagined, intended purpose of this is for traversing every ID

    (for example for something like generating an index, we'll see..)

    for now we exercise many of the kinds of things that supposedly make
    kiss-rdb great by fast-parsing the big files and only parsing out the
    part we care about (the table-opening ("section") lines).

    FOR NOW no validation. like:
      - it does NOT check that any `meta` sect comes before any `attributes'
        section for any same entity (identifier).

      - it does NOT validate anything about the identifier. (upstream it is
        implicitly validated as being `[a-zA-Z0-9]+` maybe.)

      - e.g it does NOT validate that identifiers are in some valid range
        or are in ascending order. (probably this will be forthcoming, and
        somehow abstracted out of this so it is somehow a layer or something)

    before #history-A.1 we structured these parse actions to be logically
    similar for how we will want to do things for something like RETRIEVE
    or deep search (true traversal): you can't emit
    the entity until you've found its last line and you don't know you've
    reached its last line until either you hit the next line of the next
    section OR the end of the file.

    but now that we know that works, we're simplifying this so we can see
    if we can make this parse action somehow composable for the eventual
    new implementation of RETRIEVE
    """

    def __init__(self, parse_state):
        self._ps = parse_state
        self._listener = parse_state.listener

    def on_section_start(self):
        otl = open_table_line_via_line_(self._ps.line, self._listener)
        if otl is None:
            return stop
        return (okay, otl)

    def at_end_of_input(self):
        return nothing


def open_table_line_via_line_(line, listener):

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

    from .entity_via_open_table_line_and_body_lines import OpenTableLine_ as _
    return _(identifier, which, line)


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
            o(None, call='at_end_of_input')  # this must be the last rule
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


# ==

class _HeadBlock:

    def __init__(self, lines):
        self._lines = lines  # #testpoint

    def to_line_stream(self):
        return self._lines  # hwile it works

# ==


class ErrorMonitor_:
    """wrap a listener in another listener that monitors for failure.

    this is a band-aide as a response to the audacious suggestion that
    iterators can be something of a leaky abstraction:

    they make everything look clean for normal cases, but if something
    "soft fails" while traversing the "stream", we have no way of knowing
    that our exit from the loop is premature (that is, that the last item
    yielded was not actually the _last_ item), because we are trapped behind
    and limited by the iterator interface.

    consider the case of replacing the lines of a file with a list of
    modified lines. an iterator (of the new lines) is the compelling choice
    for lots of reasons. however, for such a case it is absolutely essential
    that we know that nothing failed by the time the iteration has ended.

    using exceptions as the band-aide would be even worse.
    """

    def __init__(self, listener):
        self.ok = True
        self.experimental_mutex = None  # go this away if it's annoying

        def my_listener(*chan):
            if 'error' == chan[0]:
                del self.experimental_mutex
                self.ok = False
                listener(*chan)

        self.listener = my_listener


def cover_me():
    raise Exception('cover me')


not_ok = False
stop = (not_ok, None)
okay = True
nothing = (okay, None)

# #history-A.3: "error monitor" moved to here from elsewhere
# #history-A.2: becomes stowaway location for "coarse parse"
# #history-A.1: simplify open-table line finding to be eager
# #born.
