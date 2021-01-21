import re


def cheap_arg_parse_branch(sin, sout, serr, argv, cx, descsr=None, efx=None):
    # Trying to be exemplary (if you need to roll your own)

    bash_argv = list(reversed(argv))
    long_program_name = bash_argv.pop()

    def prog_name():
        return _shorten_long_program_name(long_program_name)

    def formals():
        yield '-h', '--help', 'This screen'
        yield '<command> [..]', "One of the below"

    # Marrying the prog_name to the formals lets it emit and invite ~15 errors
    foz = formals_via_definitions(formals(), prog_name, lambda: cx)

    vals, es = foz.nonterminal_parse(serr, bash_argv)
    if vals is None:
        return es

    # Help is here rather than deeper so we can pass trivially complicated doc
    if vals.get('help'):
        for line in foz.help_lines(doc=None):
            serr.write(line)
        return 0

    # The Ultra-Sexy Mounting of an Alternation Component:
    cmd_tup = vals.pop('command')  # our grammar specifies at least one
    cmd_name, cmd_funcer, es = foz.parse_alternation_fuzzily(serr, cmd_tup[0])
    if not cmd_name:
        return es

    ch_pn = ' '.join((prog_name(), cmd_name))  # we don't love it, but later
    ch_argv = (ch_pn, * cmd_tup[1:])

    es = cmd_funcer()(sin, sout, serr, ch_argv, efx)
    assert isinstance(es, int)
    return es


