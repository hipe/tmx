"""this is the next level up from "fixed argument parser"..

you want to use this magnetic directly if you want to build your argument
parser from modality agnostic commands, but otherwise manage your own
parsing.
"""

from modality_agnostic.memoization import lazy
import re


_THIS_NAME = 'chosen_sub_command'


def cheap_arg_parse(CLI_function, stdin, stdout, stderr, argv,
                    formal_parameters, description_template_valueser=None):
    """
    NOTE This is still highly experimental: it is almost guaranteed that the
    API will change (in terms of both function signatures and the exposed
    function constituency). #history-A.4 was an overhaul of this method to add
    support for parsing arbitrary options and (non-globbing) positional
    arguments. Its exit criteria was only that the many involved producer
    scripts continued to work as they did. #here marks new API experiments or
    places where we carry over some weaknesses from the previous code.
    """

    _syntax_AST = _syntax_AST_via_parameters_definition(formal_parameters)
    CLI = _CLI_via_syntax_AST(_syntax_AST)

    tox = _parse_lib().TokenScanner(argv)
    long_program_name = tox.shift()

    state = _InvocationState()

    @state.lazy_reader
    def program_name():
        from os import path as os_path
        return os_path.basename(long_program_name)

    @state.lazy_method_receiver
    def business_listener():  # ##here only 'expression' not 'structure'
        from script_lib import (
                build_simple_business_listener_for_case_expression__)
        return build_simple_business_listener_for_case_expression__(stderr)

    def listener_for_parse_errors(*a):
        sev, shape, cat, error_case, structurer = a
        assert((sev, shape, cat) == ('error', 'structure', 'parameter_error'))

        # catching help this way has some benefits but is mostly a hack
        if ('unrecognized_option' == error_case and
                structurer()['token'] in ('-h', '--help')):
            __write_help_lines(stderr, description_template_valueser,
                               CLI_function, state.program_name(), CLI)
            state.exitstatus = 0
            return

        for line in _express_parameter_error(state, error_case, structurer):
            stderr.write(line)
            stderr.write('\n')
        stderr.write(f"see '{state.program_name()} --help'\n")

    two = _do_parse(tox, CLI, listener_for_parse_errors)
    if two is None:
        return state.exitstatus
    opt_vals, arg_vals = two

    from modality_agnostic import listening
    ErrorMonitor = listening.ErrorMonitor

    es = CLI_function(ErrorMonitor(state.business_listener),  # #here
                      stdin, stdout, stderr, *opt_vals, *arg_vals)
    assert(isinstance(es, int))  # #[#022]
    return es


class _InvocationState:  # [#503.11] blank slate, plus one thing

    def lazy_method_receiver(self, f):  # #[#510.6] experimental
        def use_f(*a):
            return getattr(self, method_reader_method_name)()(*a)
        method_reader_method_name = f'{f.__name__}_method'
        self._add_lazy_reader(method_reader_method_name, f)
        setattr(self, f.__name__, use_f)

    def lazy_reader(self, f):  # #[#510.6] experimental
        self._add_lazy_reader(f.__name__, f)

    def _add_lazy_reader(self, method_name, f):
        def use_f():
            if not hasattr(self, attr):
                setattr(self, attr, f())
            return getattr(self, attr)
        attr = f'_{method_name}'
        setattr(self, method_name, use_f)


def __write_help_lines(stderr, description_template_valueser,
                       CLI_function, program_name, CLI):

    from script_lib.magnetics.listener_via_resources import (
            desc_lineser_via, help_lines)

    _descser = desc_lineser_via(description_template_valueser, CLI_function)

    for line in help_lines(program_name, _descser, CLI.opts, CLI.args):
        stderr.write('\n' if line is None else f'{line}\n')


