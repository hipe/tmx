"""
New experiment with CLI, exploring these claims:

- For smaller CLI's you can derive the syntax from the "usage line(s)"
- A small CLI's syntax could likewise be derived from a python function
- (in general we call these types of relationships "isomorphisms".)
- Various compositions of the above should be possible
- Support for '--help' (and '-h') should need zero buy-in from designer
- Every aspect of this should be fully customizable, opt-outable
- The option to stop on the first unrecognized token without complaining;
  to allow for compound construction with passive, chainable parsers.

In implementation, this system is divided into one backend "engine" and
theoretically several available "frontends" that produce grammars for the
backend to consume. This is just one of several theoretical frontends.

[#608.18] has tons and tons of documentation explaining almost every
aspect of this module.
- Introducing the distinction between positionals and nonpositionals
"""


import re

def build_invocation(
        sin, sout, serr, argv, usage_lines,
        docstring_for_help_description):

    seqs = tuple(_sequence_via_usage_line(s) for s in usage_lines)
    if 1 == len(seqs):
        engine, = seqs
    else:
        xx('never been kissed, probably fine')
        engine = _home().ALTERNATION_VIA_SEQUENCES(seqs)

    class Invocation:
        def __init__(self):
            self.argv_stack = list(reversed(argv))
            self._long_program_name = self.argv_stack.pop()

        def returncode_or_parse_tree(self):
            resp = _response_via_engine(sin, self.argv_stack, engine)
            return _returncode_or_parse_tree_via_response(serr, resp, self)

        @property
        def head_token(self):
            return self.argv_stack[-1]  # ..

        _raw_usage_lines = usage_lines
        _docstring = docstring_for_help_description

        @property
        def program_name(self):
            from os.path import basename
            return basename(self._long_program_name)

    return Invocation()


def _response_via_engine(sin, argv_stack, engine):
    resp = engine.receive_input_event('is_interactive', sin.isatty())
    if resp:
        return resp
    while len(argv_stack):
        resp = engine.receive_input_event('head_token', argv_stack[-1])
        if resp:
            return resp
        argv_stack.pop()
    return engine.receive_input_event('end_of_tokens')


def _returncode_or_parse_tree_via_response(serr, resp, invo):
    handler = _function_registry()

    @handler
    def early_stop(explain):
        rc = _returncode_and_behave_via_early_stop(serr, *resp[1:], invo)
        return rc, None

    @handler
    def parse_tree(pt):
        return None, pt

    return handler[resp[0]](*resp[1:])


def _returncode_and_behave_via_early_stop(serr, explain, invo):
    handler = _function_registry()

    @handler
    def early_stop_reason(*neato):
        expresser = _EarlyStopExpresser(invo)
        func = getattr(expresser, neato[0])
        w = serr.write
        for line in func(*neato[1:]):
            w(line)
        if not expresser._do_invite:
            return
        w(f"see '{invo.program_name} -h' for help\n")

    @handler
    def stderr_line(line):
        serr.write(line)

    @handler
    def returncode(rc):
        returncode.value = rc

    returncode.value = None

    for sx in explain():
        handler[sx[0]](*sx[1:])

    assert returncode.value is not None
    return returncode.value


class _EarlyStopExpresser:
    """
    For each type of early stop, one function producing lines describing it.

    At #birth, this set of member functions was derived directly from the
    set of of early stops expressed in the home file (near return codes)
    """

    def __init__(self, invo):
        self._invocation = invo
        self._do_invite = True

    def display_help(self):
        self._do_invite = False
        from script_lib.magnetics.help_lines_via_invocation import \
                help_lines_via_components_EXPERIMENTAL_ as func
        invo = self._invocation
        return func(invo._raw_usage_lines, invo.program_name, invo._docstring)

    def cannot_be_dash(self):
        xx("has stderr line. should add context. say \"in <token>\"")

    def ambiguous_long(self, founds):
        xx("show token and be like \"did you mean\"")

    def ambiguous_short(self, token, did_you_mean):
        xx("also has did_you_mean (founds[str])")

    def unrecognized_option(self):
        yield f"unrecognized option {self._head_token!r}\n"

    def unrecognized_short(self, short):
        yield f"unrecognized option {short!r}\n"

    def expecting_subcommand(self, literal_value):
        yield f"expecting subcommand {literal_value!r}\n"

    def expecting_required_positional(self, shout):
        yield f"expecting {shout}\n"

    def unexpected_extra_argument(self):
        yield f"unexpected extra argument {self._head_token!r}\n"

    def wrong_interactivity(self):
        xx("has stderr line. maybe skip context for now")

    @property
    def _head_token(self):
        return self._invocation.head_token


