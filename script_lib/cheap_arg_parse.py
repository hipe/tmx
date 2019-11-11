

def cheap_arg_parse(
        CLI_function, stdin, stdout, stderr, argv, formal_parameters,
        description_template_valueser=None, enver=None):

    """
    NOTE This is still highly experimental: it is almost guaranteed that the
    API will change (in terms of both function signatures and the exposed
    function constituency). #history-A.4 was an overhaul of this method to add
    support for parsing arbitrary options and (non-globbing) positional
    arguments. Its exit criteria was only that the many involved producer
    scripts continued to work as they did. #here marks new API experiments or
    places where we carry over some weaknesses from the previous code.
    :[#608.L]
    """

    _syntax_AST = syntax_AST_via_parameters_definition_(formal_parameters)
    CLI = CLI_via_syntax_AST_(_syntax_AST)

    def when_help(parameter_error):
        _pn = Renderers_(parameter_error.long_program_name).program_name
        __write_help_lines(
                stderr, description_template_valueser,
                CLI_function.__doc__, _pn, CLI)

    two, mon = _parse_CLI_args(stderr, argv, CLI, when_help)

    if two is None:
        return mon.exitstatus
    opt_vals, arg_vals = two

    _ = () if enver is None else (enver,)
    es = CLI_function(mon, stdin, stdout, stderr, *_, *opt_vals, *arg_vals)

    # user can return from the above function any arbitrary exitstatus. also
    # any arbitary emission could have "set" (elevated) the exitstatus.
    assert(isinstance(es, int))  # #[#022]
    mon.see_exitstatus(es)

    return mon.exitstatus


def _parse_CLI_args(stderr, argv, CLI, when_help=None):  # #testpoint

    from .magnetics.parser_via_grammar import TokenScanner
    tox = TokenScanner(argv)

    long_program_name = tox.shift()

    from .magnetics import error_monitor_via_stderr
    mon = error_monitor_via_stderr(stderr)

    def listener_for_parse_errors(*a):
        pe = ParameterError_(a, lambda: long_program_name)
        if pe.is_request_for_help:
            return when_help(pe)
        when_parameter_error(pe)

    def when_parameter_error(parameter_error):
        write_parameter_error_lines_(stderr, parameter_error)
        mon.see_exitstatus(456)  # be like 457 in sibling

    two = do_parse_(tox, CLI, listener_for_parse_errors)
    return two, mon


def require_interactive(stderr, stdin, argv):
    if stdin.isatty():
        return True
    o = stderr.write
    o(f"usage error: cannot read from STDIN.{_eol}")
    o(Renderers_(argv[0]).invite_line)


class Renderers_:  # centralize how these look & where they are rendered

    def __init__(self, long_program_name):
        self._long_program_name = long_program_name

    @property
    def invite_line(self):
        return f"see '{self.program_name} --help'{_eol}"

    @property
    def program_name(self):
        from os import path as os_path
        return os_path.basename(self._long_program_name)


class ParameterError_:  # like listening.emission_via_args
    # encapsulate the "backend" of our "routing" for emissions so it can
    # be shared. mainly, centralize the hacky way we trap requests for help

    def __init__(self, a, long_program_namer):
        severity, shape, error_category, error_case, payloader = a
        assert('error' == severity)
        assert('structure' == shape)
        assert('parameter_error' == error_category)  # not sure
        self.payload_dictionary = payloader()
        self.error_case = error_case
        self._long_program_namer = long_program_namer

    @property
    def is_request_for_help(self):
        if 'unrecognized_option' != self.error_case:
            return False
        return self.payload_dictionary['token'] in ('-h', '--help')

    @property
    def long_program_name(self):
        return self._long_program_namer()