def cheap_arg_parse(do_CLI, sin, sout, serr, argv, formals,
                    efx=None, description_valueser=None):
    bash_argv = list(reversed(argv))
    long_program_name = bash_argv.pop()

    def prog_name():
        return _shorten_long_program_name(long_program_name)

    foz = formals_via_definitions(formals, prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        for line in foz.help_lines(do_CLI.__doc__, description_valueser):
            serr.write(line)
        return 0

    opts, args = foz.sparse_tuples_in_grammar_order_via_consume_values(vals)
    flat = (sin, sout, serr, *opts, *args, efx)
    return do_CLI(*flat)


def require_interactive(stderr, stdin, argv):
    if stdin.isatty():
        return True
    w = stderr.write
    w("usage error: cannot read from STDIN.\n")
    w(_invite_line(argv[0]))


def _shorten_long_program_name(long_program_name):
    pcs = long_program_name.split(' ')
    from os.path import basename
    pcs[0] = basename(pcs[0])
    return ' '.join(pcs)


def _flatten_vals(foz, vals):
    these = {fo.key: None for fo in foz.formal_options}
    these.pop('help', None)  # typically not exists only in tests (Case5495)
    opts = tuple(vals.pop(k, None) for k in these.keys())
    pop_positional_value = _positional_popper(vals)
    args = tuple(pop_positional_value(fo) for fo in foz.formal_positionals)
    assert not vals
    return opts, args


def _positional_popper(vals):
    def pop_positional_value(fo):
        if fo.is_singular:
            if fo.is_optional:
                return vals.pop(fo.key, None)
            return vals.pop(fo.key)
        assert fo.is_plural
        if fo.is_optional:
            x = vals.pop(fo.key, ())  # maybe didn't reach #here8. (Case5486)
        else:
            xx('case woh')
            x = vals.pop(fo.key)
        assert isinstance(x, tuple)
        return x
    return pop_positional_value


# == Parse Child Command, Nonterminal Parse & Terminal Parse

def _parse_alternation_fuzzily(foz, serr, arg_slug):
    matches = []
    rx = re.compile(''.join(('^', re.escape(arg_slug))))
    for slug, func in foz.childrener():
        if arg_slug == slug:
            return slug, func, None
        if rx.match(slug):
            matches.append((slug, func))

    if 1 == (leng := len(matches)):
        return (* matches[0], None)

    if 0 == leng:
        serr.write(f'Unrecognized command "{arg_slug}". {foz.invite_line}')
        return None, None, 9  # #here4
    assert 1 < leng
    _ = _ox().oxford_OR(_ox().keys_map(k for k, _ in matches))
    serr.write(f'Ambiguous command "{arg_slug}". Did you mean {_}?\n')
    return None, None, 10  # #here4


def _nonterminal_parse(foz, bash_argv):
    # This algorithm is useful for branch nodes that have children but
    # perhaps parse global options before control is passed to children

    # First, parse all contiguous, head-anchored options. Fail on any unrecog.
    assert not foz.offsets_of_required_quote_unquote_options  # no use case
    parse_option = _build_option_parser(vals := {}, bash_argv, foz)
    while len(bash_argv) and (md := re.match('^-(.)', bash_argv[-1])):
        parse_option(md[1])
    if vals.get('help'):  # #here1
        return vals, None
    # Then, parse contiguous positionals only according to your formals
    _parse_contiguous_positionals(vals, bash_argv, foz.formal_positionals)
    return vals, None


def _passive_parse(foz, serr, bash_argv):
    """EXPERIMENTAL. consume contiguous recognized options archored to ARGV
    head, stopping at first positional-looking arg, unrecognized option-looking
    arg, or the end. The only way for this to fail is if an invoked, recognized
    option has syntax errors.
    """

    if len(foz.formal_positionals):
        raise DefinitionError_("no positionals in formals of passive parse")

    vals, stop = {}, None
    parse_option = _build_option_parser(vals, bash_argv, foz, be_passive=True)
    try:
        while len(bash_argv) and (md := re.match('^-(.)', bash_argv[-1])):
            x = parse_option(md[1])
            if x is not None:
                assert '_passive_stop_' == x
                break
    except _Stop as e:
        stop = e
    if stop:
        return _write_stop_into(serr, foz, *stop.args)
    return vals, None


def _terminal_parse(foz, bash_argv):
    # This is the more familiar algorithm where options can be interspersed
    # with arguments but we have to parse all the way to the end of the input

    vals, contiguous_actual_positionals = {}, []
    parse_option = _build_option_parser(vals, bash_argv, foz)
    while len(bash_argv):
        if (md := re.match('^-(.)', bash_argv[-1])):
            parse_option(md[1])
            continue
        contiguous_actual_positionals.append(bash_argv.pop())
    if vals.get('help'):  # #here1
        return vals, None
    if (ofs := foz.offsets_of_required_quote_unquote_options):  # (Case5495)
        fos = tuple(foz.formal_options[i] for i in ofs)
        if (missing := tuple(fo for fo in fos if fo.key not in vals)):
            these = _ox().oxford_AND(_ox().keys_map(fo.long for fo in missing))
            are = 'is' if 1 == len(missing) else 'are'
            raise _Stop(f"{these} {are} required", 7)
    bash_argv = list(reversed(contiguous_actual_positionals))
    _parse_contiguous_positionals(vals, bash_argv, foz.formal_positionals)
    if len(bash_argv):
        raise _Stop(f"Unexpected argument: {repr(bash_argv[-1])}", 8)
    return vals, None


def _stop_and_invite(orig_f):
    def use_f(foz, serr, bash_argv):
        try:
            return orig_f(foz, bash_argv)
        except _Stop as stop:
            return _write_stop_into(serr, foz, *stop.args)
    return use_f


def _write_stop_into(serr, foz, msg, exitstatus):
    if len(msg) < 40:  # to the bane of tests
        serr.write(f'{msg}. {foz.invite_line}')
    else:
        serr.write(f'{msg}\n')
        serr.write(foz.invite_line)
    return None, exitstatus


def _parse_contiguous_positionals(values, bash_argv, faz):
    special = None  # only ever zero or one special, and must be at end #here3
    minus_one = (end := len(faz)) - 1
    if end and faz[minus_one].is_special:
        special = faz[(end := minus_one)]

    # Parse off the simple arguments
    for fo in (faz[i] for i in range(0, end)):
        assert fo.is_singular and fo.is_required  # again because #here3
        if not len(bash_argv):
            raise _Stop(f"Expecting {fo.moniker}", 5)  # #here5
        values[fo.key] = bash_argv.pop()

    # If there are no special formals, you're done passive-parsing arguments
    if not special:
        return

    # If there are no more actual arguments, what happens depends on formals..
    if not len(bash_argv):
        # Requirement is checked in same way regardless of arity. (U need >= 1)
        if special.is_required:  # (Case5643)
            raise _Stop(f"Expecting {special.moniker}", 6)  # #here5
        return  # nothing to do. no writing, no failure

    if special.is_plural:
        values[special.key] = tuple(reversed(bash_argv))  # #here8
        bash_argv.clear()
        return

    values[special.key] = bash_argv.pop()


def _build_option_parser(values, bash_argv, foz, be_passive=False):

    def parse_option(char):
        tok = bash_argv[-1]
        if '-' == char:
            return parse_long(tok)
        else:
            return parse_short(tok)

    def parse_long(tok):
        stem = (md := re.match('--([^=]*)(?:=(.*))?$', tok))[1]
        if (i := offset_via_long_stem.get(stem)) is None:
            if be_passive:
                return passive_stop
            return no(f"Unrecognized option '--{stem}'", 11)
        if (fo := formal_options[i]).takes_argument:
            return parse_long_that_takes_argument(md, fo)
        if md[2] is not None:
            return no(f'{fo.long} does not take an argument', 12)
        fo.set_or_increment_value(values)
        if 'help' == fo.key:
            return bash_argv.clear()  # #here1
        bash_argv.pop()

    def parse_long_that_takes_argument(md, fo):
        if (val := md[2]) is not None:
            if 0 == len(val):  # (Case5463)
                return no(f"Equals sign must have content after it: '{fo.long}='", 13)  # noqa: E501
            bash_argv.pop()
            return fo.set_or_append_value(values, val)
        fo.set_or_append_value(values, parse_value(fo, 'long'))

    def parse_short(tok):  # we call this a "ball" of options
        if (fo := any_fo_via_char(tok[1])) is None:
            return try_to_parse_custom(tok)
        if fo.takes_argument:
            return parse_short_that_takes_argument(fo, tok)
        bash_argv.pop()  # pretend you handled it already. you return below
        i, leng = 1, len(tok)
        while True:  # (Case5484): now that you have a flag, all others must b
            fo.set_or_increment_value(values)
            if 'help' == fo.key:
                return bash_argv.clear()  # #here1
            i += 1
            if leng == i:
                break
            pf = fo
            fo = fo_via_char(tok[i])
            if fo.takes_argument:
                no((f"Can't mix flags and arg-takers in one ball of opts: "
                    f"'{pf.short}' then '{fo.short}'"), 16)

    def try_to_parse_custom(tok):
        for fo in (foz.formal_options[i] for i in foz.offsets_of_custom_options):  # noqa: E501
            rx_match_ish = fo.customer()
            mixed_trueish = rx_match_ish(tok)
            if mixed_trueish is None:
                continue
            bash_argv.pop()
            fo.set_or_append_value(values, mixed_trueish)
            return
        if be_passive:
            return passive_stop
        return fo_via_char(tok[1])  # trigger failure

    def fo_via_char(char):
        if (fo := any_fo_via_char(char)) is None:
            no(f"Unrecognized option: '-{char}'", 17)
        return fo

    def any_fo_via_char(char):
        if (i := offset_via_short_char.get(char)) is not None:
            return formal_options[i]

    def parse_short_that_takes_argument(fo, tok):
        if 2 < len(tok):
            fo.set_or_append_value(values, bash_argv.pop()[2:])  # is tok
            return
        fo.set_or_append_value(values, parse_value(fo, 'short'))

    def parse_value(fo, short_or_long):
        lns = ('long', 'short').index(short_or_long)  # lns = long not short
        if 1 == len(bash_argv):
            no(f"Expecting argument for {fo.long}", 14 if lns else 18)
        if len(tok := bash_argv[-2]) and '-' == tok[0]:
            moni, es = getattr(fo, short_or_long), 15 if lns else 19
            no(f"Value looks like option for {moni}. Use {fo.long}=..", es)
        bash_argv.pop()
        return bash_argv.pop()

    def no(msg, exitstatus):
        raise _Stop(msg, exitstatus)  # #here4

    offset_via_short_char = foz.offset_via_short_char
    offset_via_long_stem = foz.offset_via_long_stem
    formal_options = foz.formal_options
    passive_stop = '_passive_stop_'

    return parse_option


# == Render Help

def _write_help_into(foz, serr, doc):
    for line in foz.help_lines(doc):
        serr.write(line)
    return 0


def _help_lines(foz, doc=None, description_valueser=None):
    # absorbed a whole file at #history-B.2

    pcs, maxi = [foz.program_name], 0
    opt_rows, arg_rows, cx_rows = [], [], []

    for fo in foz.formal_options:
        moniker = fo._long_for_column_B()
        leng = len(moniker)
        if maxi < leng:
            maxi = leng
        pcs.append(f'[{fo.short_for_help}]')
        opt_rows.append(((fo.short or ''), moniker, fo.descs[0]))

    for fo in foz.formal_positionals:
        leng = len(fo.moniker)
        if maxi < leng:
            maxi = leng
        pcs.append(fo.surface_expression)
        arg_rows.append(('', fo.moniker, fo.descs[0]))

    yield ''.join(('usage: ', (' '.join(pcs)), '\n'))

    for key, funcer in (cx() if (cx := foz.childrener) else ()):
        func = funcer()
        ch_doc = func.__doc__ or f"(the '{key}' command)"
        desc = re.match(r'^\n?([^\n]+)', ch_doc)[1]
        leng = len(key)
        if maxi < leng:
            maxi = leng
        cx_rows.append(('', key, desc))

    if doc and len(doc):
        if description_valueser:
            doc = doc.format(** description_valueser())
        if '\n' in doc:
            itr = (md[1] for md in re.finditer('(.+\n)[ ]*', doc))
        else:
            itr = iter((f'{doc}\n',))  # (Case5519)

        yield '\n'
        yield f"description: {next(itr)}"
        for line in itr:
            yield f"  {line}"  # indent might go away, idk

    def lines_for_section(label, rows):
        if not len(rows):
            return
        yield '\n'
        yield f"{label}:\n"
        for three in rows:
            yield format_string % three

    if maxi:
        format_string = f'  %2s  %{maxi}s    %s\n'

    for line in lines_for_section('option(s)', opt_rows):
        yield line

    for line in lines_for_section('argument(s)', arg_rows):
        yield line

    if len(cx_rows):
        for line in lines_for_section(f'{fo.key}(s)', cx_rows):  # big flex
            yield line


# == Parse Formals

def formals_via_definitions(definitions, prog_namer=None, cxer=None):
    def main():
        parse_zero_or_more_formal_options()
        parse_zero_or_more_formal_positionals()

    def parse_zero_or_more_formal_positionals():
        while len(vertical_stack):
            fo = parse_formal_positional(vertical_stack.pop())
            if fo.is_special and len(vertical_stack):  # #here3
                _no(f"optional or plural positional can only occur at end: '{fo.surface_expression}'")  # noqa: E501
            formal_posis.append(fo)

    def parse_zero_or_more_formal_options():
        while len(vertical_stack):
            if '-' != vertical_stack[-1][0][0]:
                break
            parse_formal_option(vertical_stack.pop())

    def parse_formal_option(definition):
        fp = do_parse_formal_option(definition)
        offset = len(formal_opts)
        if fp.customer:
            custom_options.append(offset)  # (Case5872)
        if fp.is_required:
            required_options.append(offset)  # (Case5495)
        if (k := fp.short_char):
            assert k not in offset_via_short_char
            offset_via_short_char[k] = offset
        assert fp.long_stem not in offset_via_long_stem
        offset_via_long_stem[fp.long_stem] = offset
        formal_opts.append(fp)

    do_parse_formal_option = _build_formal_option_parser()
    parse_formal_positional = _build_formal_positional_parser()

    custom_options, required_options = [], []
    offset_via_short_char, offset_via_long_stem = {}, {}
    formal_opts, formal_posis = [], []
    vertical_stack = list(reversed(tuple(definitions)))
    main()

    class formals_index:  # "foz"
        childrener = property(lambda _: cxer) if cxer else None
        sparse_tuples_in_grammar_order_via_consume_values = _flatten_vals
        offsets_of_custom_options = tuple(custom_options)
        offsets_of_required_quote_unquote_options = tuple(required_options)
        formal_options = tuple(formal_opts)
        formal_positionals = tuple(formal_posis)

    cls = formals_index
    cls.offset_via_short_char = offset_via_short_char
    cls.offset_via_long_stem = offset_via_long_stem

    if prog_namer:
        cls.parse_alternation_fuzzily = _parse_alternation_fuzzily
        cls.nonterminal_parse = _stop_and_invite(_nonterminal_parse)
        cls.terminal_parse = _stop_and_invite(_terminal_parse)
        cls.passive_parse = _passive_parse
        cls.write_help_into = _write_help_into
        cls.help_lines = _help_lines
        cls.invite_line = property(lambda _: _invite_line(prog_namer()))
        cls.program_name = property(lambda _: prog_namer())

    return formals_index()


def _invite_line(prog_name):
    return f'Use "{prog_name} -h" for help\n'


# == Parse Formal Positional

def _build_formal_positional_parser():  # #testpoint
    # A regular formal positional is required and not plural. But these two
    # characteristics ("imperity" and arity) are here conceived of as boolean
    # meta-parameters, both of which may flip freely, producing four
    # permutations of sensible and allowed form, which we use these shorthand
    # names for: "regular", "glob", "required plural" & "optional positional".
    # Furthermore we now support two styles of surface expression of these:
    #
    # | which               |  classic way  |        🆒 🆕 way
    # | glob                |       <foo>*  |   "[<foo> [..]]"
    # | required plural     |       <foo>+  |     "<foo> [..]"
    # | optional positional |       <foo>?  |        "[<foo>]"

    def parse_formal_positional(definition):  # #here7
        expression, *descs = definition

        # First, parse off the brackets in "<foo> [..]" or "[<foo> [..]]"
        pair = _recursively_parse_formal_positional_expression(expression)
        is_plural, is_required, moniker = _is_plural_is_required_moniker(pair)

        # Then,
        if not (md := rx.match(moniker)):
            _no(f"Expecting formal positional expression. Had: {repr(moniker)}")  # noqa: E501

        # We don't care if u "<foo>" or "foo" or "FOO" but make sure "<>" balan
        lt, stem, gt, kleene = md.groups()
        if 1 < len(set((s is None) for s in (lt, gt))):  # (F, F) or (T, T)
            _no(f"Unbalanced '<' '>'. Need \"<{stem}>\" or \"{stem}\" had \"{stem}\"")  # noqa: E501

        if kleene is not None:
            if is_plural or not is_required:
                _no("Can't use square a bracket form AND a kleene operator ('{kleene}'). Had: {repr(expression)}")  # noqa: E501
            if '*' == kleene:
                is_plural, is_required = True, False
            elif '+' == kleene:
                is_plural = True
            else:
                assert '?' == kleene
                is_required = False
            moniker = ''.join(((lt or ''), stem, (gt or '')))  # get kleene out

        return _FormalPositional(
            stem, moniker, descs, is_required, is_plural, expression)

    rx = re.compile(r'''^
        (?P<less_than><)?                               # maybe starts with "<"
        (?P<stem>    (?: [a-z][a-z0-9]*(?:-[a-z0-9]+)* )   # "foo-bar" or
                   | (?: [A-Z][A-Z0-9]*(?:_[A-Z0-9]+)* ))  # "FOO_BAR"
        (?P<greater_than>>)?                            # maybe ends with ">"
        (?P<kleene_style_arity_expression>[*+?])?$
    ''', re.VERBOSE)

    return parse_formal_positional  # #here7


def _is_plural_is_required_moniker(pair):

    # If right side is none, it's a plain old positional. "<arg>"
    if pair[1] is None:
        return False, True, pair[0]

    # Currently the innermost moniker of the expression must be an ellipsis
    _monikers_recursive(monks := [], pair)
    if monks[-1] not in ('..', '…', '...'):
        _no("Currently, the innermost moniker of a nested optional positional "
            f"expression must be an ellipsis. Had: {repr(monks[-1])}")

    # If left side is empty string, the whole thing is contained in []
    whole_thing_is_optional = 0 == len(pair[0])

    # To support the "[<foo> [<bar> [<baz>]]]" form would be novel but there's
    # no real-world case yet. Currently we target (only) these three #here6.
    here = 1 if whole_thing_is_optional else 0
    nominitive_monikers = monks[here:-1]
    if 1 < len(uniq := set(nominitive_monikers)):
        # (Case_5405) flickers if we don't keep the below in surface order
        ordered = sorted(uniq, key=lambda k: nominitive_monikers.index(k))
        _ = ''.join(('Had: (', ', '.join(_ox().keys_map(ordered)), ')'))
        _no("Currently there's no support for multiple optional positionals. "
            f"All monikers in a positional expression must be the same. {_}")

    if whole_thing_is_optional:  # "[<arg> [..]]"
        return True, False, monks[here]

    # If left side is not empty string, it's required "<arg> [<arg> [..]]"
    return True, True, monks[here]


def _monikers_recursive(monikers, pair):
    left, right = pair
    monikers.append(left)  # maybe empty string
    if right is not None:
        _monikers_recursive(monikers, right)


def _recursively_parse_formal_positional_expression(string):
    # Generalize these forms (#here6):
    #
    #   - required plural:      <file> [<file> [..]]
    #   - glob:                 [<command> [..]]
    #   - regular positional:   <arg>

    if ']' != string[-1]:
        return string, None  # base case

    # Get the zero or more head content
    md = re.match(r'^([^ \[]*) ?\[', string)
    left = md[1]
    right_string = string[md.span()[1]:-1]
    right = _recursively_parse_formal_positional_expression(right_string)
    return left, right


# == Parse Formal Option

def _build_formal_option_parser():
    def parse_formal_option(definition):  # #here7
        dstack = list(reversed(definition))

        # == begin experiment

        def main():
            if head_looks_short():
                if scan_ordinary_short():
                    parse_long()
                else:
                    parse_custom()
            else:
                parse_long()

        def head_looks_short():  # '^-' followed by not '-'
            return store('md', re.match('^-((?!-).+)', tok()))

        def scan_ordinary_short():
            if re.match('^[a-zA-Z]$', short_char := self.md[1]):
                return store('short_char', 'short', short_char, pop())

        def parse_long():
            if not (md := long_rx.match(tok())):
                _no(f"Expecting long switch expression, had: {tok()!r}")
            _ = (pop(), *md.groups())
            store('longg', 'long_stem', 'arg_moniker', 'arity_or_imperity', *_)

        def parse_custom():
            rx = re.compile("""^
                -< (?P<stem>  [a-z][a-z0-9]*(?:-[a-z0-9]+)*  ) >
                (?P<arity_or_imperity>  [!*+]  )?  $""", re.VERBOSE)
            if not (md := rx.match(tok())):
                _no(f"Can't support a short switch like this yet: {tok()!r}")
            store('long_stem', 'arity_or_imperity',  *md.groups())  # noqa: E501
            store('short', 'customer', pop(), pop())
            assert callable(self.customer)

        def store(*omg):
            half, rem = divmod(leng := len(omg), 2)
            assert not rem
            keys, vals = omg[:half], omg[half:]
            for i in range(0, half):
                setattr(self, keys[i], vals[i])
            return vals[0] if 2 == leng else True

        def pop():
            return dstack.pop()

        def tok(what=None):
            if len(dstack):
                return dstack[-1]
            _no(f"Definition ended too early: {definition!r}")

        these = 'short', 'short_char', 'customer', \
            'longg', 'long_stem', 'arg_moniker', 'arity_or_imperity'
        self = main  # meh
        store(*these, *(None for _ in range(0, len(these))))
        main()
        short, short_char, customer, \
            longg, long_stem, arg_moniker, arity_or_imperity = \
            (getattr(self, k) for k in these)

        # == end experiment

        is_required, is_plural = False, False
        if arity_or_imperity is None:
            pass
        elif '*' == arity_or_imperity:
            is_plural = True  # (Case5489)
        elif '!' == arity_or_imperity:  # justified in (Case5495)
            if not arg_moniker:
                _no(f"'!' cannot be used on flags, only on options that "
                    f"take arguments. Had: '{longg}'")  # (Case5494)
            is_required = True
        else:
            assert '+' == arity_or_imperity  # (Case
            xx('case this')
            is_required, is_plural = True, True

        # One or more descs
        if not len(dstack):
            _no(f"For now, always supply description ({short or longg})")

        descs = tuple(reversed(dstack))
        return _FormalOption(short_char, customer, long_stem,
                             arg_moniker, descs, is_required, is_plural)

    long_rx = re.compile(r'''^
      --(?P<stem>  [a-zA-Z][a-zA-Z0-9]* (?: -[a-zA-Z][a-zA-Z0-9]* )* )
      (?: =
        (?P<arg_moniker>
           <[a-z][a-z0-9]+(?:-[a-z][a-z0-9]+)*>   # dashes IFF all lowercase
          | [A-Z][A-Z0-9]*(?:_[A-Z][A-Z0-9]+)* )  # underscores IFF all upper
      )?      # we allow ☝️ a single-character name IFF it's upper (Case5495)
      (?P<arity_or_imperity>  [!*+]  )?
    $''', re.VERBOSE)

    return parse_formal_option


# == Model

class _FormalOption:
    def __init__(o, sc, customer, ls, am, ds, ir, ip):
        o.customer = customer
        o.short_char, o.long_stem, o.arg_moniker, o.descs = sc, ls, am, ds
        o.is_required, o.is_plural, o.is_singular = ir, ip, not ip
        o.takes_argument = o.arg_moniker is not None
        o.key = o.long_stem.replace('-', '_')

    def set_or_append_value(o, vals, val):
        if o.is_singular:
            vals[o.key] = val
            return
        if o.key not in vals:
            vals[o.key] = []
        vals[o.key].append(val)

    def set_or_increment_value(o, vals):  # for flags (incrementing and not)
        if o.is_singular:
            vals[o.key] = True
            return
        if o.key not in vals:
            vals[o.key] = 0
        vals[o.key] += 1

    @property
    def short_for_help(o):
        head = o.short if o.short_char else o.long
        tail = '=X' if o.takes_argument else ''
        return ''.join((head, tail))

    def _long_for_column_B(o):
        return ''.join((o.long, *(('=', o.arg_moniker) if o.takes_argument else ())))  # noqa: E501

    @property
    def long(o):
        if o.customer:
            return f"-<{o.long_stem}>"
        return f"--{o.long_stem}"

    @property
    def short(o):
        if o.short_char:
            return f'-{o.short_char}'


class _FormalPositional:
    def __init__(o, stem, moniker, descs, is_required, is_plural, surface):
        o.key = stem.replace('-', '_').lower()
        o.moniker, o.descs = moniker, descs
        o.is_required, o.is_plural = is_required, is_plural
        o.is_optional, o.is_singular = (not is_required), (not is_plural)
        o.is_special = is_plural or o.is_optional
        o.surface_expression = surface


def _no(msg):
    raise DefinitionError_(msg)


class DefinitionError_(RuntimeError):  # #testpoint (only)
    pass


class _Stop(RuntimeError):
    pass


def _ox():
    from text_lib.magnetics import via_words as mod
    return mod


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


# #history-B.2: blind rewrite
# #history-A.7: sunsetted last traces of stepper
# #history-A.6: sub-expressions
# #history-A.5: expose API for "cheap arg parse branch"
# #history-A.4: help & initial integration
# #history-A.3: begin parser-generator-backed rewrite of "cheap arg parse"
# #history-A.2: MASSIVE exodus
# #history-A.1: as referenced (can be temporary)
# #born.