def _sequence_via_usage_line(usage_line):
    kwargs = {k:v for k, v in _four_pieces_via_usage_line(usage_line)}
    return _home().SEQUENCE_VIA(**kwargs)


def _four_pieces_via_usage_line(usage_line):
    """Translate the stream of term sexps to the four name-value pairs.

    When we refactor to #just-in-time-parse-parsing, this function goes away.
    """

    def stack():
        yield 'optional_glob', lambda sx: positionals.append(sx), 1
        yield 'required_glob', lambda sx: positionals.append(sx), 2
        yield 'optional_positional', lambda sx: positionals.append(sx), 0
        yield 'required_positional', lambda sx: positionals.append(sx), 0
        yield 'nonpositional', lambda sx: nonpositionals.append(sx), 0
        yield 'subcommand', lambda sx: subcommands.append(sx), 0
        yield 'for_interactive', lambda sx: on_for_interactive(*sx[1:]), 1

    stack = list(stack())

    def on_for_interactive(yn):
        if yn is not None:
            return 'for_interactive', yn

    subcommands = []
    nonpositionals = []
    positionals = []

    for sx in _parse_usage_line(usage_line):
        typ = sx[0]
        if 'flag' == typ:
            typ = 'nonpositional'
        while True:
            if not len(stack):
                xx(f"oops, unexpected or in wrong position: {typ!r}")
            if typ == stack[-1][0]:
                break
            stack.pop()
        func, num_pops = stack[-1][1:]
        pair = func(sx)
        if pair:
            yield pair
        if num_pops:
            for _ in range(0, num_pops):
                stack.pop()

    if subcommands:
        yield 'subcommands', tuple(subcommands)

    if nonpositionals:
        yield 'nonpositionals', tuple(nonpositionals)

    if positionals:
        yield 'positionals', tuple(positionals)