def __write_help_lines(
        stderr, description_template_valueser,
        doc_string, program_name, CLI):

    from .magnetics.help_lines_via import desc_lineser_via, help_lines_via

    _descser = desc_lineser_via(description_template_valueser, doc_string)

    for line in help_lines_via(program_name, _descser, CLI.opts, CLI.args):
        stderr.write(_eol if line is None else f'{line}{_eol}')  # [#607.I]


def write_parameter_error_lines_(stderr, pe):
    _lines = __lines_for_parameter_error(pe.error_case, pe.payload_dictionary)
    for line in _lines:
        assert(_eol not in line)  # catch these early for now

        # before #history-A.5 we would put the raw line and the EOL in
        # two separate calls to `write` (think of the memory savings!);
        # but the "expect STD's" library we are now targeting wants us
        # to write only terminated lines for its reasons [#605.2]

        stderr.write(f"{line}{_eol}")

    stderr.write(Renderers_(pe.long_program_name).invite_line)


def __lines_for_parameter_error(error_case, dct):

    opt, arg, token_pos, tok = (None, None, None, None)
    dct = {k: v for k, v in dct.items()}
    if 'option' in dct:
        opt = dct.pop('option')
        opt_moniker = f"'--{opt.long_name}'"
    if 'argument' in dct:
        arg = dct.pop('argument')
        arg_moniker = __arg_moniker_via(arg.styled_moniker)
    if 'token_position' in dct:
        token_pos = dct.pop('token_position')
    if 'token' in dct:
        tok = dct.pop('token')
        tok_moniker = repr(tok)
    assert(not len(dct))  # get earliest possible warning that stuff is wrong
    mutable_words = error_case.split('_')

    if opt is not None:
        assert('option' == mutable_words[0])  # #here5
        mutable_words[0] = opt_moniker
    else:
        assert('option' != mutable_words[0])

    if arg is not None:
        assert(tok is None)
        mutable_words.append(arg_moniker)

    if token_pos is None and tok is not None:
        mutable_words[-1] = f"{mutable_words[-1]}:"  # ick/meh
        mutable_words.append(tok_moniker)

    yield f"parameter error: {' '.join(mutable_words)}"

    if token_pos is not None:
        from kiss_rdb.magnetics.string_scanner_via_string import (
                two_lines_of_ascii_art_via_position_and_line)
        for s in two_lines_of_ascii_art_via_position_and_line(token_pos, tok):
            yield s


def __arg_moniker_via(arg_name):
    import re
    _md = re.match(r'(?:(<)|([a-z])|([A-Z]))', arg_name)  # #here2
    has_less_than, is_lowcase, is_upcase = _md.groups()
    if has_less_than:
        return arg_name
    if is_lowcase:
        return f'<{arg_name}>'  # ..
    assert(is_upcase)
    return arg_name


class CLI_via_syntax_AST_:  # #testpoint

    def __init__(self, syntax_AST):
        # pre-compute things that can be pre-computed
        opts, args, req_opt_offsets = syntax_AST
        _two = _build_option_index(opts)
        self.opt_offset_via_short_name, self.opt_offset_via_long_name = _two
        self.sequence_grammar = tuple(_sequence_grammar_via_syntax_args(args))
        self.opts = opts
        self.args = args
        self.offsets_of_required_options = req_opt_offsets