def _express_parameter_error(state, error_case, structurer):
    # cases covered visually: (Case5470) (Case5470) (Case5424) (Case5438)
    # (Case5459) (Case5463) (Case5480) (Case5484) (Case5442) (Case5445)
    # (Case5449) (Case5452) (Case5456)

    opt, arg, token_pos, tok = (None, None, None, None)
    dct = structurer()
    dct = {k: v for k, v in dct.items()}
    if 'option' in dct:
        opt = dct.pop('option')
        opt_moniker = f"'--{opt.long_name}'"
    if 'argument' in dct:
        arg = dct.pop('argument')
        arg_moniker = f"<{arg.name}>"  # ..
    if 'token_position' in dct:
        token_pos = dct.pop('token_position')
    if 'token' in dct:
        tok = dct.pop('token')
        tok_moniker = repr(tok)
    assert(not len(dct))  # get earliest possible warning that stuff is wrong
    mutable_words = error_case.split('_')

    if opt is not None:
        assert('option' == mutable_words[0])
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
        from kiss_rdb.magnetics_.string_scanner_via_definition import (
                two_lines_of_ascii_art_via_position_and_line)
        for s in two_lines_of_ascii_art_via_position_and_line(token_pos, tok):
            yield s

    state.exitstatus = 456


def _init_CLI(o, syntax_AST):
    # pre-compute things that can be pre-computed
    o.opts, o.args = syntax_AST
    _ = __build_option_index(o.opts)
    o.opt_offset_via_short_name, o.opt_offset_via_long_name = _
    o.sequence_grammar = tuple(__sequence_grammar_via_syntax_args(o.args))


class _CLI_via_syntax_AST:  # #testpoint
    __init__ = _init_CLI


# #refo [#608.K] you could eliminate (at writing) all `lazy` here (look)

class argument_parser_index_via:
    """a collection of commands is passed over the transation boundary

    as a stream (actually iterator), streams being the lingua franca for
    collections passed over transactional boundaries. however it's more
    convenient to have this collection be in a dictionary after the work
    is done of building the argument parser..
    """

    def __init__(self, stderr, prog, command_stream, description_string):

        ap = _argument_parser_via(stderr, prog, description=description_string)

        self.command_dictionary = _populate_via_command_stream(
                stderr, ap, command_stream)
        self.argument_parser = ap

    this_one_name__ = _THIS_NAME


def _populate_via_command_stream(stderr, ap, command_stream):

    d = {}
    subparsers = ap.add_subparsers(dest=_THIS_NAME)
    for cmd in command_stream:
        k = cmd.name
        if k in d:
            _msg = "name collision - multiple commands named '%s'"
            cover_me(_msg % k)
        d[k] = cmd
        __populate_via_command(subparsers, stderr, cmd)
    return d


def __populate_via_command(subparsers, stderr, cmd):

    desc_s = _element_description_string_via_mixed(cmd.description)
    if desc_s is None:
        _tmpl = "«desc for subparser (place 2) '{}'»\nline 2"
        desc_s = _tmpl.format(cmd.name)

    ap = subparsers.add_parser(
        _slug_via_name(cmd.name),
        description=desc_s,
        add_help=False,
        help='«help for command»',  # `add_help = False` 🤔
    )
    _hack_argument_parser(ap, stderr)

    _populate_via_parameter_dictionary(
        parser=ap,
        parameter_dictionary=cmd.formal_parameter_dictionary,
        )


def argument_parser_via_parameter_dictionary__(
        stderr, prog, parameter_dictionary, **platform_kwargs):

    description = platform_kwargs['description']  # no prisoners

    desc_s = _element_description_string_via_mixed(description)
    if desc_s is None:
        desc_s = '«DUMMY DESC FOR NEW THING»'

    platform_kwargs['description'] = desc_s

    ap = _argument_parser_via(stderr, prog, **platform_kwargs)
    _populate_via_parameter_dictionary(ap, parameter_dictionary)
    return ap