def _parse_usage_line(usage_line):
    # In making [#608.17] an FSA dotfile, we decided this was way too complex
    # to be covered completely by hand-written FSA, so we came up with the
    # custom, stack-based approach below (near "customly" and described 
    # in [#608.18]).

    # == States & Transitions

    def from_beginning_state():
        yield if_USAGE_literal, will_move_to(from_after_USAGE_literal)

    def from_after_USAGE_literal():
        yield if_PROG_NAME_literal, be_for_interactive_and_move_to_etc
        yield if_pipey_thing, process_pipey_thing

    def from_after_pipey_thing():
        yield if_PROG_NAME_literal, will_move_to(from_expecting_next_term_or_end)

    def from_expecting_next_term_or_end():
        yield if_more_input, match_next_term_and_process_customly
        yield if_end_of_input, flush_any_final_thing

    def from_after_glob_term():
        yield if_end_of_input, flush_any_final_thing

    # == Actions

    def match_next_term_and_process_customly():
        sx, state.cursor = _term_matcher()(usage_line, state.cursor)
        typ = sx[0]
        cat = _term_category_via_term_type[typ]

        # (The density below is what avoids the noisiness of [#608.17])

        # If this category is already in the formal past, stop
        if cat in formal_term_categories_in_the_past:
            raise match_failure(explain_bad_category_position(cat))

        # Special handling for this one thing
        if 'required_glob' == cat and \
                'optpos_category' in actual_term_categories_in_the_past:
            raise match_failure("required glob can't follow optional positional")

        # Since it's not in the formal past, it must be somewhere in the stack
        while True:
            this_category = term_category_present_or_future_stack[-1][0]
            if this_category == cat:

                # Maybe pop this off the stack
                arity, = term_category_present_or_future_stack[-1][1:]
                is_max_one = ('zero_or_more', 'max_one').index(arity)
                if is_max_one:
                    # Put this category in both pasts (may be redundant)
                    actual_term_categories_in_the_past[cat] = None
                    formal_term_categories_in_the_past[cat] = None

                    term_category_present_or_future_stack.pop()
                break

            # This category is not in formal past nor matches the arg category.
            # Put it in the formal past so we know its time is passed
            formal_term_categories_in_the_past[this_category] = None
            term_category_present_or_future_stack.pop()

        # There's only one kind of term that needs to be flattened
        if 'nested_optional_positionals' == typ:
            shouts, = sx[1:]
            return tuple(('optional_positional', s) for s in shouts)  # #here1
        return (sx,)  # #here1

    def explain_bad_category_position(cat):
        last_cat = list(actual_term_categories_in_the_past.keys()).pop()
        cat_short = cat.replace('_category', '')
        if last_cat == cat:
            return f"Can't have more than one {cat_short}"
        last_cat_short = last_cat.replace('_category', '')
        return f"Can't have {cat_short} after {last_cat_short}"

    term_category_present_or_future_stack = [
        ('glob_category', 'max_one'),
        ('optpos_category', 'max_one'),
        ('reqpos_category', 'zero_or_more'),
        ('nonpositional_category', 'zero_or_more'),
        ('subcommand_category', 'zero_or_more')
    ]
    formal_term_categories_in_the_past = {}
    actual_term_categories_in_the_past = {}

    def process_pipey_thing():
        md = rx_pipey_thing.assert_match(usage_line, state.cursor)
        state.cursor = md.end()
        move_to(from_after_pipey_thing)
        return (('for_interactive', False),)  # #here1

    o = _AssertivePattern
    rx_pipey_thing = o(r'<[a-z]+(?:-[a-z]+)*>[ ]\|[ ]', expecting="pipey thing")

    def be_for_interactive_and_move_to_etc():
        move_to(from_expecting_next_term_or_end)
        # the absence of the pipey thing doesn't necessarily confer etc so None
        return (('for_interactive', None),)  # #here1

    def flush_any_final_thing():
        pass  # nothing to do, ever, for now

    # == Matchers

    def if_PROG_NAME_literal():
        return match(prog_name_literal_rx)

    c = re.compile
    prog_name_literal_rx = c('{{prog_name}}')

    def if_USAGE_literal():
        return match(usage_literal_rx)

    usage_literal_rx = c('usage:[ ]')

    def if_pipey_thing():
        return '<' == usage_line[state.cursor]

    def if_end_of_input():
        return leng == state.cursor

    def if_more_input():
        return leng != state.cursor

    state = from_beginning_state  # #watch-the-world-burn
    state.cursor = 0
    assert '\n' == usage_line[-1]
    leng = len(usage_line) - 1

    # - Support for Matchers

    def match(rx):
        md = rx.match(usage_line, state.cursor)
        if not md:
            return
        state.cursor = md.span()[1]
        state.md = md
        return True

    def pop_matchdata():
        ret = state.md
        state.md = None
        return ret

    # == State machine mechanics

    def will_move_to(state_function):
        def move():
            return move_to(state_function)
        return move

    def move_to(state_function):
        state.state_function = state_function

    state.state_function = from_beginning_state

    def find_and_call_action():
        for matcher, action in state.state_function():
            if (found := matcher()):
                return action()
        raise match_failure(_reason_via_state_function(state.state_function))

    def match_failure(reason):
        return _MatchFailure(reason, string=usage_line, cursor=state.cursor)

    while if_more_input():
        if (flush_these := find_and_call_action()):
            for item in flush_these:  # #here1
                yield item
    if (flush_these := find_and_call_action()):
        for item in flush_these:  # #here1
            yield item


def _term_matcher():
    if _term_matcher.value is None:
        _term_matcher.value = _build_term_matcher()
    return _term_matcher.value


_term_matcher.value = None


