from collections import namedtuple as _nt


def _formals():

    # (using '-f' is nice because it looks and means like ffmpeg)
    yield '-f', f'{_from_monikers.format_flag}=<fmt>', _same_help

    yield('--from-arg=<arg>*',
          'EXPERIMENTAL pass thru to producer script (yikes)')

    # (using '-t' is sad, we would rather have again '-f' like ffmpeg
    # but that would require custom arg parsing that is way out of scope.
    # it's basically `[opts] arg` twice. #wish [#459.T])
    yield '-t', f'{_to_monikers.format_flag}=<fmt>', _same_help

    from data_pipes.cli import this_screen_ as this_screen
    yield '-h', '--help', this_screen
    yield _from_monikers.arg, 'the collection the data comes from'
    yield _to_monikers.arg, 'the collection the data goes to'


_monikers = _nt('Monikers', ('arg', 'format_flag', 'STDIN_STDOUT'))
_from_monikers = _monikers('FROM_COLLECTION', '--from-format', 'STDIN')
_to_monikers = _monikers('TO_COLLECTION', '--to-format', 'STDOUT')


_same_help = "(or will try to infer from file extension if present)"


def CLI_(stdin, stdout, stderr, argv, rscer):
    """Harness the power of pipes…"""

    # ..

    """EXPERIMENTAL. Created as a cheap-and-easy way to create and populate
    a collection with a producer script or similar.

    With FROM_COLLECTION of "-", lines of the indicated format are read from
    STDIN. With TO_COLLECTION of "-", lines of the specified format are
    written to STDOUT. Only certain formats are available for certain cases;
    for example an output of "-" is available only for single-file formats.

    At writing the only participating formats are CSV and json..
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    from data_pipes.cli import formals_via_ as func, \
        write_help_into_, monitor_via_
    foz = func(_formals(), lambda: prog_name)
    vals, es = foz.terminal_parse(stderr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return write_help_into_(stderr, CLI_.__doc__, foz)

    from_collection = vals.pop('from_collection')
    to_collection = vals.pop('to_collection')

    to_format_default = None
    if '-' == to_collection:
        to_format_default = 'json'  # experiment

    from_format = vals.pop('from_format', None)
    to_format = vals.pop('to_format', to_format_default)

    from_args = vals.pop('from_arg', ())
    if len(from_args):
        raise RuntimeError('gone now')

    assert not vals

    # shouldn't need RNG ever - don't we want to transfer the same ID's in?

    def main():
        try:
            return main_NEW_WAY()
        except stop_because_OLD_WAY as exe:
            e = exe
        check_all_old(*e.args)
        return main_OLD_WAY()

    def main_OLD_WAY():
        from_coll = resolve_from_collection()
        to_coll = resolve_to_collection()
        sch, ents = from_coll.to_schema_and_entities(throwing_listener)
        with to_coll.open_pass_thru_receiver_as_storage_adapter(mon.listener) as recv:  # noqa: E501
            if True:
                for ent in ents:
                    assert ent.path
                    assert ent.lineno
                    dct = ent.core_attributes_dictionary_as_storage_adapter_entity  # noqa: E501
                    recv(dct)
        return mon.exitstatus

    def main_NEW_WAY():
        with open_the_input_collection_for_traversal() as (schema, ents):
            with open_the_output_collection_for_writing() as receiver:
                receiver.receive_schema_and_entities(schema, ents, listener)
        return mon.exitstatus

    # == BEGIN hack bridge to accomodate old way which will go away eventually

    def resolve_to_collection():
        fmt, arg = normalize(to_format, to_collection, stdout, _to_monikers)
        return chum_chum_zum_zum(fmt, arg)

    def resolve_from_collection():
        fmt, s = normalize(from_format, from_collection, stdin, _from_monikers)
        return chum_chum_zum_zum(fmt, s)

    def chum_chum_zum_zum(fmt, arg):
        _ = collib.collection_via_path(arg, throwing_listener, format_name=fmt)
        return _._impl

    def check_all_old(input_or_output):
        expect_is_none = ('output', 'input').index(input_or_output)
        two, two_ = REMEMBER_THESE_PEEKS
        is_none_ = two_ is None
        assert bool(expect_is_none) == is_none_
        if is_none_:
            if (use_to_format := to_format) is None:
                use_to_format = hack_infer_format(to_collection)
            two_ = use_to_format, to_collection
        fmt, arg = two
        fmt_, arg_ = two_
        is_old, is_old_ = is_old_way[fmt], is_old_way[fmt_]
        if all((is_old, is_old_)):
            return
        s, s_ = (('old' if b else 'new') for b in (is_old, is_old_))
        msgs, pcs = [], []
        pcs.append(f"can't convert from {fmt} (which is currently {s} way)")
        pcs.append(f"to {fmt_} (which is currently {s_} way)")
        msgs.append(' '.join(pcs))
        msgs.append(f"(from collection: {arg})")
        msgs.append(f"(to collection: {arg_})")
        long_msg = '. '.join(msgs)
        raise RuntimeError(long_msg)

    def CHECK_FOR_OLD_WAY(fmt, arg, input_or_output):
        if fmt is None:
            fmt = hack_infer_format(arg)
        offset = ('input', 'output').index(input_or_output)
        REMEMBER_THESE_PEEKS[offset] = fmt, arg
        if is_old_way[fmt]:
            raise stop_because_OLD_WAY(input_or_output)

    def hack_infer_format(arg):
        from os.path import splitext
        return cha_via_cha[splitext(arg)[1]]

    REMEMBER_THESE_PEEKS = [None, None]

    cha_via_cha = {
        '.csv': 'csv',
        '.json': 'json',
        '.md': 'markdown-table',
        '.py': 'producer-script',
    }

    is_old_way = {
        'csv': False,
        'json': False,
        'markdown-table': True,
        'producer-script': True,
    }

    class stop_because_OLD_WAY(RuntimeError):
        pass

    # == END old way will go away

    def open_the_input_collection_for_traversal():
        fmt, s = normalize(from_format, from_collection, stdin, _from_monikers)
        CHECK_FOR_OLD_WAY(fmt, s, 'input')  # delete just this line in the futu
        return collib.OPEN_FOR_READING_THE_NEW_WAY(fmt, s, throwing_listener)

    def open_the_output_collection_for_writing():
        fmt, arg = normalize(to_format, to_collection, stdout, _to_monikers)
        CHECK_FOR_OLD_WAY(fmt, arg, 'output')  # delete just this line in the f
        return collib.OPEN_FOR_WRITING_THE_NEW_WAY(fmt, arg, throwing_listener)

    def normalize(fmt, arg, sin_sout, o):
        if '-' == arg:
            if sin_sout.isatty() and 'STDIN' == o.STDIN_STDOUT:
                # (oops this one is asymmetrical)
                error(f"when {o.arg} is '-', {o.STDIN_STDOUT} must be a pipe")
            use_coll_ID = sin_sout
        elif sin_sout.isatty():
            use_coll_ID = arg
        else:
            error(f"{o.STDIN_STDOUT} cannot be a pipe unless {o.arg} is '-'")
        return fmt, use_coll_ID

    # == Listeners and related

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    def error(msg):
        stderr.write(''.join((msg, '\n')))  # ich muss sein [#605.2]
        raise stop()

    class stop(RuntimeError):
        pass

    # == Our `self` and writing to it

    def memo(attr, mixed):
        setattr(self, attr, mixed)

    class self:  # #class-as-namespace
        pass

    # == Smalls and go!

    from data_pipes import meta_collection_ as func
    collib = func()

    mon = monitor_via_(stderr)
    listener = mon.listener
    try:
        return main()
    except stop:
        return 9876


# #history-B.1: rewrote
# #born.