class _populate_via_parameter_dictionary:

    def __init__(self, parser, parameter_dictionary):

        self._parser = parser
        self._count_of_positional_args_added = 0

        for name in parameter_dictionary:
            self.__add_parameter(parameter_dictionary[name], name)

    def __add_parameter(self, param, name):
        """[#502] discusses different ways to conceive of parameters ..

        in terms of ther argument arity. here we could either follow the
        "lexicon" (`is_required`, `is_flag`, `is_list`) or the numbers. we
        follow the numbers for no good reason..
        """

        r = param.argument_arity_range
        min = r.start
        max = r.stop
        if min is 0:
            if max is 0:
                self.__add_flag(param, name)
            elif max is 1:
                self.__add_optional_field(param, name)
            else:
                assert(max is None)
                self.__add_optional_list(param, name)
        else:
            assert(1 == min)
            if max is 1:
                self.__add_required_field(param, name)
            else:
                assert(max is None)
                self.__add_required_list(param, name)

    def __add_required_field(self, param, name):
        """purely from an interpretive standpoint, we could express any number..

        of required fields as positional arguments when as a CLI command.
        HOWEVER from a usability standpoint, as an #aesthetic-heuristic
        we'll say experimentally that THREE is the max number of positional
        arguments a command should have.
        """

        if 3 > self._count_of_positional_args_added:
            self._count_of_positional_args_added += 1
            self.__do_add_required_field(param, name)
        else:
            cover_me('many required fields')

    def __add_required_list(self, param, name):  # category 5
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name),
            nargs='+',
            # action = 'append', ??
        )

    def __do_add_required_field(self, param, name):  # category 4
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name))

    def __add_optional_list(self, param, name):  # category 3
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name),
            nargs='*',
            # action = 'append', ??
        )

    def __add_optional_field(self, param, name):  # category 2
        self._parser.add_argument(
            (_DASH_DASH + _slug_via_name(name)),
            ** self._common_kwargs(param, name),
            metavar=_infer_metavar_via_name(name),
        )

    def __add_flag(self, param, name):  # category 1
        self._parser.add_argument(
            (_DASH_DASH + _slug_via_name(name)),
            ** self._common_kwargs(param, name),
            action='store_true',  # this is what makes it a flag
        )

    def _common_kwargs(self, param, name):

        s = param.generic_universal_type
        if s is not None:
            implement_me()

        d = {}
        s = _element_description_string_via_mixed(param.description)
        if s is None:
            s = "«the '{}' parameter»".format(name)

        d['help'] = s
        return d


#
# argument parser (build with functions not methods, expermentally)
#


def _CLI_parser_function_via_syntax_AST(syntax_AST):  # #testpoint

    # pre-compute things that can be pre-computed
    o = _CLI()
    o.opts, o.args = syntax_AST
    _ = __build_option_index(o.opts)
    o.opt_offset_via_short_name, o.opt_offset_via_long_name = _
    o.sequence_grammar = tuple(__sequence_grammar_via_syntax_args(o.args))

    def parse(token_scanner, listener):
        return _do_parse(token_scanner, o, listener)

    return parse


class _CLI:  # #[#510.2] blank state
    pass


def _do_parse(tox, CLI, listener):  # #testpoint

    inner_parser = _parse_lib().parser_via_grammar_and_symbol_table(
        CLI.sequence_grammar, {
            'option': lambda: option_parsing,
            'argument': lambda: argument_parsing})

    def inner_parser_listener(*a):
        *severity_shape_categ, error_case, structurer = a
        assert(severity_shape_categ == ['error', 'structure', 'parse_error'])
        if 'missing_required' == error_case:
            i = structurer()['offset_in_grammar']
            assert(1 == i % 2)  # (Case5452)
            return when('expecting', argument=CLI.args[int(i/2)])
        if 'extra_input' == error_case:
            return when('unexpected_argument')  # (Case5449)
        assert(False)

    def main():
        big_flat = inner_parser.parse(tox, inner_parser_listener)
        if big_flat is None:
            return  # (Case5442)
        # roll up big flat so it is in formal parameter order (Case5421)
        return __two_tuples_via_big_flat(big_flat, CLI.opts, CLI.args)

    # -- parsing the option expressions

    class option_parsing:  # #class-as-namespace

        def match_by_peek_as_subparser(_t):
            return token_looks_like_option(tox.peek)

        def parse_as_subparser(_t, _l):
            return parse_option()

    def parse_option():

        chars = _parse_lib().TokenScanner(tox.peek)  # YIKES but it works well
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
            wv = (True,)  # #wrapped-AST-value
        if wv is None:
            return
        # unwrap the wrapped value to get the value. then re-wrap it crazily
        value, = wv
        # #option-value #options-values-term #wrapped-AST-value
        return (((opt_offset, value),),)

    def parse_flagball(chars, opt_offset):
        # Multiple formal options can be in one token. It seems that other
        # parsers typically support the mixed-style where a jumble of short
        # flags can occur before one short-form arg-taking expression, all in
        # the same token. We intentionally do *not* support this form because
        # we find it aesthetically upsetting for a savings of only 2 chars.

        these = []  # #options-values-term
        while True:
            these.append((opt_offset, True))  # #option-value
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
            _wish('dash as valid positional argument value')
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