def _build_term_matcher():  # #testpoint
    """The '{{prog_name}}' literal can be followed by O-to-N terms EACH of
    which is one of the [#608.18] seven foundational term types. (See
    "Development of the seven foundational term types" there.)
    The order of the below list is didactic with that documentation.

    foo-bar             subcommand (literal)
                        ("options":)
    [-flag]               flag
    [--flag]              flag
    [-file=DING]          optional_nonpositional
    [--file=DING]         optional_nonpositional
    ARG                 required_positional
    [ARG [FARG [PARG]]] nested_optional_positionals
    ARG [ARG [..]]      required_glob
    [ARG [ARG [..]]]    optional_glob

    The resultant function matches "greedily" (the longest match) but doesn't
    match end of the string, so it can be used to match each next term in a
    usage line.
    """

    def match_term(string, cursor):
        md = rx1.assert_match(string, cursor)
        cursor += 1  # LOOK skip over the space that was matched
        which = _which_one_match(md)
        if 'sq' == which:
            return match_bracketed_expression(string, cursor)
        if 'UC' == which:
            return match_reqpos_or_reqglob(string, cursor)
        assert 'LC' == which
        return match_subcommand(string, cursor)

    o = _AssertivePattern
    rx1 = o(r'[ ](?:(?P<sq>\[)|(?P<UC>[A-Z])|(?P<LC>[a-z]))',
            expecting="open bracket or [A-Z] or [a-z]")

    def match_bracketed_expression(string, cursor):
        # Assume string at cursor is an open bracket
        cursor += 1  # LOOK advance past the open bracket

        # in the spirit of #here2, check only the (any) first character
        md = rx_first_char_after_open_bracket.assert_match(string, cursor)
        which = _which_one_match(md)
        if 'dash' == which:
            sx, next_cursor = match_dash_term(string, cursor)
        else:
            assert 'A_to_Z' == which
            sx, next_cursor = match_bracketed_shouty_term(string, cursor)
        md = rx_close_bracket.assert_match(string, next_cursor)
        return sx, md.end()  # #here3

    shout_rxs = '[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*'

    rx_first_char_after_open_bracket = o(
            '(?:(?P<dash>-)|(?P<A_to_Z>[A-Z]))',
            expecting="dash or x or y or z")

    def match_bracketed_shouty_term(string, cursor):
        # match "[ARG [ARG [..]]]" or "[ARG [FARG [PARG]]]"

        def recurse(cur, depth):
            # Only allow ellpsis at this one depth
            if 3 == depth:
                md1 = rx_shout_or_ellipsis.assert_match(string, cur)
                which = _which_one_match(md1)
                if 'ellipsis' == which:
                    yield 'ellipsis', md1.end()
                    return
            else:
                md1 = rx_shout.assert_match(string, cur)
            cur = md1.end()
            md2 = rx_close_bracket_or_space_and_open_bracket.assert_match(
                    string, cur)
            which = _which_one_match(md2)
            if 'close_bracket' == which:
                yield 'var', md1['shout'], cur  # LOOK don't advance
                # we have it in there for better errors
                return
            cur = md2.end()  # *do* advance
            yield 'var', md1['shout'], cur
            assert 'space_and_open_bracket' == which
            for sx in recurse(cur, depth+1):
                last_cursor = sx[-1]
                yield sx
            md3 = rx_close_bracket.assert_match(string, last_cursor)
            yield 'close_bracket', md3.end()
        stack = list(recurse(cursor, 1))
        last_cursor = stack[-1][-1]

        # Skim off the close brackets (they were necessary before)
        while 'close_bracket' == stack[-1][0]:
            stack.pop()

        # Take the ellipsis term off so the list is normalized
        yes_ellipsis = False
        if 'ellipsis' == stack[-1][0]:
            stack.pop()
            yes_ellipsis = True

        # If it's ellipsis, they must all be the same. Otherwise all different
        if yes_ellipsis:
            all_must_be_this = None
        else:
            varz = []
            seen = {}

        for sx in stack:
            assert 'var' == sx[0]
            shout, curs = sx[1:]
            if yes_ellipsis:
                # Every term must be the same
                if all_must_be_this is None:
                    all_must_be_this = shout
                elif all_must_be_this != shout:
                    raise _MatchFailure(
                        f"For glob, expected repeat of {all_must_be_this!r}",
                        string=string, cursor=(curs-len(shout)))
            elif shout in seen:  # Every term must be different
                raise _MatchFailure(
                    f"for now, an optional positional can't re-use a var name",
                    string=string, cursor=(curs-len(shout)))
            else:
                varz.append(shout)
                seen[shout] = None

        if yes_ellipsis:
            result_sx = 'optional_glob', all_must_be_this
        else:
            result_sx = 'nested_optional_positionals', tuple(varz)

        return result_sx, last_cursor  # #here3

    ellipsis_rsx = r'\.\.'
    rx_shout_or_ellipsis = o(
            f'(?:(?P<ellipsis>{ellipsis_rsx})|'
            f'(?P<shout>{shout_rxs}))',
            expecting='ellipsis ("..") or SHOUTY_ARG')
    rx_close_bracket_or_space_and_open_bracket = o(
            r'(?:(?P<close_bracket>])|(?P<space_and_open_bracket>[ ]\[))',
            expecting="close bracket or space and open bracket")
    rx_close_bracket = o(']', expecting='close square bracket ("]")')

    def match_reqpos_or_reqglob(string, cursor):
        """Assume string[cursor] is [A-Z].
        "ARG [ARG [..]]" looks a lot like "[ARG [ARG [..]]]", so at first
        glance it's tempting to DRY the work of the latter with that of the
        former. However we do not, because:
          - The latter we solve recursively to match two kinds of terms.
            The former does not solve as elegantly with recursion.
        Take care to match only "FOO [FOO" such that the same term is
        repeated. When it is not, then probably the parser will use the
        aforementioned other strategy when it gets to that token.
        Annoyingly we'll repeat a parsing of the ellipsis surface sequence.
        """
        md = rx_reqglob_head.assert_match(string, cursor)
        shout = md['shout']
        cursor = md.end()
        if not md['globby_head']:
            return ('required_positional', shout), cursor
        md = rx_glob_assertion.assert_match(string, cursor)
        return ('required_glob', shout), md.end()  # #here3

    rx_reqglob_head = o(
            f'(?P<shout>{shout_rxs})(?P<globby_head> \\[\\1 )?',
            expecting="SHOUT or SHOUT [SHOUT [..]]")
    rx_glob_assertion = o(r'\[\.\.]]', expecting='"[..]]"')
    rx_shout = o(f'(?P<shout>{shout_rxs})', expecting='SHOUTY_ARG')

    def match_dash_term(string, cursor):
        md = rx_dash_term.assert_match(string, cursor)
        familiar_name = string[cursor:(md.span('slug')[1])]
        beg, end = md.span('nonpositional_variable_name')
        if -1 == beg:
            sx = 'flag', familiar_name
        else:
            sx = ('optional_nonpositional',
                    familiar_name, md['nonpositional_variable_name'])
        return sx, md.span()[1]  # #here3

    rx_dash_term = o(
            '-(?P<_2nd_dash>-)?'
            '(?P<slug>[a-zA-Z][-a-zA-Z0-9]*)'
            f'(?:[= ](?P<nonpositional_variable_name>{shout_rxs}|-))?',
            expecting="--foo-bar[=DING]")

    def match_subcommand(string, cursor):
        md = rx_subcommand.assert_match(string, cursor)
        return ('subcommand', md['familiar_name']), md.end()  # #here3

    rx_subcommand = o(
            '(?P<familiar_name>[a-z][a-z0-9]*(?:-[a-z0-9]+)*)',
            expecting="sub-command-name")

    return match_term