def do_parse_(tox, CLI, listener, stop_ASAP=False):

    from .magnetics.parser_via_grammar import (
            parser_via_grammar_and_symbol_table,
            TokenScanner)

    inner_parser = parser_via_grammar_and_symbol_table(
        CLI.sequence_grammar, {
            'option': lambda: option_parsing,
            'argument': lambda: argument_parsing})

    def listener_for_inner_parse(*a):
        severity, shape, error_category, error_case, payloader = a
        assert('error' == severity)
        assert('structure' == shape)
        assert('parse_error' == error_category)

        if 'extra_input' == error_case:
            return when('unexpected_argument')  # (Case5449)

        if 'missing_required' == error_case:
            dct = payloader()
            i = dct['offset_in_grammar']
            assert(1 == i % 2)  # (Case5452)
            return when('expecting', argument=CLI.args[int(i/2)])

        assert(False)

    def main():

        # parse
        big_flat = inner_parser.parse(tox, listener_for_inner_parse, stop_ASAP)
        if big_flat is None:
            return  # (Case5442)

        # roll up big flat so it is in formal parameter order (Case5421)
        opts, args = __two_tuples_via_big_flat(big_flat, CLI.opts, CLI.args)

        # this crazy thing with required optionals
        if len(CLI.offsets_of_required_options):
            for i in CLI.offsets_of_required_options:
                if opts[i] is not None:
                    continue
                # #here5: must start with 'option'
                return when('option_is_required', option=CLI.opts[i])

        return opts, args

    # -- parsing the option expressions

    class option_parsing:  # #class-as-namespace

        def match_by_peek_as_subparser(_t):
            return token_looks_like_option(tox.peek)

        def parse_as_subparser(_t, _l):
            return parse_option()

    def parse_option():

        chars = TokenScanner(tox.peek)  # YIKES but it works well
        assert('-' == chars.shift())  # skip over first '-'
        assert(not chars.is_empty)

        tup = parse_formal_option(chars)
        if tup is None:
            return
        is_short, opt_offset = tup
        opt = CLI.opts[opt_offset]

        # does the formal option take an argument? parse accordingly for yes/no

        has_stuff_after = not chars.is_empty
        if opt.takes_argument:
            if has_stuff_after:
                if is_short:
                    wv = short_takes_arg_and_not_done_with_tok(chars)
                else:
                    wv = long_takes_arg_and_not_done_with_token(chars)
            else:
                wv = short_or_long_takes_arg_and_done_with_token(opt)
        elif has_stuff_after:
            if is_short:
                return parse_flagball(chars, opt_offset)
            return when('flag_option_must_have_nothing_after_it', chars)
        else:
            # is flag, formally and actually
            tox.advance()  # (Case5428)
            wv = (True,)  # #wrapped-AST-value # #option-value:for-flag
        if wv is None:
            return
        # unwrap the wrapped value to get the value. then re-wrap it crazily
        value, = wv
        # #option-value #option-slot-values #wrapped-AST-value
        return (((opt_offset, value),),)

    def parse_flagball(chars, opt_offset):
        # Multiple formal options can be in one token. It seems that other
        # parsers typically support the mixed-style where a jumble of short
        # flags can occur before one short-form arg-taking expression, all in
        # the same token. We intentionally do *not* support this form because
        # we find it aesthetically upsetting for a savings of only 2 chars.

        these = []  # #option-slot-values
        while True:
            these.append((opt_offset, True))  # #option-value:for-flag
            if chars.is_empty:  # never the first time
                break
            opt_offset = CLI.opt_offset_via_short_name.get(chars.peek, None)
            if opt_offset is None:
                return when('unrecognized_option', chars)  # (Case5480)
            if CLI.opts[opt_offset].takes_argument:
                return when(
                  'cannot_mix_flags_and_optional_arguments_in_one_token',
                  chars)  # (Case5477)
            chars.advance()
        tox.advance()
        return (these,)  # #wrapped-AST-value

    def long_takes_arg_and_not_done_with_token(chars):
        if '=' != chars.peek:
            return when('expecting_equals_sign', chars)  # (Case5424)
        chars.advance()  # (Case5428)
        if chars.is_empty:
            # suggest = if you want empty string, pass as separate token
            when('equals_sign_must_have_content_after_it', chars)
            return  # (Case5463)
        return flush_the_rest(chars)

    def short_takes_arg_and_not_done_with_tok(chars):
        return flush_the_rest(chars)  # #hi. (Case5431)

    def flush_the_rest(chars):
        tox.advance()
        return (chars.flush_the_rest(),)  # #wrapped-AST-value

    def short_or_long_takes_arg_and_done_with_token(opt):
        # as long: (Case5421)  when short: (Case5435)
        tox.advance()
        if tox.is_empty:
            when('option_requires_argument', option=opt)
            return  # (Case5456)
        tok = tox.peek
        if token_looks_like_option(tok):
            when('option_value_looks_like_option', option=opt)
            return  # (Case5470)
        tox.advance()
        return (tok,)  # #wrapped-AST-value

    def parse_formal_option(chars):
        # if the token starts with '--'..
        if '-' == chars.peek:
            chars.advance()

            # is the string after the "--" well-formed as an option name?
            md = long_name_rx.match(chars.tokens, pos=chars.pos)
            if md is None:
                # suggest expecting a-zA-Z0-9 etc
                return when('malformed_option_name', chars)  # (Case5438)
            long_name = md[0]
            _beg, end = md.span()

            # can you resolve a particular formal option from it?
            i = CLI.opt_offset_via_long_name.get(long_name, None)
            if i is None:
                return when('unrecognized_option')  # (Case5442)
            chars.advance_to_position(end)
            is_short = False
        else:
            # the token starts with '-' not '--' and is not "-"
            i = CLI.opt_offset_via_short_name.get(chars.peek, None)
            if i is None:
                return when('unrecognized_option')  # (Case5445)
            chars.advance()
            is_short = True
        return is_short, i

    import re
    long_name_rx = re.compile(_long_name_rxs)

    # -- parsing the argument expressions

    class argument_parsing:  # #class-as-namespace

        def match_by_peek_as_subparser(_t):
            return not token_looks_like_option(tox.peek)

        def parse_as_subparser(_t, _l):
            return (tox.shift(),)  # (Case5421)

    def token_looks_like_option(tok):
        leng = len(tok)
        if 0 == leng:
            return
        if '-' != tok[0]:
            return
        if 1 == leng:
            assert('-' == tok)
            return  # #todo not covered - pass thru dash as valid arg value
        return True

    # -- whiners

    def when(error_case, character_scanner=None, option=None, argument=None):
        def structer():
            dct = {}
            if option is not None:
                dct['option'] = option
            if argument is not None:
                dct['argument'] = argument
            if character_scanner is not None:
                tokens = character_scanner.tokens
                if character_scanner.is_empty:
                    use_pos = len(tokens)  # point at the spot after it (cov'd)
                else:
                    use_pos = character_scanner.pos
                dct['token'] = tokens
                dct['token_position'] = use_pos
            elif not tox.is_empty:
                dct['token'] = tox.peek
            return dct
        listener('error', 'structure', 'parameter_error', error_case, structer)
    return main()