def __build_option_index(opts):
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

    num_args = len(args)
    actual_options = [None for _ in range(0, len(opts))]
    actual_arguments = [None for _ in range(0, num_args)]

    i = 0
    stop_here = 2 * num_args
    arg_offset = -1  # BE CAREFUL

    while True:
        options_values_terms = big_flat[i]
        if options_values_terms is not None:
            # #options-values-term
            for options_values_term in options_values_terms:
                for opt_offset, value in options_values_term:  # #option-value
                    if opts[opt_offset].is_plural:
                        _wish('plurals (1/2)')
                    else:
                        actual_options[opt_offset] = value
        if stop_here == i:
            break
        i += 1
        arg_offset += 1
        value = big_flat[i]
        if args[arg_offset].is_plural:
            _wish('plurals (2/2)')
        else:
            actual_arguments[arg_offset] = value
        i += 1

    return tuple(actual_options), tuple(actual_arguments)


def __sequence_grammar_via_syntax_args(args):

    # "flatten" the syntax so we can use our sequence grammar. For a two-arg
    # syntax, the grammar is `opt* arg1 opt* arg2 opt*` and so on. For an N-
    # arg syntax

    for s_a in __sequence_grammar_via_syntax_args_pcs(args):
        for s in s_a:
            yield s


def __sequence_grammar_via_syntax_args_pcs(args):
    yield 'zero or more', 'option'
    for _ in range(0, len(args)):
        yield 'one', 'argument', 'zero or more', 'option'  # ..

# ==


