def _formals():
    yield f'{_from_format_flag}=<fmt>', _same_help
    yield('--from-arg=<arg>*',
          'EXPERIMENTAL pass thru to producer script (yikes)')
    yield f'{_to_format_flag}=<fmt>', _same_help
    from data_pipes.cli import this_screen_ as this_screen
    yield '-h', '--help', this_screen
    yield _from_arg_moniker, 'the collection the data comes from'
    yield _to_arg_moniker, 'the collection the data goes to'


_from_arg_moniker = 'FROM_COLLECTION'
_from_format_flag = '--from-format'

_to_arg_moniker = 'TO_COLLECTION'
_to_format_flag = '--to-format'


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

    There is only one particiapting output format at writing, and it
    only writes to STDOUT.
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
        maybe_dash_is_used_as_FROM()
        maybe_dash_is_used_as_TO()
        make_sure_STDIN_interactivity_looks_right()
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

    def resolve_to_collection():
        return when_STDOUT() if self.TO_is_STDOUT else when_not_STDOUT()

    def resolve_from_collection():
        return when_STDIN() if self.FROM_is_STDIN else when_not_STDIN()

    def when_STDOUT():
        return self.to_SA.module.COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
            stdout, mon.listener)

    def when_STDIN():
        return self.from_SA.module.COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
            stdin, mon.listener)

    def when_not_STDOUT():
        return meta_collection.collection_via_path(
            to_collection, tl, format_name=to_format)._impl

    def when_not_STDIN():
        return meta_collection.collection_via_path(
            from_collection, tl, format_name=from_format)._impl

    def make_sure_STDIN_interactivity_looks_right():
        if self.FROM_is_STDIN:
            if not stdin.isatty():
                return
            error(f"when {_from_arg_moniker} is '-' STDIN must be a pipe")
        if stdin.isatty():
            return
        error(f"STDIN cannot be a pipe unless {_from_arg_moniker} is '-'")

    def maybe_dash_is_used_as_FROM():
        dash_ham('FROM_is_STDIN', 'from_SA', _from_arg_moniker,
                 _from_format_flag, from_collection, from_format)

    def maybe_dash_is_used_as_TO():
        dash_ham('TO_is_STDOUT', 'to_SA', _to_arg_moniker,
                 _to_format_flag, to_collection, to_format)

    def dash_ham(yn_attr, sa_attr, arg_moniker, format_flag, coll_path, fmt):
        memo(yn_attr, yn := '-' == coll_path)
        if not yn:
            return
        if fmt is None:
            error(f"{arg_moniker} of '-' requires '{format_flag}'")
        memo(sa_attr, meta_collection.storage_adapter_via_format_name(fmt, tl))

    # == Listeners and related

    def throwing_listener(sev, *rest):
        mon.listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    tl = throwing_listener

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
    meta_collection = func()

    mon = monitor_via_(stderr)
    try:
        return main()
    except stop:
        return 9876


# #history-B.1: rewrote
# #born.