def _build_option_index(opts):
    # associate every short name and every long name back to a formal option

    opt_offset_via_short_name = {}
    opt_offset_via_long_name = {}

    for i in range(0, len(opts)):
        opt = opts[i]
        s = opt.short_name
        if s is not None:
            assert(s not in opt_offset_via_short_name)  # ..
            opt_offset_via_short_name[s] = i
        s = opt.long_name
        assert(s not in opt_offset_via_long_name)  # ..
        opt_offset_via_long_name[s] = i

    return opt_offset_via_short_name, opt_offset_via_long_name


# == the trick with winding and unwinding the thing

def __two_tuples_via_big_flat(big_flat, opts, args):
    """`big_flat` is a tuple of the actual values whose structure matches

    the sequence grammar produced at #here3. Here we "decode" what was
    "encoded" there: re-arrange the actuals so they are in two tuples: one for
    options and one for arguments. (Both tuples have a length and structure
    derived from the user's formal params.)
    """

    actual_options = [None for _ in range(0, len(opts))]
    actual_arguments = []
    tuplize_these = []

    def see_actual_options(option_slots_values):
        if option_slots_values is None:
            return
        # one syntax can have many slots where expressions can go. each slot
        # can have many expressions of option value. so, loop inside loop.
        for option_slot_values in option_slots_values:  # #option-slot-values
            for opt_offset, value in option_slot_values:  # #option-value
                formal = opts[opt_offset]
                if formal.is_plural:
                    if formal.takes_argument:
                        if actual_options[opt_offset] is None:
                            actual_options[opt_offset] = []
                            tuplize_these.append(opt_offset)
                        actual_options[opt_offset].append(value)
                        continue
                    if actual_options[opt_offset] is None:
                        actual_options[opt_offset] = 0
                    actual_options[opt_offset] += 1
                    continue
                actual_options[opt_offset] = value

    def see_actual_argument(decoded_value):
        actual_arguments.append(decoded_value)  # hi.

    _ = __do_two_tuples_via_big_flat(big_flat, opts, args)
    do_this = {
            'actual_options': see_actual_options,
            'actual_argument': see_actual_argument,
            }
    for which, payload in _:
        do_this[which](payload)

    assert(len(actual_arguments) == len(args))

    for i in tuplize_these:
        actual_options[i] = tuple(actual_options[i])

    return tuple(actual_options), tuple(actual_arguments)


