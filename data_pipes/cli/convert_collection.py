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

    def main():  # (this logic is repeated 1x in a test :[#459.M])
        with open_the_input_collection_for_traversal() as (schema, ents):
            with open_the_output_collection_for_writing() as receiver:
                receiver.receive_schema_and_entities(schema, ents, listener)
        return mon.exitstatus

    def open_the_input_collection_for_traversal():
        fmt, x = normalize(from_format, from_collection, stdin, _from_monikers)
        coll = resolve_collection(fmt, x)
        return coll.open_schema_and_entity_traversal(throwing_listener)

    def open_the_output_collection_for_writing():
        fmt, x = normalize(to_format, to_collection, stdout, _to_monikers)
        coll = resolve_collection(fmt, x)
        return coll.open_collection_to_write_given_traversal(throwing_listener)

    def resolve_collection(fmt, arg):
        return collib.collection_via_path(
            arg, throwing_listener, format_name=fmt)

    def normalize(fmt, arg, sin_sout, o):
        if '-' == arg:
            if sin_sout.isatty() and 'STDIN' == o.STDIN_STDOUT:
                # (oops this one is asymmetrical)
                error(f"when {o.arg} is '-', {o.STDIN_STDOUT} must be a pipe")
            use_coll_ID = sin_sout
            if fmt is None:
                fmt = 'json'
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
