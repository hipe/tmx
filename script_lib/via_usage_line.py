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
"""


import re

def build_invocation(
        sin, sout, serr, argv, usage_lines,
        docstring_for_help_description,
        parameter_refinements=None):

    usage_lines = tuple(usage_lines)  # clients like functions & generators
    def seq_via_usage_line(s):
        return _sequence_via_usage_line(s, parameter_refinements)
    seqs = tuple(seq_via_usage_line(s) for s in usage_lines)
    return _build_invocation(
            sin, serr, argv, seqs, usage_lines, docstring_for_help_description)


def _build_invocation(
        sin, serr, argv, seqs, usage_lines, docstring_for_help_description):
    # #testpoint

    if 1 == len(seqs):
        engine, = seqs
    else:
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

        @property
        def first_usage_line(self):
            from script_lib.magnetics.help_lines_via_invocation import \
                    build_fake_template_thing_ as func
            return func(self.program_name)(usage_lines[0])

        def description_lines_via_docstring(_, s):  # 1x
            from script_lib.magnetics.help_lines_via_invocation import \
                description_lines_via_mixed_ as func
            return func(s)

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
            if 'stop_parsing' == resp[0]:
                pt, = resp[1:]
                if pt.do_consume_head_token:
                    argv_stack.pop()  # indicate we processed it
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

    @handler
    def stop_parsing(pt):
        return None, pt

    return handler[resp[0]](*resp[1:])


def _returncode_and_behave_via_early_stop(serr, explain, invo):
    handler = _function_registry()

    @handler
    def early_stop_reason(*neato):
        early_stop_reason.tuple = neato

    early_stop_reason.tuple = None

    @handler
    def stderr_line(line):
        stderr_line.lines.append(line)

    stderr_line.lines = []

    @handler
    def returncode(rc):
        returncode.value = rc

    returncode.value = None

    other = {}
    for sx in explain():
        k = sx[0]
        if k in handler:
            handler[k](*sx[1:])
        elif k in other:
            xx(f'oops: {k!r}')
        elif 2 == (leng := len(sx)):
            other[k] = sx[1]
        elif 0 == leng:
            other[k] = True
        else:
            other[k] = sx[1:]

    assert early_stop_reason.tuple is not None
    assert returncode.value is not None

    expresser = _EarlyStopExpresser(invo)
    tup = early_stop_reason.tuple
    func = getattr(expresser, tup[0])
    w = serr.write
    for line in func(*tup[1:], **other):
        w(line)

    for line in stderr_line.lines:
        w(line)

    if expresser._do_invite:
        w(f"see '{invo.program_name} -h' for help\n")

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
        yield "value cannot be dash\n"

    def failed_value_constraint(self, desc):
        yield f"expecting {desc}\n"

    def ambiguous_long(self, founds):
        yield f"ambiguous long-looking token {self._head_token!r}\n"
        yield f"did you mean {founds!r}?\n"

    def ambiguous_short(self, did_you_mean):
        yield f"ambiguous short-looking token {self._head_token!r}\n"
        yield f"did you mean {did_you_mean!r}?\n"

    def unrecognized_option(self):
        yield f"unrecognized option {self._head_token!r}\n"

    def unrecognized_short(self):
        short = self._head_token
        yield f"unrecognized option {short!r}\n"

    def expecting_subcommand(self, literal_value):
        yield f"expecting subcommand {literal_value!r}\n"

    def expecting_required_positional(self, shout):
        yield f"expecting {shout}\n"

    def unexpected_extra_argument(self):
        yield f"unexpected extra argument {self._head_token!r}\n"

    def wrong_interactivity(self, formal_for_interactive, is_interactive):
        if formal_for_interactive:
            assert not is_interactive
            yield "Cannot handle pipe thru STDIN (must be interactive)\n"
            return
        assert is_interactive
        yield "Must have pipe from STDIN (can't be interactive)\n"

    @property
    def _head_token(self):
        return self._invocation.head_token


def _sequence_via_usage_line(usage_line, parameter_refinements=None):  # #testpoint
    sexps = _parse_usage_line(usage_line)
    return _home().SEQUENCE_VIA_TERM_SEXPS(sexps, parameter_refinements)


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

        # (there's only 1 surface syntax term type that needs special process.)
        if 'nested_optional_positionals' == sx[0]:
            fam_names, = sx[1:]
            return tuple(('optional_positional', s) for s in fam_names)  # #here1

        return (sx,)  # #here1

    state = from_beginning_state  # #watch-the-world-burn

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

    state.last_category = None
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

    state.match_failure = match_failure  # #here5

    stay = True
    while stay:
        stay = if_more_input()
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
    -file               required_positional (nonpositional-looking literal)
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
        if 'open_square_bracket' == which:
            return match_bracketed_expression(string, cursor)
        if 'uppercase' == which:
            return match_reqpos_or_reqglob(string, cursor)
        if 'lowercase' == which:
            return match_subcommand(string, cursor)
        if 'single_dash' == which:
            return _build_single_dash_sexp(), cursor+1  # #here3
        assert 'nonpositional_looking_literal' == which
        if True:
            return match_nonpos_looking_literal(string, cursor)

    o = _AssertivePattern
    rx1 = o('[ ](?:'
                '(?P<open_square_bracket>\\[)|'
                '(?P<uppercase>[A-Z])|'
                '(?P<lowercase>[a-z])|'
                '(?P<nonpositional_looking_literal>-[a-zA-Z]{2,})|'
                '(?P<single_dash>-(?=(?:$| )))'
            ')',
            expecting="open bracket or [A-Z] or [a-z] or single dash")

    def match_bracketed_expression(string, cursor):
        # Assume string at cursor is an open bracket
        cursor += 1  # LOOK advance past the open bracket

        # in the spirit of #here2, check only the (any) first character
        md = rx_first_char_after_open_bracket.assert_match(string, cursor)
        which = _which_one_match(md)
        if 'dash' == which:
            sx, next_cursor = match_dash_term(string, cursor)
        elif 'A_to_Z' == which:
            sx, next_cursor = match_bracketed_shouty_term(string, cursor)
        else:
            assert 'a_to_z'
            sx, next_cursor = match_stop_term(string, cursor)
        md = rx_close_bracket.assert_match(string, next_cursor)
        return sx, md.end()  # #here3

    shout_rxs = '[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*'

    rx_first_char_after_open_bracket = o(
            '(?:(?P<dash>-)|(?P<A_to_Z>[A-Z])|(?P<a_to_z>[a-z]))',
            expecting="dash or A-Z or a-z")

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

    def match_stop_term(string, cursor):
        # (writing it "by hand" for #here2 and because backwards)
        open_bracket_pos = cursor-1  # LOOK

        # Find the close bracket
        close_bracket_pos = string.find(']', cursor)
        if -1 == close_bracket_pos:
            raise _MatchFailure("closing ']' not found", string, cursor)

        # Assert that it ends with '..'
        inside = string[cursor:close_bracket_pos]
        if len(inside) < 3 or '..' != inside[-2:]:
            here = open_bracket_pos + len(inside) - 2
            raise _MatchFailure("expecting '..'", string, here)
        inside = inside[0:-2]

        # Make sure the content part matches these peevish rules
        md = re.search('[^-A-Za-z0-9 ]', inside)  # find first char that isn't
        if md:
            raise _MatchFailure(
                    "inside must be A-Z a-z 0-9 or dash or space",
                    string, (cursor+md.start()))
        if ' ' not in inside:
            raise _MatchFailure("must contain at least one space", string, cursor)

        familiar = string[open_bracket_pos:(close_bracket_pos+1)]
        return ('stop_parsing',  familiar), close_bracket_pos

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
            metavar = md['nonpositional_variable_name']
            sx = ['optional_nonpositional', familiar_name, metavar]
            if '-' == metavar:
                sx.append(('value_constraint', _must_be_dash_value_constraint))
                sx.append(('can_accept_dash_as_value',))
            sx = tuple(sx)
        return sx, md.end()  # #here3

    rx_dash_term = o(
            '-(?P<_2nd_dash>-)?'
            '(?P<slug>[a-zA-Z][-a-zA-Z0-9]*)'
            f'(?:[= ](?P<nonpositional_variable_name>{shout_rxs}|-))?',
            expecting="--foo-bar[=DING]")

    def match_nonpos_looking_literal(string, cursor):
        md = rx_nonpos_looking_literal.assert_match(string, cursor)
        sx = _build_nonpos_looking_literal_sexp(md['literal'])
        return sx, md.end()

    rx_nonpos_looking_literal = o(
            '(?P<literal>-[-a-zA-Z]+)(?!==)',
            expecting='"-foo-bar" or "-FOO-BAR" (not followed by "=")')

    def match_subcommand(string, cursor):
        md = rx_subcommand.assert_match(string, cursor)
        return ('subcommand', md['familiar_name']), md.end()  # #here3

    rx_subcommand = o(
            '(?P<familiar_name>[a-z][a-z0-9]*(?:-[a-z0-9]+)*)',
            expecting="sub-command-name")

    return match_term


def _build_single_dash_sexp():
    """Experimental implementation of the "single dash" as positional literal..
    Could be memoized but why.
    """

    def properties():
        yield ('can_accept_dash_as_value',)
        yield 'value_constraint', _must_be_dash_value_constraint
        yield 'value_normalizer', do_not_store
        yield 'familiar_name_function', lambda: '-'

    def do_not_store(token):
        assert '-' == token
        return
    return 'required_positional', None, *properties()


def _build_nonpos_looking_literal_sexp(target_token):
    """Experimental implementation of something like "-file X" w/o using =
    """

    def properties():
        constrain = _build_literal_value_constraint(target_token)
        yield 'value_constraint', constrain
        yield 'value_normalizer', do_not_store
        yield 'familiar_name_function', lambda: target_token

    def do_not_store(token):
        assert target_token == token
        return
    return 'required_positional', None, *properties()


def _must_be_dash_value_constraint(token):
    return _build_literal_value_constraint('-')(token)


def _build_literal_value_constraint(target_token):
    def constrain(token):
        if target_token == token:
            return
        def details():
            yield 'early_stop_reason', 'failed_value_constraint', repr(target_token)
            yield 'returncode', 101
        return 'early_stop', details
    return constrain





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
    itr = iter(re.sub('^if_', '', pair[0].__name__).replace('_', ' ')
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

    def __contains__(self, k):
        return k in self._dict


def _home():
    import script_lib as mod
    return mod


def xx(msg=None):
    raise RuntimeError(''.join(('to do', *((': ', msg) if msg else ()))))

# #history-C.3 lost code to sibling when changed to just-in-time-parse-parsing
# #history-C.2 (as referenced)
# #history-C.1 (as referenced)
# #birth