def __do_two_tuples_via_big_flat(big_flat, opts, args):  # see caller

    num_args = len(args)
    has_glob = args[-1].is_plural if num_args else False

    if has_glob:
        use_num_args = num_args - 1  # traversal stops before
    else:
        use_num_args = num_args

    use_num_terms = 1 + 2 * use_num_args  # exactly #here4

    if has_glob:
        assert(len(big_flat) == use_num_terms + 1)
    else:
        assert(len(big_flat) == use_num_terms)

    yield 'actual_options', big_flat[0]  # at least one per #here4

    for i in range(1, use_num_terms, 2):
        yield 'actual_argument', big_flat[i]
        yield 'actual_options', big_flat[i + 1]

    if not has_glob:
        return

    glob_value = big_flat[-1]
    sub_yield = []
    for arg_value_item, option_slot_values in (glob_value or ()):
        yield 'actual_options', option_slot_values
        sub_yield.append(arg_value_item)

    yield 'actual_argument', tuple(sub_yield)


def _sequence_grammar_via_syntax_args(args):
    """The bulk of this module's workload is concerned with realizing the

    client's target CLI syntax by encoding it into a "sequence grammar", then
    using that sequence grammar to parse user input, then taking the resulting
    AST and decoding it back into a structure that the client can recognize
    by associating actual values with formal parameters from the syntax.

    For a simple two-arg syntax, the sequence grammar we want is:
    `opt* arg1 opt* arg2 opt*`.

    (`*` (kleene-star) means "zero or more of the previous thing".)

    The sequence grammar is peppered with so many `opt*` terms (one at each
    outer boundary and one at each joint between positional arguments) so
    that we can parse options passed "anywhere" in the input: at the front,
    at the end, or between any two adjacent positional arguments.

    We can generalize this approach to all N-arg syntaxes with either:

        opt* (arg opt*){N}
    or
        (opt* arg){N} opt*

    We use the former just for better code narrative, so we ease-in to
    complexity.

    Our sequence grammar system does not have the ability to express that
    a grammatical term should be repeated some specific N number of times
    (because, in part, it's straightforward to write this out "by hand" (when
    you are writing your grammar by hand)).

    As such, essentially all we're doing here is taking some non-negative
    integer N and exploding it into a sequence grammar according to above.

    Note that even for a syntax of zero positional arguments, the generated
    sequence grammar will still have one `opt*` term. :#here4

    Syntaxes with a glob term (i.e plural, min zero or one, must be at end)
    are more complictaed. We introduced "sub-expressions" for this
    (at #history-A.6). This syntatical feature is expressed here as
    either `( arg opt* )+` or `( arg opt* )*`, at the end.
    """  # :#here3

    yield 'zero or more'
    yield 'option'
    if not len(args):
        return
    if args[-1].is_plural:
        *non_globs, glob = args
        has_glob = True
    else:
        non_globs = args
        has_glob = False
    for arg in non_globs:
        assert(arg.is_plural is False)
        yield 'one'
        yield 'argument'
        yield 'zero or more'
        yield 'option'
    if has_glob:
        if '*' == glob.arity_string:
            yield 'zero or more'
        else:
            assert('+' == glob.arity_string)
            yield 'one or more'
        yield '('
        yield 'one'
        yield 'argument'
        yield 'zero or more'
        yield 'option'
        yield ')'