_term_category_via_term_type = {
    'optional_glob': 'glob_category',
    'required_glob': 'glob_category',
    'nested_optional_positionals': 'optpos_category',
    'required_positional': 'reqpos_category',
    'optional_nonpositional': 'nonpositional_category',
    'flag': 'nonpositional_category',
    'subcommand': 'subcommand_category',
}


"""
Implementation/algorithm notes for above


:#here2: Even though we could maybe parse certain nonterminals
(like all terms, maybe) with one giant ball-of-mud regex, we opt instead for
breaking it up into smaller steps so we get more useful error messages to the
user on parse failure.
"""


class _AssertivePattern:
    def __init__(self, rx_s, expecting):
        self._rx = re.compile(rx_s)
        self._expecting = expecting

    def assert_match(self, string, cursor):
        md = self._rx.match(string, cursor)
        if md:
            return md
        raise _MatchFailure(f"Expecting {self._expecting}", string, cursor)


def _which_one_match(md):
    return next(k for k, v in md.groupdict().items() if v)


class _MatchFailure(RuntimeError):
    def __init__(self, reason, string, cursor):
        self.reason, self.string, self.cursor = reason, string, cursor
        self._string = "\n" + ''.join(self._to_pieces())

    def __str__(self):
        return self._string

    def _to_pieces(self):
        yield self.reason
        yield '\n'
        yield self.string
        yield '-' * self.cursor
        yield '^'


# == state machine support wants to move

def _reason_via_state_function(state_function):
    return ' '.join(_reason_pieces_via_state_function(state_function))


def _reason_pieces_via_state_function(state_function):
    head = state_function.__name__.replace('_', ' ')
    yield head[0].upper() + head[1:]
    yield "can't find a transition. Expecting"
    itr = iter(re.sub('^if_', '', pair[0].__name__).sub('_', ' ')
            for pair in state_function())
    yield next(itr)
    for noun_phrase in itr:
        yield 'or'
        yield noun_phrase

# ==


class _function_registry:
    def __init__(self):
        self._dict = {}

    def __call__(self, f):
        self._dict[f.__name__] = f
        return f

    def __getitem__(self, k):
        return self._dict[k]


def _home():
    import script_lib as mod
    return mod


def xx(msg=None):
    raise RuntimeError(''.join(('to do', *((': ', msg) if msg else ()))))

# #birth
