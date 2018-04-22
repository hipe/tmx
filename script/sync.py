#!/usr/bin/env python3 -W error::Warning::0


# == BEGIN a lot of this will become much more OCD-compliant near #open [#502]

_description_of_sync = """line one
line two"""


def __populate_argument_parser(ap):

    ap.add_argument(
            '--from',  # "thing_one"
            help='«help for thing one»',
            metavar='«from-descriptor»',
            )

    ap.add_argument(
            '--to',  # "thing_two"
            help='«help for thing two»',
            metavar='«to-descriptor»',
            )


def _myCLI(sin, sout, serr, argv):

    def __main():
        ok and __resolve_namespace()
        ok and __validate_required_options()
        ok and __boogey()
        return exitstatus

    def __boogey():
        from_s = getattr(namespace, 'from')  # 😥
        to_s = namespace.to
        serr.write("from: {} and to: {}\n".format(from_s, to_s))
        nonlocal exitstatus
        exitstatus = sl.SUCCESS

    def __validate_required_options():

        _these = ['from', 'to']  # ['thing_one', 'thing_two']
        missing = [atr for atr in _these if getattr(namespace, atr) is None]
        if len(missing) != 0:
            _monikers = ['--{}'.format(s.replace('_', '-')) for s in missing]
            _these = ', '.join(_monikers)
            serr.write("missing required optional(s): {}\n".format(_these))
            _stop_early(sl.GENERIC_ERROR)

    def __resolve_namespace():
        es, ns = __procure_exitstatus_or_namespace(serr, argv)
        if es is None:
            nonlocal namespace
            namespace = ns
        else:
            _stop_early(es)

    def _stop_early(es):
        nonlocal exitstatus
        exitstatus = es
        nonlocal ok
        ok = False

    import script_lib as sl
    namespace = None
    exitstatus = None
    ok = True
    return __main()


def __procure_exitstatus_or_namespace(serr, argv):

    import script_lib.magnetics.fixed_argument_parser_via_argument_parser as ap_lib  # noqa: E501

    from collections import deque
    argv_stream = deque(argv)

    ap = __build_argument_parser(serr, argv_stream, ap_lib)

    e = None
    try:
        ns = ap.parse_args(argv_stream)
    except ap_lib.Interruption as e_:
        e = e_

    if e:
        s = e.message
        es = e.exitstatus
        if es == 0:
            None if s is None else sanity()
        else:
            serr.write(s)
        return (es, None)
    else:
        return (None, ns)


def __build_argument_parser(serr, argv_stream, ap_lib):

    _prog = argv_stream.popleft()
    ap = __begin_argument_parser(serr, _prog, ap_lib)
    __populate_argument_parser(ap)
    return ap


def __begin_argument_parser(serr, prog, ap_lib):

    ap = ap_lib.begin_native_argument_parser_to_fix(
            prog=prog,
            description=_description_of_sync,
            )

    ap_lib.fix_argument_parser(ap, serr)
    return ap

# == END


def sanity():
    ohai('sanity')


def ohai(s):
    raise Exception(s)


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    _exitstatus = _myCLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #born.