# ==

def syntax_AST_via_parameters_definition_(tups):  # #testpoint
    opts, args, req_opt_offsets = __first_pass(tups)

    # check that any glob is in the right place
    leng = len(args)
    for i in range(0, leng):
        if not args[i].is_plural:
            continue
        if i == (leng - 1):
            break
        _ = args[i].formal_name
        _msg = f"plural positional args can only occur at the end: '{_}'"
        raise FormalParametersSyntaxError(_msg)

    return opts, args, req_opt_offsets


def __first_pass(tups):

    from .magnetics.parser_via_grammar import (
        parser_via_grammar_and_symbol_table,
        TokenScanner)

    parser = parser_via_grammar_and_symbol_table(
            ('zero or more', 'option',
             'zero or more', 'argument'),
            {'option': lambda: FormalOptionParser(),
             'argument': lambda: FormalPositionalArgumentParser()})

    class Crazee:
        def __init__(self):
            self._parser = None

        def parse_as_subparser(self, tox, listener):
            _subtox = TokenScanner(tox.peek)
            x = self.parser.parse(_subtox, listener)
            if x is None:
                return
            tox.advance()
            return (x,)

        @property
        def parser(self):
            if self._parser is None:
                self._parser = self.build_parser()
            return self._parser

    class FormalOptionParser(Crazee):

        def match_by_peek_as_subparser(self, tox):
            first_token = tox.peek[0]  # it's a matrix of strings
            if looks_like_short_rx.match(first_token):
                return True
            return looks_like_long_rx.match(first_token)

        def build_parser(self):
            return parser_via_grammar_and_symbol_table(
                ('any', 'short', 'one', 'long', 'one or more', 'desc'),
                {'short': lambda: formal_short_parser,
                 'long': lambda: formal_long_parser,
                 'desc': lambda: desc_parser})

    class FormalPositionalArgumentParser(Crazee):

        def match_by_peek_as_subparser(self, tox):
            return formal_positional_arg_name_head_rx.match(tox.peek[0])

        def build_parser(self):
            return parser_via_grammar_and_symbol_table(
                ('one', 'arg name', 'one or more', 'desc'),
                {'arg name': lambda: arg_name_parser,
                 'desc': lambda: desc_parser})

    class formal_short_parser:

        def match_by_peek_as_subparser(tox):
            return looks_like_short_rx.match(tox.peek)

        def parse_as_subparser(tox, listener):
            return (formal_short_rx.match(tox.shift())[1],)  # ..

    class formal_long_parser:

        def match_by_peek_as_subparser(tox):
            return looks_like_long_rx.match(tox.peek)

        def parse_as_subparser(tox, listener):
            md = formal_long_rx.match(tox.peek)
            if md is None:
                _ = f'long option has invalid character(s): {repr(tox.peek)}'
                raise FormalParametersSyntaxError(_)
            tox.advance()
            return (md.groups(),)

    class arg_name_parser:

        def match_by_peek_as_subparser(tox):
            return formal_positional_arg_name_head_rx.match(tox.peek[0])

        def parse_as_subparser(tox, listener):
            md = formal_positional_arg_name_rx.match(tox.peek)
            if md is None:
                _ = f'argument name has invalid character(s): {repr(tox.peek)}'
                raise FormalParametersSyntaxError(_)
            tox.advance()
            return ((md[1], md[2]),)  # #NT_formal_positional_arg

    class desc_parser:  # #class-as-namespace

        def match_by_peek_as_subparser(tox):
            return looks_like_desc_rx.match(tox.peek)

        def parse_as_subparser(tox, _listener):
            return (tox.shift(),)  # #wrapped-AST-value

    import re
    o = re.compile
    looks_like_short_rx = o('-[a-zA-Z]')
    formal_short_rx = o('-([a-zA-Z])$')
    looks_like_long_rx = o('--[a-z][-a-z]')  # ..
    formal_long_rx = o(f'--({_long_name_rxs})(?:=([_A-Z]+))?([*!])?$')
    looks_like_desc_rx = o('[a-zA-Z(«]')  # ..
    formal_positional_arg_name_head_rx = o('[a-zA-Z<]')

    lowcase = '[a-z][a-z0-9]*'
    upcase = '[A-Z][A-Z0-9]*'

    # == BEGIN :#here2:
    _A = f'<{lowcase}(?:-{lowcase})*>'
    _B = f'{upcase}(?:_{upcase})*'
    _C = f'{lowcase}(?:-{lowcase})*'  # might deprecate

    formal_positional_arg_name_rx = o(fr'({_A}|{_B}|{_C})([*+])?$')
    # #NT_formal_positional_arg
    # == END

    from modality_agnostic import listening
    listener = listening.throwing_listener

    req_opt_offsets = []

    opts, args = parser.parse(TokenScanner(tups), listener)

    a = []
    for opt_parts in (opts or ()):
        short_name, (long_name, meta_var, arity_string), descs = opt_parts
        formal = FormalOption_(
                short_name, long_name, meta_var, arity_string, descs)
        if formal.is_required:
            req_opt_offsets.append(len(a))
        a.append(formal)
    opts = tuple(a)

    args = tuple(_FormalArgument(*arg_parts) for arg_parts in (args or ()))

    return opts, args, req_opt_offsets


