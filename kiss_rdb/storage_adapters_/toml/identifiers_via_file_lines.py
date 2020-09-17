"""this module defines the grammar (state machine)

we use for coarse, line-based parsing of toml files.

it is a near-exact adaptation of [#863]
"""

from kiss_rdb.magnetics_.state_machine_via_definition import StateMachine
from kiss_rdb.magnetics.string_scanner_via_string import (
        StringScanner,
        pattern_via_description_and_regex_string)


def table_start_line_stream_via_file_lines_(file_lines, listener):
    return state_machine_.parse(
            all_lines=file_lines,
            actions_class=Actions_for_ID_Traversal_Non_Validating_,
            listener=listener)


class BaseActions_:
    """base class with every action (transition) defined as no-op.

    you are not required to subclass this, but if you don't, you must provide
    a definition for every transition.
    """

    def ready__to__table_begun(self):
        pass

    def ready__to__discretionary_block_1(self):
        pass

    def ready__to__done(self):
        pass

    def discretionary_block_1__to__discretionary_block_1(self):
        pass

    def discretionary_block_1__to__table_begun(self):
        pass

    def discretionary_block_1__to__done(self):
        pass

    def table_begun__to__inside_table(self):
        pass

    def table_begun__to__inside_multi_line_literal(self):
        pass

    def table_begun__to__inside_multi_line_basic(self):
        pass

    def table_begun__to__table_begun(self):
        pass

    def table_begun__to__discretionary_block_2(self):
        pass

    def table_begun__to__done(self):
        pass

    def discretionary_block_2__to__discretionary_block_2(self):
        pass

    def discretionary_block_2__to__inside_table(self):
        pass

    def discretionary_block_2__to__inside_multi_line_literal(self):
        pass

    def discretionary_block_2__to__inside_multi_line_basic(self):
        pass

    def discretionary_block_2__to__done(self):
        pass

    def inside_multi_line_literal__to__inside_multi_line_literal(self):
        pass

    def inside_multi_line_literal__to__inside_table(self):
        pass

    def inside_multi_line_basic__to__inside_multi_line_basic(self):
        pass

    def inside_multi_line_basic__to__inside_table(self):
        pass

    def inside_table__to__inside_table(self):
        pass

    def inside_table__to__inside_multi_line_literal(self):
        pass

    def inside_table__to__inside_multi_line_basic(self):
        pass

    def inside_table__to__table_begun(self):
        pass

    def inside_table__to__discretionary_block_3(self):
        pass

    def inside_table__to__done(self):
        pass

    def discretionary_block_3__to__inside_table(self):
        pass

    def discretionary_block_3__to__inside_multi_line_literal(self):
        pass

    def discretionary_block_3__to__inside_multi_line_basic(self):
        pass

    def discretionary_block_3__to__discretionary_block_3(self):
        pass

    def discretionary_block_3__to__table_begun(self):
        pass

    def discretionary_block_3__to__done(self):
        pass


class Actions_for_ID_Traversal_Non_Validating_(BaseActions_):
    """

    meant to be a fast-ish, coarse traversal for the purpose of seeing
    all the in-use identifiers.

    FOR NOW no validation. like:
      - it does NOT check that any `meta` sect comes before any `attributes'
        section for any same entity (identifier).

      - it does NOT validate anything about the identifier. (upstream it is
        implicitly validated as being `[a-zA-Z0-9]+` maybe.)

      - e.g it does NOT validate that identifiers are in some valid range
        or are in ascending order. (probably this will be forthcoming, and
        somehow abstracted out of this so it is somehow a layer or something)

      - (at #history-A.4 everything overhauled for transition actions.)

      - (after #history-A.1 we simplified it just to emit on table open line.)

      - (before #history-A.1, these parse actions were implemented imagining
        we were doing something like a RETRIEVE where you can't emit the whole
        entity until you've found the end (i.e the start of next or EOF)..

    (before #history-A.1 this was done more complicatedly as proof-of-concept)
    """

    def __init__(self, parse_state):

        listener = parse_state.listener

        def f(line):
            return table_start_line_via_line_(line, listener)

        self._table_start_via_line = f
        self._parse_state = parse_state

    def ready__to__table_begun(self):
        return self._table_begun()

    def discretionary_block_1__to__table_begun(self):
        return self._table_begun()

    def table_begun__to__table_begun(self):
        return self._table_begun()

    def inside_table__to__table_begun(self):
        return self._table_begun()

    def discretionary_block_3__to__table_begun(self):
        return self._table_begun()

    def _table_begun(self):
        ts = self._table_start_via_line(self._parse_state.line)
        if ts is None:
            return stop
        return (okay, ts)


def table_start_line_via_line_(line, listener):

    # the line must parse into "name components" "[a.b.c]\n" => ('a', 'b', 'c')

    nc = _name_components_via_line(line, listener)
    if nc is None:
        return

    # #cover-me we don't cover if it's "[]\n"

    # the first name component must be the keyword `item`

    if 'item' != nc[0]:
        return _input_error(listener, expecting='keyword "item"', position=1)

    # if there's only one name component, it's too few

    length = len(nc)
    if 1 == length:
        _ = 1 + len(nc[0])  # eew
        return _input_error(listener, expecting='dot', position=_)

    # if there's only two name components, it's also too few

    identifier = nc[1]
    if 2 == length:
        _ = 1 + len(nc[0]) + 1 + len(identifier)  # the worst
        return _input_error(listener, expecting='dot', position=_)

    # the third name component must be one of these TWO keywords

    keyword = nc[2]
    if 'attributes' == keyword:
        which = 'attributes'
    elif 'meta' == keyword:
        which = 'meta'
    else:
        _ = 1 + len(nc[0]) + 1 + len(identifier) + 1  # SO BAD
        __ = 'keyword "attributes" or "meta"'
        return _input_error(listener, expecting=__, position=_)

    # if there's more than three name components, it's too many

    if 3 < length:
        _ = 1 + len(nc[0]) + 1 + len(identifier) + 1 + len(which)  # NOOOOOO
        return _input_error(listener, expecting="']'", position=_)

    return _TableStartLine(
            identifier_string=identifier,
            table_type=which,
            line=line)


