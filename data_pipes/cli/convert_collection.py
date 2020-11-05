from collections import namedtuple as _nt


IS_CHAINABLE = True
MUST_BE_ENDPOINT_OF_PIPELINE = True


def NONTERMINAL_PARSE_ARGS(serr, bash_argv):
    prog_name = bash_argv.pop()
    from data_pipes.cli import formals_via_ as func
    foz = func(_formals(), lambda: prog_name)
    vals, rc = foz.nonterminal_parse(serr, bash_argv)

    # #track [#459.O]: resulting in *three* args below
    if vals is None:
        return None, None, rc
    return vals, foz, None


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


def BUILD_COLLECTION_MAPPER(stderr, vals, foz, rscser):
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

    if vals.get('help'):
        doc = BUILD_COLLECTION_MAPPER.__doc__
        rc = foz.write_help_into(stderr, doc)
        return None, rc

    to_collection = vals.pop('to_collection')

    to_format_default = None
    if '-' == to_collection:
        to_format_default = 'json'  # experiment

    to_format = vals.pop('to_format', to_format_default)
    assert not vals

    def collection_mapper_via_sout(sout):
        def map_collection(schema, ents):
            try:
                return do_map_collection(sout, schema, ents)
            except stop:
                return 9876
        return map_collection

    def do_map_collection(sout, schema, ents):
        with open_the_output_collection_for_writing(sout) as receiver:
            receiver.receive_schema_and_entities(schema, ents, listener)
        return mon.returncode

    def open_the_output_collection_for_writing(stdout):
        fmt, x = normalize(to_format, to_collection, stdout, _to_monikers)
        coll = resolve_collection(fmt, x)
        return coll.open_collection_to_write_given_traversal(throwing_listener)

    def resolve_collection(fmt, arg):
        return collib.collection_via_path(
            arg, throwing_listener, format_name=fmt)

    def normalize(fmt, arg, sin_sout, o):
        from data_pipes.cli import normalize_collection_reference_ as func
        return func(sin_sout, fmt, arg, o.STDIN_STDOUT, o.arg, error)

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

    # == Smalls and go!

    from data_pipes import meta_collection_ as func
    collib = func()

    mon = rscser().produce_monitor()
    listener = mon.listener

    return collection_mapper_via_sout, None


# #history-B.1: rewrote
# #born.