def _syntax_AST_via_parameters_definition(tups):  # #testpoint
    parse_lib = _parse_lib()
    build_parser = parse_lib.parser_via_grammar_and_symbol_table

    parser = build_parser(
            ('zero or more', 'option',
             'zero or more', 'argument'),
            {'option': lambda: FormalOptionParser(),
             'argument': lambda: FormalPositionalArgumentParser()})

    class Crazee:
        def __init__(self):
            self._parser = None

        def parse_as_subparser(self, tox, listener):
            _subtox = parse_lib.TokenScanner(tox.peek)
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
            return build_parser(
                ('any', 'short', 'one', 'long', 'one or more', 'desc'),
                {'short': lambda: formal_short_parser,
                 'long': lambda: formal_long_parser,
                 'desc': lambda: desc_parser})

    class FormalPositionalArgumentParser(Crazee):

        def match_by_peek_as_subparser(self, tox):
            return multi_purpose_rx.match(tox.peek[0])  # BE CAREFUL

        def build_parser(self):
            return build_parser(
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
            return (formal_long_rx.match(tox.shift()).groups(),)  # ..

    class arg_name_parser:

        def match_by_peek_as_subparser(tox):
            return multi_purpose_rx.match(tox.peek[0])  # BE CAREFUL

        def parse_as_subparser(tox, listener):
            return (formal_arg_name_rx.match(tox.shift())[0],)  # ..

    class desc_parser:  # #class-as-namespace

        def match_by_peek_as_subparser(tox):
            return looks_like_desc_rx.match(tox.peek)

        def parse_as_subparser(tox, _listener):
            return (tox.shift(),)  # #wrapped-AST-value

    looks_like_short_rx = re.compile('-[a-z]')
    formal_short_rx = re.compile('-([a-z])$')
    looks_like_long_rx = re.compile('--[a-z][-a-z]')  # ..
    formal_long_rx = re.compile(f'--({_long_name_rxs})(?:=([_A-Z]+))?$')
    looks_like_desc_rx = re.compile('[a-zA-Z]')
    multi_purpose_rx = re.compile('[a-z]')
    formal_arg_name_rx = re.compile('[a-z][a-z0-9]*(?:-[a-z0-9]+)*$')

    from modality_agnostic import listening
    listener = listening.throwing_listener

    opts, args = parser.parse(parse_lib.TokenScanner(tups), listener)
    if opts is None:
        opts = ()
    else:
        opts = tuple(FormalOption_(*opt_parts) for opt_parts in opts)

    if args is None:
        args = ()
    else:
        args = tuple(_FormalArgument(*arg_parts) for arg_parts in args)

    return opts, args


def _argument_parser_via(stderr, prog, **platform_kwargs):

    ap_lib = _ap_lib()
    ap = ap_lib.begin_native_argument_parser_to_fix__(
        prog=prog,
        **platform_kwargs
        )
    _hack_argument_parser(ap, stderr)
    return ap


class FormalOption_:

    def __init__(self, any_short_name, long_two, descs):
        self.short_name = any_short_name
        self.long_name, self.meta_var = long_two
        self.description_lines = descs

    @property
    def takes_argument(self):
        return self.meta_var is not None  # meh

    is_plural = False


class _FormalArgument:

    def __init__(self, name, descs):  # ..
        self.name = name
        self.description_lines = descs

    is_plural = False


def _element_description_string_via_mixed(x):

    if callable(x):
        desc_s = _string_via_description_function(x)
    elif type(x) is str:
        desc_s = x
    elif x is None:
        desc_s = None
    else:
        cover_me('command desc as {}'.format(type(x)))
    return desc_s


def _string_via_description_function(lineser):

    # FRONTIER of how to support passing a [#511.4] styler to a linser

    import inspect
    if len(inspect.signature(lineser).parameters):
        def use_lineser():
            return lineser(STYLER_)
        from script_lib.magnetics import STYLER_
    else:
        use_lineser = lineser
    return ''.join(use_lineser())


def _hack_argument_parser(ap, stderr):

    ap_lib = _ap_lib()
    ap_lib.fix_argument_parser__(ap, stderr)


def _infer_metavar_via_name(name):
    """given an optional field named eg. "--important-file", name its

    argument moniker 'FILE' rather than'IMPORTANT_FILE'
    """

    return __the_infer_metavar_via_name_function()(name)


@lazy
def __the_infer_metavar_via_name_function():
    regex = re.compile('[^_]+$')

    def f(name):
        return regex.search(name)[0].upper()
    return f


_long_name_rxs = '[a-z]+(?:-[a-z0-9]+)*'


def _slug_via_name(name):
    return name.replace('_', '-')  # UNDERSCORE, DASH


def _ap_lib():
    import script_lib.magnetics.fixed_argument_parser_via_argument_parser as x
    return x


def _parse_lib():
    from . import parser_via_grammar as parse_lib
    return parse_lib


@lazy
def _():
    # #wish [#008.E] gettext uber alles
    from gettext import gettext as g

    def f(s):
        return g(s)
    return f


def _wish(s):
    raise Exception(f'future feature expected here: {s}')


def implement_me():
    raise _exe('implement me')


def cover_me(msg):
    raise _exe(f'cover me: {msg}')


_exe = Exception

_DASH_DASH = '--'
_NEWLINE = '\n'

# #pending-rename: to "cheap arg parse" or something
# #history-A.4: help & initial integration
# #history-A.3: begin parser-generator-backed rewrite of "cheap arg parse"
# #history-A.2: MASSIVE exodus
# #history-A.1: as referenced (can be temporary)
# #born.