def _name_components_via_line(line, listener):
    """
    parses toml "section" lines crudely.

    given a line like this:
        "[foo.bar.baz123]\n"
    result in an array like this:
        ["foo", "bar", "baz123"]
    """

    scn = StringScanner(line, listener)

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


o = pattern_via_description_and_regex_string
_open_brace = o('open brace ("[")', r'\[')
_loosey_goosey_identifier = o('identifier ([a-zA-Z0-9]+)', r'[a-zA-Z0-9]+')
_dot = o('dot (".")', r'\.')
_close_brace_and_end_of_line = o('close brace and end of line', r'\]\n$')
del(o)


def _input_error(listener, **kwargs):
    listener('error', 'structure', 'input_error', lambda: kwargs)


# -- below is derived directly from the [#863] state transition graph

def _define_state_machine(funcs):  # interface here is VERY experimental!

    o = funcs.transition_via_definition
    del(funcs)

    # --

    # BIG HACK: the function names for the below simple "testers"
    # are used in UI !! eek (Case4072) (e.g "blank line or comment line")

    def blank_line_or_comment(line):
        if '\n' == line:
            return True
        if '#' == line[0]:  # #[#867.F]
            return True

    def table_start(line):
        return '[' == line[0]  # assume [#864.provision-2.1] - first character

    import re
    _ = '"""'  # don't break syntax highlighting :/
    bare_key_rx = re.compile(f"^([A-Za-z0-9_-]+) ?= ?('''|{_})?")  # :#here1

    def dispatch_when_key_value(line):
        md = bare_key_rx.match(line)
        if md is None:
            return

        quot = md[2]  # #here1

        if quot is None:
            return ('inside table', md)

        if '"""' == quot:
            return ('inside multi-line literal', md)

        if "'''" == quot:
            return ('inside multi-line basic', md)

        assert(False)

    def no_literal_delim(line):
        return '"""' not in line

    def yes_literal_delim(line):
        return '"""' in line

    def no_basic_delim(line):
        return "'''" not in line

    def yes_basic_delim(line):
        return "'''" in line

    # --

    key_value_of_some_sort = o(
            dispatcher=dispatch_when_key_value,
            noun_phrase='key-value of some sort',
            transition_tos=(
                'inside table',
                'inside multi-line literal',
                'inside multi-line basic',
                ))
    blank_or_comment_stay_here = o(
            tester=blank_line_or_comment)
    table_start__to__table_begun = o(
            tester=table_start,
            transition_to='table begun')
    eos_ok = o(
            tests_for_EOS=True,
            transition_to='done')
    # --

    # (again, below is derived almost directly from [#863].)

    _transitions_via_state_name = {
        'ready': (
            table_start__to__table_begun,
            o(blank_line_or_comment, 'discretionary block 1'),
            eos_ok,
            ),
        'discretionary block 1': (
            blank_or_comment_stay_here,
            table_start__to__table_begun,
            eos_ok,
            ),
        'table begun': (
            key_value_of_some_sort,
            table_start__to__table_begun,
            o(blank_line_or_comment, 'discretionary block 2'),
            eos_ok,
            ),
        'discretionary block 2': (
            blank_or_comment_stay_here,
            key_value_of_some_sort,
            eos_ok,
            ),
        'inside multi-line literal': (
            o(no_literal_delim),
            o(yes_literal_delim, 'inside table'),
            ),
        'inside multi-line basic': (
            o(no_basic_delim),
            o(yes_basic_delim, 'inside table'),
            ),
        'inside table': (
            key_value_of_some_sort,
            table_start__to__table_begun,
            o(blank_line_or_comment, 'discretionary block 3'),
            eos_ok,
            ),
        'discretionary block 3': (
            key_value_of_some_sort,
            blank_or_comment_stay_here,
            table_start__to__table_begun,
            eos_ok,
            ),
        'done': (),
        }
    return {
            'name_of_initial_state': 'ready',
            'transitions_via_state_name': _transitions_via_state_name,
            'name_of_goal_state': 'done',
            }


state_machine_ = StateMachine(_define_state_machine)


# ==


def TSLO_via(identifier_string, meta_or_attributes):  # table start line object
    _meh = f'[item.{identifier_string}.{meta_or_attributes}]\n'
    return _TableStartLine(identifier_string, meta_or_attributes, _meh)


class _TableStartLine:

    def __init__(self, identifier_string, table_type, line):
        self.identifier_string = identifier_string
        self.table_type = table_type
        self.line = line
        self._identifier = None

    def identifier_for_storage_adapter(self):
        # it looks like we accomplish RETRIEVE without creating identifiers..

        from modality_agnostic import listening
        listener = listening.throwing_listener

        if self._identifier is None:
            from kiss_rdb.magnetics_.identifier_via_string import (
                identifier_via_string_)
            self._identifier = identifier_via_string_(
                    self.identifier_string, listener)
        return self._identifier


# ==

not_ok = False
stop = (not_ok, None)
okay = True
nothing = (okay, None)

# #history-A.4: actions re-arch to support multi-line strings
# #history-A.3: "error monitor" moved to here from elsewhere
# #history-A.2: becomes stowaway location for "coarse parse"
# #history-A.1: simplify open-table line finding to be eager
# #born.