class FormalOption_:

    def __init__(self, short_name, long_name, meta_var, arity_string, descs):

        if arity_string is None:
            self.is_plural = False
        elif '*' == arity_string:
            # arg-taking form ok, flag form ok
            self.is_plural = True
        else:
            assert('!' == arity_string)
            if meta_var is None:
                _msg = (f"'!' cannot be used on flags, only optional fields "
                        f"('--{long_name}')")
                raise FormalParametersSyntaxError(_msg)
            self.is_required = True
            self.is_plural = False

        if short_name is not None:
            assert(1 == len(short_name))

        self.short_name = short_name
        self.long_name = long_name
        self.meta_var = meta_var
        self.arity_string = arity_string
        self.description_lines = descs

    @property
    def takes_argument(self):
        return self.meta_var is not None  # meh

    is_required = False


class _FormalArgument:

    def __init__(self, styled_moniker_and_arity, descs):  # ..
        self.styled_moniker, self.arity_string = styled_moniker_and_arity

        if self.arity_string is None:
            self.is_plural = False
        else:
            assert self.arity_string in ('+', '*')
            self.is_plural = True

        # #NT_formal_positional_arg
        self.description_lines = descs

    @property
    def formal_name(self):
        if self.arity_string is None:
            return self.styled_moniker
        return f"{self.styled_moniker}{self.arity_string}"


_long_name_rxs = '[a-z]+(?:-[a-z0-9]+)*'


def cover_me(msg):
    raise Exception(f"cover me: {msg}")


class FormalParametersSyntaxError(Exception):
    pass


_eol = '\n'


# #history-A.7: sunsetted last traces of stepper
# #history-A.6: sub-expressions
# #history-A.5: expose API for "cheap arg parse branch"
# #history-A.4: help & initial integration
# #history-A.3: begin parser-generator-backed rewrite of "cheap arg parse"
# #history-A.2: MASSIVE exodus
# #history-A.1: as referenced (can be temporary)
# #born.
